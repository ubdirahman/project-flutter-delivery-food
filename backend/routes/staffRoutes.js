const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const { protect, authorize } = require('../middleware/auth');
const Order = require('../models/Order');
const User = require('../models/User');

// GET all orders that are Pending and Paid (or Cash on Delivery)
router.get('/orders/pending', protect, authorize('staff', 'admin', 'superadmin', 'delivery'), async (req, res) => {
    try {
        const { restaurantId } = req.query;
        console.log('Fetching pending orders for restaurant:', restaurantId || 'ALL');

        let query = {};
        if (req.user.role === 'delivery') {
            // Delivery sees orders that are Accepted, Preparing, or Ready, AND not yet assigned to a delivery person
            query.status = { $in: ['Accepted', 'Preparing', 'Ready'] };
            query.deliveryId = { $exists: false }; // Or null
        } else {
            query.status = 'Pending';
        }

        if (restaurantId && restaurantId !== 'null' && restaurantId !== 'undefined') {
            if (mongoose.Types.ObjectId.isValid(restaurantId)) {
                query.restaurantId = new mongoose.Types.ObjectId(restaurantId);
            }
        }

        const orders = await Order.find(query)
            .populate('userId', 'username email')
            .populate('staffId', 'username phoneNumber')
            .populate('restaurantId', 'name address')
            .sort({ createdAt: -1 });

        console.log(`Found ${orders.length} pending orders`);
        res.json(orders);
    } catch (err) {
        console.error('Pending orders error:', err);
        res.status(500).json({ message: err.message });
    }
});

// Accept Order
router.patch('/orders/:id/accept', protect, authorize('staff', 'admin', 'superadmin', 'delivery'), async (req, res) => {
    try {
        const { staffId } = req.body;
        let newStatus = 'Accepted';
        if (req.user.role === 'delivery') {
            newStatus = 'Handed to Delivery';
        }

        const order = await Order.findByIdAndUpdate(
            req.params.id,
            {
                status: newStatus,
                staffId: staffId
            },
            { new: true }
        );
        if (!order) return res.status(404).json({ message: 'Order not found' });
        res.json({ success: true, order });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Reject Order
router.patch('/orders/:id/reject', protect, authorize('staff', 'admin', 'superadmin', 'delivery'), async (req, res) => {
    try {
        const { rejectionReason } = req.body;
        const order = await Order.findByIdAndUpdate(
            req.params.id,
            {
                status: 'Rejected',
                rejectionReason: rejectionReason || 'No reason provided'
            },
            { new: true }
        );
        if (!order) return res.status(404).json({ message: 'Order not found' });
        res.json({ success: true, order });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Get Restaurant Stats (Total Orders, Total Revenue, etc.)
router.get('/stats/:restaurantId', protect, authorize('staff', 'admin', 'superadmin', 'delivery'), async (req, res) => {
    try {
        const { restaurantId } = req.params;

        if (!mongoose.Types.ObjectId.isValid(restaurantId)) {
            return res.status(400).json({ message: 'Invalid restaurantId format' });
        }

        const oid = new mongoose.Types.ObjectId(restaurantId);
        console.log(`Fetching stats for restaurant: ${restaurantId}`);

        // Total Orders
        const totalOrders = await Order.countDocuments({ restaurantId: oid });

        // Total Revenue (only for non-cancelled orders)
        const revenueData = await Order.aggregate([
            { $match: { restaurantId: oid, status: { $ne: 'Cancelled' } } },
            { $group: { _id: null, total: { $sum: '$totalAmount' } } }
        ]);

        const totalRevenue = (revenueData && revenueData.length > 0) ? revenueData[0].total : 0;

        // Orders by Status
        const statusBreakdown = await Order.aggregate([
            { $match: { restaurantId: oid } },
            { $group: { _id: '$status', count: { $sum: 1 } } }
        ]);

        // Convert statusBreakdown to object for easier access
        const statusCounts = {};
        statusBreakdown.forEach(item => {
            statusCounts[item._id] = item.count;
        });

        // Available for Delivery (Accepted, Preparing, or Ready but no deliveryId)
        const availableForDelivery = await Order.countDocuments({
            restaurantId: oid,
            status: { $in: ['Accepted', 'Preparing', 'Ready'] },
            deliveryId: { $exists: false }
        });

        res.json({
            success: true,
            stats: {
                totalOrders,
                totalRevenue,
                pendingOrders: statusCounts['Pending'] || 0,
                acceptedOrders: statusCounts['Accepted'] || 0,
                preparingOrders: statusCounts['Preparing'] || 0,
                readyOrders: statusCounts['Ready'] || 0,
                availableForDelivery,
                handedToDeliveryOrders: statusCounts['Handed to Delivery'] || 0,
                deliveredOrders: statusCounts['Delivered'] || 0,
                rejectedOrders: statusCounts['Rejected'] || 0,
                cancelledOrders: statusCounts['Cancelled'] || 0,
                statusBreakdown
            }
        });
    } catch (err) {
        console.error('Stats error:', err);
        res.status(500).json({ message: 'Stats error: ' + err.message });
    }
});

// Accept Order for Delivery (Agree)
router.patch('/orders/:id/agree-delivery', protect, authorize('delivery', 'admin', 'superadmin'), async (req, res) => {
    try {
        const order = await Order.findByIdAndUpdate(
            req.params.id,
            {
                deliveryId: req.user._id,
                // We keep the main status as is (Accepted/Preparing/Ready)
            },
            { new: true }
        ).populate('deliveryId', 'username phoneNumber');

        if (!order) return res.status(404).json({ message: 'Order not found' });
        res.json({ success: true, order });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Reject Order for Delivery (Cannot take it)
router.patch('/orders/:id/reject-delivery', protect, authorize('delivery', 'admin', 'superadmin'), async (req, res) => {
    try {
        const { reason } = req.body;
        const order = await Order.findByIdAndUpdate(
            req.params.id,
            {
                deliveryId: null, // Ensure it's not assigned
                rejectionReason: reason || 'Delivery person cannot take this order'
            },
            { new: true }
        );

        if (!order) return res.status(404).json({ message: 'Order not found' });
        res.json({ success: true, order });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Update Order Status (Processing)
router.patch('/orders/:id/status', protect, authorize('staff', 'admin', 'superadmin', 'delivery'), async (req, res) => {
    try {
        const { status } = req.body;
        const validStatuses = ['Preparing', 'Ready', 'Handed to Delivery', 'Delivered'];

        if (!validStatuses.includes(status)) {
            return res.status(400).json({ message: 'Invalid status update' });
        }

        const order = await Order.findByIdAndUpdate(
            req.params.id,
            { status },
            { new: true }
        );
        if (!order) return res.status(404).json({ message: 'Order not found' });
        res.json({ success: true, order });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET orders managed by specific staff member
router.get('/orders/managed', protect, authorize('staff', 'admin', 'superadmin', 'delivery'), async (req, res) => {
    try {
        const userId = req.user._id;
        console.log(`Fetching managed orders for staff: ${userId}`);

        const orders = await Order.find({
            $or: [
                { staffId: userId },
                { deliveryId: userId }
            ],
            status: { $in: ['Accepted', 'Preparing', 'Ready', 'Handed to Delivery'] }
        })
            .populate('userId', 'username email phoneNumber')
            .populate('staffId', 'username phoneNumber')
            .populate('deliveryId', 'username phoneNumber')
            .sort({ updatedAt: -1 });

        res.json(orders);
    } catch (err) {
        console.error('Managed orders error:', err);
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
