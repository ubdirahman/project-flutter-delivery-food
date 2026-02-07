const mongoose = require('mongoose');
const User = require('./models/User');
const Order = require('./models/Order');
const Restaurant = require('./models/Restaurant');
require('dotenv').config();

const checkMahadStaff = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB\n');

        // Find mahad staff user
        const staff = await User.findOne({ email: 'mahad@gmail.com' });

        if (!staff) {
            console.log('ERROR: mahad@gmail.com not found');
            process.exit(1);
        }

        console.log('=== STAFF USER: mahad@gmail.com ===');
        console.log(`Username: ${staff.username}`);
        console.log(`Email: ${staff.email}`);
        console.log(`ID: ${staff._id}`);
        console.log(`Role: ${staff.role}`);
        console.log(`Restaurant ID: ${staff.restaurantId || 'NOT SET'}`);

        if (staff.restaurantId) {
            // Check restaurant
            const restaurant = await Restaurant.findById(staff.restaurantId);
            if (restaurant) {
                console.log(`\nRestaurant: ${restaurant.name}`);
                console.log(`Restaurant ID: ${restaurant._id}`);

                // Check pending orders for this restaurant
                const pendingOrders = await Order.find({
                    restaurantId: staff.restaurantId,
                    status: 'Pending'
                }).populate('userId', 'username email');

                console.log(`\n=== PENDING ORDERS FOR THIS RESTAURANT ===`);
                console.log(`Total: ${pendingOrders.length}\n`);

                pendingOrders.forEach((order, index) => {
                    console.log(`Order ${index + 1}:`);
                    console.log(`  ID: ${order._id}`);
                    console.log(`  Customer: ${order.userId?.username || 'Unknown'}`);
                    console.log(`  Total: $${order.totalAmount}`);
                    console.log(`  Status: ${order.status}`);
                    console.log('');
                });
            } else {
                console.log(`\nWARNING: Restaurant ${staff.restaurantId} not found!`);
            }
        } else {
            console.log('\nWARNING: Staff user has NO restaurantId!');
        }

        // Also check password (hashed)
        console.log('\n=== LOGIN INFO ===');
        console.log(`Email: mahad@gmail.com`);
        console.log(`Password: (check what password was used when creating this user)`);

        process.exit(0);
    } catch (err) {
        console.error('Error:', err);
        process.exit(1);
    }
};

checkMahadStaff();
