const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Message = require('../models/Message');
const User = require('../models/User');

const { protect, authorize } = require('../middleware/auth');

// Send a message (User to Restaurant Admin)
router.post('/', protect, async (req, res) => {
    try {
        console.log('Incoming Message Data:', JSON.stringify(req.body, null, 2));
        let { senderId, restaurantId, orderId, content, type } = req.body;

        // Fallback: If restaurantId is missing but orderId is present, find it from the order
        if (!restaurantId && orderId) {
            console.log('RestaurantId missing, attempting to infer from Order:', orderId);
            const Order = require('../models/Order');
            if (mongoose.Types.ObjectId.isValid(orderId)) {
                const order = await Order.findById(orderId);
                if (order && order.restaurantId) {
                    restaurantId = order.restaurantId.toString();
                    console.log('Inferred RestaurantId:', restaurantId);
                }
            }
        }

        if (!restaurantId || !senderId) {
            console.log('Message validation failed: missing restaurantId or senderId');
            return res.status(400).json({ message: 'restaurantId and senderId are required' });
        }

        // Find the admin of this restaurant
        let restaurantAdmin = null;
        if (mongoose.Types.ObjectId.isValid(restaurantId)) {
            restaurantAdmin = await User.findOne({
                restaurantId: restaurantId,
                role: 'admin'
            });
        }

        const message = new Message({
            senderId,
            restaurantId,
            orderId: orderId || null,
            content,
            type: type || 'general',
            receiverId: restaurantAdmin ? restaurantAdmin._id : null
        });

        await message.save();
        res.status(201).json({ success: true, message });
    } catch (err) {
        console.error('Message send error:', err);
        res.status(500).json({ message: 'Internal server error: ' + err.message });
    }
});

// Get messages for a user
router.get('/user/:userId', protect, async (req, res) => {
    // Only allow user to see their own messages unless admin
    if (req.user._id.toString() !== req.params.userId && req.user.role === 'user') {
        return res.status(403).json({ success: false, message: 'Unauthorized' });
    }
    try {
        const messages = await Message.find({ senderId: req.params.userId }).sort({ createdAt: -1 });
        res.json(messages);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Get messages for a restaurant (admin or staff)
router.get('/restaurant/:restaurantId', protect, authorize('admin', 'staff', 'superadmin', 'delivery'), async (req, res) => {
    try {
        const messages = await Message.find({ restaurantId: req.params.restaurantId })
            .populate('senderId', 'username email')
            .populate('orderId')
            .sort({ createdAt: -1 });
        res.json(messages);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Reply to a message (Staff/Admin)
router.post('/reply', protect, authorize('admin', 'staff', 'superadmin', 'delivery'), async (req, res) => {
    try {
        console.log('Incoming Reply Data:', JSON.stringify(req.body, null, 2));
        const { restaurantId, receiverId, content, orderId } = req.body;

        if (!restaurantId || !receiverId || !content) {
            return res.status(400).json({ message: 'restaurantId, receiverId, and content are required' });
        }

        const message = new Message({
            senderId: req.user._id, // Staff/Admin sending the reply
            receiverId,
            restaurantId,
            orderId: orderId || null,
            content,
            type: 'reply'
        });

        await message.save();
        console.log('Reply saved successfully:', message._id);
        res.status(201).json({ success: true, message });
    } catch (err) {
        console.error('Message reply error:', err);
        res.status(500).json({ message: 'Internal server error: ' + err.message });
    }
});

module.exports = router;
