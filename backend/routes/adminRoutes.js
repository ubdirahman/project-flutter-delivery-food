const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const Order = require('../models/Order');
const User = require('../models/User');
const Food = require('../models/Food');
const Restaurant = require('../models/Restaurant');
const { protect, authorize } = require('../middleware/auth');

// Get Dashboard Stats
router.get('/stats', protect, authorize('admin', 'superadmin', 'staff', 'delivery'), async (req, res) => {
    try {
        const { restaurantId } = req.query;
        let matchQuery = {};

        // Enforce restaurantId for non-superadmins (Admins/Staff)
        if (req.user.role !== 'superadmin' && req.user.restaurantId) {
            matchQuery.restaurantId = req.user.restaurantId;
        } else if (restaurantId) {
            // Superadmin can query specific restaurant
            matchQuery.restaurantId = new mongoose.Types.ObjectId(restaurantId);
        }

        const totalOrders = await Order.countDocuments(matchQuery);

        let totalCustomers;
        if (matchQuery.restaurantId) {
            // Count unique customers who ordered from this restaurant
            const uniqueCustomers = await Order.distinct('userId', matchQuery);
            totalCustomers = uniqueCustomers.length;
        } else {
            totalCustomers = await User.countDocuments({ role: 'user' });
        }

        // Calculate total revenue from non-cancelled orders
        const totalRevenueResult = await Order.aggregate([
            { $match: { ...matchQuery, status: { $ne: 'Cancelled' } } },
            { $group: { _id: null, total: { $sum: "$totalAmount" } } }
        ]);
        const totalRevenue = totalRevenueResult.length > 0 ? totalRevenueResult[0].total : 0;

        const ongoingOrders = await Order.countDocuments({
            ...matchQuery,
            status: { $in: ['Pending', 'Preparing', 'On the way'] }
        });

        // Calculate total items sold from non-cancelled orders
        const totalItemsSoldResult = await Order.aggregate([
            { $match: { ...matchQuery, status: { $ne: 'Cancelled' } } },
            { $unwind: "$items" },
            { $group: { _id: null, total: { $sum: "$items.quantity" } } }
        ]);
        const totalItemsSold = totalItemsSoldResult.length > 0 ? totalItemsSoldResult[0].total : 0;

        // Calculate Average Order Value
        const avgOrderValue = totalOrders > 0 ? (totalRevenue / totalOrders).toFixed(2) : 0;

        // Get Top Selling Items
        const topSellingItems = await Order.aggregate([
            { $match: { ...matchQuery, status: { $ne: 'Cancelled' } } },
            { $unwind: "$items" },
            {
                $group: {
                    _id: "$items.name",
                    name: { $first: "$items.name" },
                    totalOrders: { $sum: 1 },
                    totalQuantity: { $sum: "$items.quantity" },
                    totalRevenue: { $sum: { $multiply: ["$items.price", "$items.quantity"] } },
                    image: { $first: "$items.image" }
                }
            },
            { $sort: { totalQuantity: -1 } },
            { $limit: 5 }
        ]);

        res.json({
            totalOrders,
            totalCustomers,
            totalRevenue,
            ongoingOrders,
            totalRestaurants: await Restaurant.countDocuments(),
            totalStaff: await User.countDocuments({
                role: 'staff',
                ...(restaurantId && mongoose.Types.ObjectId.isValid(restaurantId) ? { restaurantId: new mongoose.Types.ObjectId(restaurantId) } : {})
            }),
            totalItemsSold,
            totalDelivery: await Order.countDocuments({ ...matchQuery, status: 'Delivered' }),
            avgOrderValue,
            topSellingItems
        });
    } catch (err) {
        console.error('Admin Stats Error:', err);
        res.status(500).json({ message: err.message });
    }
});

