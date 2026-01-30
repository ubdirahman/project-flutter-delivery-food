const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const User = require('../models/User');
const Food = require('../models/Food');
const Restaurant = require('../models/Restaurant');

// Get Dashboard Stats
router.get('/stats', async (req, res) => {
    try {
        const totalOrders = await Order.countDocuments();
        const totalCustomers = await User.countDocuments({ role: 'user' });

        // Calculate total revenue from non-cancelled orders
        const totalRevenueResult = await Order.aggregate([
            { $match: { status: { $ne: 'Cancelled' } } },
            { $group: { _id: null, total: { $sum: "$totalAmount" } } }
        ]);
        const totalRevenue = totalRevenueResult.length > 0 ? totalRevenueResult[0].total : 0;

        const ongoingOrders = await Order.countDocuments({ status: { $in: ['Pending', 'Preparing', 'On the way'] } });

        // Calculate total items sold from non-cancelled orders
        const totalItemsSoldResult = await Order.aggregate([
            { $match: { status: { $ne: 'Cancelled' } } },
            { $unwind: "$items" },
            { $group: { _id: null, total: { $sum: "$items.quantity" } } }
        ]);
        const totalItemsSold = totalItemsSoldResult.length > 0 ? totalItemsSoldResult[0].total : 0;

        // Calculate Average Order Value
        const avgOrderValue = totalOrders > 0 ? (totalRevenue / totalOrders).toFixed(2) : 0;

        res.json({
            totalOrders,
            totalCustomers,
            totalRevenue,
            ongoingOrders,
            totalRestaurants: await Restaurant.countDocuments(),
            totalStaff: await User.countDocuments({ role: 'staff' }),
            totalItemsSold,
            avgOrderValue
        });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Get Performance Data (last 7 days)
router.get('/performance', async (req, res) => {
    try {
        const last7Days = [];
        for (let i = 6; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            date.setHours(0, 0, 0, 0);
            const nextDate = new Date(date);
            nextDate.setDate(nextDate.getDate() + 1);

            const count = await Order.countDocuments({
                createdAt: { $gte: date, $lt: nextDate }
            });
            const revenue = await Order.aggregate([
                { $match: { createdAt: { $gte: date, $lt: nextDate }, status: { $ne: 'Cancelled' } } },
                { $group: { _id: null, total: { $sum: "$totalAmount" } } }
            ]);

            last7Days.push({
                date: date.toLocaleDateString('en-US', { weekday: 'short' }),
                orders: count,
                revenue: revenue.length > 0 ? revenue[0].total : 0
            });
        }
        res.json(last7Days);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Get All Orders (for admin)
router.get('/orders', async (req, res) => {
    try {
        const orders = await Order.find().populate('userId').sort({ createdAt: -1 });
        res.json(orders);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Admin CRUD for Restaurants
router.get('/restaurants', async (req, res) => {
    try {
        const restaurants = await Restaurant.find();
        res.json(restaurants);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

router.post('/restaurants', async (req, res) => {
    const restaurant = new Restaurant(req.body);
    try {
        const newRestaurant = await restaurant.save();
        res.status(201).json(newRestaurant);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// --- Staff Management ---

// Create new staff
router.post('/staff', async (req, res) => {
    try {
        const { username, email, password, phoneNumber } = req.body;

        if (!username || !email || !password) {
            return res.status(400).json({ success: false, message: 'Username, email and password are required' });
        }

        const existingEmail = await User.findOne({ email });
        if (existingEmail) {
            return res.status(400).json({ success: false, message: 'Email already exists' });
        }

        const existingUsername = await User.findOne({ username });
        if (existingUsername) {
            return res.status(400).json({ success: false, message: 'Username already taken' });
        }

        const staff = new User({
            username,
            email,
            password,
            phoneNumber: phoneNumber || '',
            role: 'staff'
        });
        await staff.save();
        res.status(201).json({ success: true, staff });
    } catch (err) {
        console.error('Staff creation error:', err);
        res.status(500).json({ success: false, message: 'Internal server error', error: err.message });
    }
});

// Get all staff members
router.get('/staff', async (req, res) => {
    try {
        const staffMembers = await User.find({ role: 'staff' });
        res.json(staffMembers);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Delete staff member
router.delete('/staff/:id', async (req, res) => {
    try {
        const user = await User.findByIdAndDelete(req.params.id);
        if (!user) return res.status(404).json({ message: 'Staff member not found' });
        res.json({ success: true, message: 'Staff member deleted' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
