const mongoose = require('mongoose');
const User = require('./models/User');
const Order = require('./models/Order');
const Restaurant = require('./models/Restaurant');
require('dotenv').config();

const checkStaffOrders = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB\n');

        // Find staff users
        const staffUsers = await User.find({ role: 'staff' });
        console.log('=== STAFF USERS ===');
        for (const staff of staffUsers) {
            console.log(`Staff: ${staff.username}`);
            console.log(`  ID: ${staff._id}`);
            console.log(`  Restaurant ID: ${staff.restaurantId || 'NOT SET'}\n`);
        }

        // Find all restaurants
        const restaurants = await Restaurant.find({});
        console.log('\n=== RESTAURANTS ===');
        restaurants.forEach(r => {
            console.log(`${r.name} - ID: ${r._id}`);
        });

        // Find pending orders
        const pendingOrders = await Order.find({ status: 'Pending' });
        console.log(`\n=== PENDING ORDERS (${pendingOrders.length}) ===`);
        for (const order of pendingOrders) {
            console.log(`Order ${order._id}`);
            console.log(`  Restaurant ID: ${order.restaurantId}`);
            console.log(`  Total: $${order.totalAmount}`);
            console.log(`  Status: ${order.status}\n`);
        }

        process.exit(0);
    } catch (err) {
        console.error('Error:', err);
        process.exit(1);
    }
};

checkStaffOrders();
