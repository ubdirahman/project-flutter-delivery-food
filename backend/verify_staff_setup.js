const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');
const Order = require('./models/Order');

dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/somali_food_db';

async function verifyStaffSetup() {
    try {
        await mongoose.connect(MONGODB_URI);
        console.log('✅ Connected to MongoDB\n');

        // 1. Find all staff users
        console.log('=== STAFF USERS ===');
        const staffUsers = await User.find({ role: 'staff' }).select('username email role restaurantId');

        if (staffUsers.length === 0) {
            console.log('❌ No staff users found in database');
        } else {
            staffUsers.forEach(staff => {
                console.log(`\n📋 Staff: ${staff.username} (${staff.email})`);
                console.log(`   ID: ${staff._id}`);
                console.log(`   Restaurant ID: ${staff.restaurantId || '❌ NOT SET'}`);
            });
        }

        // 2. Find all pending orders
        console.log('\n\n=== PENDING ORDERS ===');
        const pendingOrders = await Order.find({ status: 'Pending' })
            .populate('userId', 'username email')
            .populate('restaurantId', 'name');

        if (pendingOrders.length === 0) {
            console.log('❌ No pending orders found');
        } else {
            console.log(`Found ${pendingOrders.length} pending orders:\n`);
            pendingOrders.forEach(order => {
                console.log(`📦 Order ID: ${order._id}`);
                console.log(`   Customer: ${order.userId?.username || 'Unknown'}`);
                console.log(`   Restaurant: ${order.restaurantId?.name || order.restaurantId || 'Unknown'}`);
                console.log(`   Total: $${order.totalAmount}`);
                console.log(`   Status: ${order.status}`);
                console.log('');
            });
        }

        // 3. Check if staff restaurantId matches any pending orders
        console.log('\n=== MATCHING ANALYSIS ===');
        for (const staff of staffUsers) {
            if (!staff.restaurantId) {
                console.log(`⚠️  ${staff.username} has NO restaurantId - cannot see any orders`);
                continue;
            }

            const matchingOrders = pendingOrders.filter(order =>
                order.restaurantId && order.restaurantId._id.toString() === staff.restaurantId.toString()
            );

            if (matchingOrders.length > 0) {
                console.log(`✅ ${staff.username} should see ${matchingOrders.length} pending order(s)`);
            } else {
                console.log(`⚠️  ${staff.username} has restaurantId ${staff.restaurantId} but NO pending orders for this restaurant`);
            }
        }

        console.log('\n=== RECOMMENDATIONS ===');
        if (staffUsers.length === 0) {
            console.log('1. Create a staff user using the admin interface');
        } else if (staffUsers.some(s => !s.restaurantId)) {
            console.log('1. Assign restaurantId to staff users who are missing it');
        }

        if (pendingOrders.length === 0) {
            console.log('2. Create test orders with status "Pending"');
        }

    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await mongoose.connection.close();
        console.log('\n✅ Connection closed');
    }
}

verifyStaffSetup();
