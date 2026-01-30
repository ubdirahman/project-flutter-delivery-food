const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const User = require('../models/User');

// Middleware to verify staff role (Simple version for now)
const verifyStaff = async (req, res, next) => {
    // In a real app, this would use JWT and check req.user.role
    // For this implementation, we'll assume the frontend sends staffId in headers or body for simplicity
    // or we just trust the staff panel routes for now as per "Staff Responder System" requirements.
    next();
};

// GET all orders that are Pending and Paid (or Cash on Delivery)
router.get('/orders/pending', async (req, res) => {
    try {
        const orders = await Order.find({
            status: 'Pending',
            // Typically only show orders that are paid or COD
            paymentStatus: { $in: ['Paid', 'Pending'] }
        })
            .populate('userId', 'username email')
            .sort({ createdAt: -1 });

        res.json(orders);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Accept Order
router.patch('/orders/:id/accept', async (req, res) => {
    try {
        const { staffId } = req.body;
        const order = await Order.findByIdAndUpdate(
            req.params.id,
            {
                status: 'Accepted',
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
router.patch('/orders/:id/reject', async (req, res) => {
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

// Update Order Status (Processing)
router.patch('/orders/:id/status', async (req, res) => {
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

module.exports = router;
