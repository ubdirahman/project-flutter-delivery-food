const mongoose = require('mongoose');
const User = require('./models/User');
const Order = require('./models/Order');
const Restaurant = require('./models/Restaurant');
require('dotenv').config();

const fixStaffRestaurantAssignment = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB\n');

        // Get the first restaurant
        const restaurant = await Restaurant.findOne({});
        if (!restaurant) {
            console.log('ERROR: No restaurants found in database!');
            console.log('Please create a restaurant first using the admin interface.');
            process.exit(1);
        }

        console.log(`Found restaurant: ${restaurant.name} (ID: ${restaurant._id})\n`);

        // Update all staff users to have this restaurantId
        const staffUpdate = await User.updateMany(
            { role: 'staff', restaurantId: { $exists: false } },
            { $set: { restaurantId: restaurant._id } }
        );
        console.log(`Updated ${staffUpdate.modifiedCount} staff user(s) with restaurantId`);

        // Update all orders to have this restaurantId
        const orderUpdate = await Order.updateMany(
            { restaurantId: { $exists: false } },
            { $set: { restaurantId: restaurant._id } }
        );
        console.log(`Updated ${orderUpdate.modifiedCount} order(s) with restaurantId`);

        // Show final state
        console.log('\n=== VERIFICATION ===');
        const staffUsers = await User.find({ role: 'staff' });
        console.log(`\nStaff users (${staffUsers.length}):`);
        staffUsers.forEach(staff => {
            console.log(`  - ${staff.username}: restaurantId = ${staff.restaurantId || 'NOT SET'}`);
        });

        const pendingOrders = await Order.find({ status: 'Pending' });
        console.log(`\nPending orders (${pendingOrders.length}):`);
        pendingOrders.forEach(order => {
            console.log(`  - Order ${order._id}: restaurantId = ${order.restaurantId || 'NOT SET'}`);
        });

        console.log('\n✅ Fix completed successfully!');
        console.log('Staff users should now be able to see pending orders.');

        process.exit(0);
    } catch (err) {
        console.error('Error:', err);
        process.exit(1);
    }
};

fixStaffRestaurantAssignment();
