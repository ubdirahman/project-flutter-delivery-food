const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const Food = require('../models/Food');
const { protect, authorize } = require('../middleware/auth');
const mongoose = require('mongoose');

// Create a new order
router.post('/', protect, async (req, res) => {
    console.log('Order creation attempt by:', req.user ? req.user.email : 'Unknown User');
    console.log('Order Data:', JSON.stringify(req.body, null, 2));

    const { userId, items, totalAmount, paymentMethod, address, restaurantId } = req.body;
    console.log('Incoming Order for Restaurant ID:', restaurantId);

    if (!items || !Array.isArray(items) || items.length === 0) {
        console.log('Order creation failed: items missing or empty');
        return res.status(400).json({ success: false, message: 'Order must contain at least one item' });
    }

    try {
        // 1. Verify and decrement quantity for each item
        for (const item of items) {
            if (!item.foodId || !mongoose.Types.ObjectId.isValid(item.foodId)) {
                return res.status(400).json({ success: false, message: `Invalid foodId: ${item.foodId}` });
            }
            const food = await Food.findById(item.foodId);
            if (!food) {
                return res.status(404).json({ success: false, message: `Food item ${item.name || item.foodId} not found` });
            }
            if (food.quantity < item.quantity) {
                console.log(`Insufficient stock for ${food.name}: requested ${item.quantity}, available ${food.quantity}`);
                return res.status(400).json({
                    success: false,
                    message: `Not enough quantity for ${food.name}. Available: ${food.quantity}`
                });
            }
        }

        // 2. Create the order first (to ensure ID is valid before decrementing)
        const order = new Order({
            userId: userId || req.user._id,
            items,
            totalAmount,
            paymentMethod,
            address,
            restaurantId
        });
        await order.save();

        // 3. Decrement quantities
        for (const item of items) {
            await Food.findByIdAndUpdate(item.foodId, { $inc: { quantity: -item.quantity } });
        }

        console.log('Order created successfully:', order._id);
        res.status(201).json({ success: true, order });
    } catch (err) {
        console.error('Order creation error:', err);
        res.status(400).json({
            success: false,
            message: err.name === 'ValidationError' ? 'Validation Failed' : err.message,
            errors: err.errors
        });
    }
});

// Get user orders
router.get('/user/:userId', protect, async (req, res) => {
    console.log(`Fetching orders for user: ${req.params.userId} requested by: ${req.user.email}`);

    // Check if valid ObjectId to prevent CastError
    if (!mongoose.Types.ObjectId.isValid(req.params.userId)) {
        return res.status(400).json({ success: false, message: 'Invalid User ID format' });
    }

    // Only allow user to see their own orders unless admin
    if (req.user._id.toString() !== req.params.userId && req.user.role === 'user') {
        console.log(`Unauthorized order access attempt: ${req.user._id} tried to access ${req.params.userId}`);
        return res.status(403).json({ success: false, message: 'Unauthorized' });
    }
    try {
        const orders = await Order.find({ userId: req.params.userId }).sort({ createdAt: -1 });
        console.log(`Successfully found ${orders.length} orders for user ${req.params.userId}`);
        res.json(orders);
    } catch (err) {
        console.error(`Order retrieval error for user ${req.params.userId}:`, err);
        res.status(500).json({ success: false, message: 'Internal Server Error while fetching orders' });
    }
});

// Update order status
router.patch('/:orderId', protect, authorize('admin', 'superadmin', 'staff', 'delivery'), async (req, res) => {
    try {
        const { status } = req.body;

        if (!mongoose.Types.ObjectId.isValid(req.params.orderId)) {
            return res.status(400).json({ success: false, message: 'Invalid Order ID format' });
        }

        let order = await Order.findById(req.params.orderId);
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }

        // Enforce restaurant isolation for staff and restaurant admins
        if (req.user.role !== 'superadmin' && req.user.restaurantId) {
            if (order.restaurantId.toString() !== req.user.restaurantId.toString()) {
                return res.status(403).json({ success: false, message: 'Not authorized to update orders for other restaurants' });
            }
        }

        order.status = status;
        await order.save();

        res.json(order);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Delete order
router.delete('/:orderId', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        if (!mongoose.Types.ObjectId.isValid(req.params.orderId)) {
            return res.status(400).json({ success: false, message: 'Invalid Order ID format' });
        }

        const order = await Order.findByIdAndDelete(req.params.orderId);
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }
        res.json({ success: true, message: 'Order deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
