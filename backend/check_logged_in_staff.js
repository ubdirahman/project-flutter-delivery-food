const mongoose = require('mongoose');
const User = require('./models/User');
const Order = require('./models/Order');
const Restaurant = require('./models/Restaurant');
require('dotenv').config();

const checkLoggedInStaff = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB\n');

        // Find all staff users
        const staffUsers = await User.find({ role: 'staff' });
        console.log('=== ALL STAFF USERS ===');
        for (const staff of staffUsers) {
            console.log(`\nUsername: ${staff.username}`);
            console.log(`Email: ${staff.email}`);
            console.log(`ID: ${staff._id}`);
            console.log(`Restaurant ID: ${staff.restaurantId || 'NOT SET'}`);

            if (staff.restaurantId) {
                // Check if restaurant exists
                const restaurant = await Restaurant.findById(staff.restaurantId);
                if (restaurant) {
                    console.log(`Restaurant: ${restaurant.name}`);

                    // Check pending orders for this restaurant
                    const pendingOrders = await Order.find({
                        restaurantId: staff.restaurantId,
                        status: 'Pending'
                    });
                    console.log(`Pending orders for this restaurant: ${pendingOrders.length}`);
                } else {
                    console.log(`WARNING: Restaurant ID ${staff.restaurantId} does not exist!`);
                }
            }
        }

        // Check all pending orders
        console.log('\n\n=== ALL PENDING ORDERS ===');
        const allPending = await Order.find({ status: 'Pending' });
        console.log(`Total pending orders: ${allPending.length}`);
        for (const order of allPending) {
            console.log(`\nOrder ID: ${order._id}`);
            console.log(`Restaurant ID: ${order.restaurantId || 'NOT SET'}`);
            console.log(`Total: $${order.totalAmount}`);
            console.log(`Status: ${order.status}`);
        }

        process.exit(0);
    } catch (err) {
        console.error('Error:', err);
        process.exit(1);
    }
};

checkLoggedInStaff();