// Get Top Restaurants (Superadmin only)
router.get('/top-restaurants', protect, authorize('superadmin'), async (req, res) => {
    try {
        const topRestaurants = await Order.aggregate([
            { $match: { status: { $ne: 'Cancelled' } } },
            {
                $group: {
                    _id: "$restaurantId",
                    totalOrders: { $sum: 1 },
                    totalRevenue: { $sum: "$totalAmount" }
                }
            },
            {
                $lookup: {
                    from: "restaurants",
                    localField: "_id",
                    foreignField: "_id",
                    as: "restaurantInfo"
                }
            },
            { $unwind: "$restaurantInfo" },
            {
                $project: {
                    _id: 1,
                    name: "$restaurantInfo.name",
                    image: "$restaurantInfo.image",
                    totalOrders: 1,
                    totalRevenue: 1
                }
            },
            { $sort: { totalOrders: -1 } },
            { $limit: 5 }
        ]);
        res.json(topRestaurants);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Get Performance Data (last 7 days)
router.get('/performance', protect, authorize('admin', 'superadmin', 'staff', 'delivery'), async (req, res) => {
    try {
        const { restaurantId } = req.query;
        let baseMatch = {};

        // Enforce restaurantId for non-superadmins
        if (req.user.role !== 'superadmin' && req.user.restaurantId) {
            baseMatch.restaurantId = req.user.restaurantId;
        } else if (restaurantId) {
            if (mongoose.Types.ObjectId.isValid(restaurantId)) {
                baseMatch.restaurantId = new mongoose.Types.ObjectId(restaurantId);
            } else {
                console.warn(`Invalid restaurantId provided for performance: ${restaurantId}`);
            }
        }

        const last7Days = [];
        for (let i = 6; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            date.setHours(0, 0, 0, 0);
            const nextDate = new Date(date);
            nextDate.setDate(nextDate.getDate() + 1);

            const dateMatch = {
                createdAt: { $gte: date, $lt: nextDate }
            };

            const count = await Order.countDocuments({
                ...baseMatch,
                ...dateMatch
            });

            const revenue = await Order.aggregate([
                { $match: { ...baseMatch, ...dateMatch, status: { $ne: 'Cancelled' } } },
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
        console.error('Admin Performance Error:', err);
        res.status(500).json({ message: err.message });
    }
});

// Get All Orders (for admin)
router.get('/orders', protect, authorize('admin', 'superadmin', 'staff', 'delivery'), async (req, res) => {
    try {
        const { restaurantId } = req.query;
        let query = {};

        // Enforce restaurantId for non-superadmins
        if (req.user.role !== 'superadmin' && req.user.restaurantId) {
            query.restaurantId = req.user.restaurantId;
        } else if (restaurantId) {
            query.restaurantId = restaurantId;
        }
        const orders = await Order.find(query).populate('userId').sort({ createdAt: -1 });
        res.json(orders);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Admin CRUD for Restaurants
// GET is public for customers
router.get('/restaurants', async (req, res) => {
    try {
        const restaurants = await Restaurant.find();
        res.json(restaurants);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

router.get('/my-restaurant', protect, authorize('admin', 'staff', 'delivery'), async (req, res) => {
    try {
        if (!req.user.restaurantId) {
            return res.status(400).json({ success: false, message: 'User is not assigned to a restaurant' });
        }
        const restaurant = await Restaurant.findById(req.user.restaurantId);
        if (!restaurant) {
            return res.status(404).json({ success: false, message: 'Restaurant not found' });
        }
        res.json(restaurant);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

router.get('/restaurants-with-stats', protect, authorize('superadmin'), async (req, res) => {
    try {
        const restaurants = await Restaurant.find();
        const restaurantsWithStats = await Promise.all(restaurants.map(async (rest) => {
            const totalOrders = await Order.countDocuments({ restaurantId: rest._id });
            const totalRevenueResult = await Order.aggregate([
                { $match: { restaurantId: rest._id, status: { $ne: 'Cancelled' } } },
                { $group: { _id: null, total: { $sum: "$totalAmount" } } }
            ]);
            const totalRevenue = totalRevenueResult.length > 0 ? totalRevenueResult[0].total : 0;

            const totalCustomers = (await Order.distinct('userId', { restaurantId: rest._id })).length;
            const totalStaff = await User.countDocuments({ role: 'staff', restaurantId: rest._id });

            return {
                ...rest.toObject(),
                stats: {
                    totalOrders,
                    totalRevenue,
                    totalCustomers,
                    totalStaff
                }
            };
        }));
        res.json(restaurantsWithStats);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

router.post('/restaurants', protect, authorize('superadmin'), async (req, res) => {
    const { name, address, phone, image, description, adminEmail, adminPassword, adminUsername } = req.body;

    try {
        // 1. PRE-CHECK: If admin details provided, check if user already exists
        if (adminEmail) {
            const existingUser = await User.findOne({ email: adminEmail });
            if (existingUser) {
                return res.status(400).json({
                    success: false,
                    message: `Admin user with email ${adminEmail} already exists. Please use a unique email.`
                });
            }
        }

        const username = adminUsername || `${name.replace(/\s+/g, '').toLowerCase()}_admin`;
        if (username) {
            const existingUsername = await User.findOne({ username });
            if (existingUsername) {
                return res.status(400).json({
                    success: false,
                    message: `Admin username ${username} already exists. Please provide a custom username.`
                });
            }
        }

        // 2. Create the restaurant
        console.log('Attempting to create restaurant with data:', { name, address, phone, image, description });
        const restaurant = new Restaurant({ name, address, phone, image, description });
        const newRestaurant = await restaurant.save();
        console.log('Restaurant created successfully:', newRestaurant._id);

        // 3. Create the restaurant admin user
        if (adminEmail && adminPassword) {
            try {
                const adminUser = new User({
                    username,
                    email: adminEmail,
                    password: adminPassword,
                    role: 'admin',
                    restaurantId: newRestaurant._id
                });
                await adminUser.save();
            } catch (userErr) {
                // IMPORTANT: If user creation fails, we should ideally delete the created restaurant
                // to maintain consistency (poor man's transaction)
                await Restaurant.findByIdAndDelete(newRestaurant._id);
                throw userErr;
            }
        }

        res.status(201).json({ success: true, restaurant: newRestaurant });
    } catch (err) {
        console.error('Restaurant creation error:', err);
        res.status(400).json({
            success: false,
            message: err.message,
            errors: err.errors
        });
    }
});

router.put('/restaurants/:id', protect, authorize('superadmin'), async (req, res) => {
    console.log(`PUT request received for restaurant ID: ${req.params.id}`);
    try {
        const restaurant = await Restaurant.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );
        if (!restaurant) {
            console.log(`Restaurant NOT FOUND for update: ${req.params.id}`);
            return res.status(404).json({ success: false, message: 'Restaurant not found' });
        }
        res.json({ success: true, restaurant });
    } catch (err) {
        console.error('Restaurant update error:', err);
        // Better error message for validation or other issues
        res.status(400).json({
            success: false,
            message: err.name === 'ValidationError' ? 'Validation Failed' : err.message,
            errors: err.errors
        });
    }
});

router.delete('/restaurants/:id', protect, authorize('superadmin'), async (req, res) => {
    console.log(`DELETE request received for restaurant ID: ${req.params.id}`);
    try {
        const restaurant = await Restaurant.findByIdAndDelete(req.params.id);
        if (!restaurant) {
            console.log(`Restaurant NOT FOUND for ID: ${req.params.id}`);
            return res.status(404).json({ success: false, message: 'Restaurant not found' });
        }
        console.log(`Restaurant deleted successfully: ${req.params.id}`);

        // Also delete associated users/food/etc if needed? 
        // For now just the restaurant as requested.

        res.json({ success: true, message: 'Restaurant deleted successfully' });
    } catch (err) {
        console.error('Restaurant deletion error:', err);
        res.status(500).json({ success: false, message: err.message });
    }
});

// --- Staff Management ---

// Create new staff
router.post('/staff', protect, authorize('admin', 'superadmin'), async (req, res) => {
    console.log('Received staff creation request:', req.body);
    try {
        const { username, email, password, phoneNumber } = req.body;

        if (!username || !email || !password) {
            console.log('Missing fields:', { username: !!username, email: !!email, password: !!password });
            return res.status(400).json({ success: false, message: 'Username, email and password are required' });
        }

        const existingEmail = await User.findOne({ email });
        if (existingEmail) {
            console.log('Email already exists:', email);
            return res.status(400).json({ success: false, message: 'Email already exists' });
        }

        const existingUsername = await User.findOne({ username });
        if (existingUsername) {
            console.log('Username already taken:', username);
            return res.status(400).json({ success: false, message: 'Username already taken' });
        }

        const staff = new User({
            username,
            email,
            password,
            phoneNumber: phoneNumber || '',
            role: req.body.role === 'delivery' ? 'delivery' : 'staff',
            restaurantId: req.body.restaurantId // Link to restaurant
        });
        await staff.save();
        console.log('Staff created successfully:', staff._id);
        res.status(201).json({ success: true, staff });
    } catch (err) {
        console.error('Staff creation error:', err);
        res.status(500).json({ success: false, message: 'Internal server error', error: err.message });
    }
});

// Get all staff members
router.get('/staff', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        let query = { role: { $in: ['staff', 'delivery'] } };
        // Enforce restaurantId for non-superadmins
        if (req.user.role !== 'superadmin' && req.user.restaurantId) {
            query.restaurantId = req.user.restaurantId;
        }

        const staffMembers = await User.find(query);
        res.json(staffMembers);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Delete staff member
router.delete('/staff/:id', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        const user = await User.findByIdAndDelete(req.params.id);
        if (!user) return res.status(404).json({ message: 'Staff member not found' });
        res.json({ success: true, message: 'Staff member deleted' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// No fallback here for now
module.exports = router;
