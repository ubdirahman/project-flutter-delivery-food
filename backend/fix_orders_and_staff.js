const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config();

const Order = require('./models/Order');
const User = require('./models/User');
const Restaurant = require('./models/Restaurant');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/somali_food_db';

async function fixData() {
    try {
        await mongoose.connect(MONGODB_URI);
        console.log('Connected to MongoDB');

        // 1. Get a default restaurant
        const defaultRestaurant = await Restaurant.findOne();
        if (!defaultRestaurant) {
            console.error('No restaurants found! Please create a restaurant first.');
            process.exit(1);
        }
        console.log(`Using default restaurant: ${defaultRestaurant.name} (${defaultRestaurant._id})`);

        // 2. Fix Orders with missing restaurantId
        // We find all orders and filter manually or use a safer query
        const allOrders = await Order.find();
        const ordersToFix = allOrders.filter(order =>
            !order.restaurantId ||
            order.restaurantId.toString() === 'null' ||
            order.restaurantId.toString() === 'undefined'
        );
        console.log(`Found ${ordersToFix.length} orders to fix`);

        for (const order of ordersToFix) {
            order.restaurantId = defaultRestaurant._id;
            await order.save();
        }
        console.log('Orders fixed successfully');

        // 3. Fix Staff/Admin Users with missing restaurantId
        const staffToFix = await User.find({
            role: { $in: ['staff', 'admin', 'delivery'] },
            $or: [
                { restaurantId: { $exists: false } },
                { restaurantId: null }
            ]
        });
        console.log(`Found ${staffToFix.length} staff/admin users to fix`);

        for (const staff of staffToFix) {
            staff.restaurantId = defaultRestaurant._id;
            await staff.save();
        }
        console.log('Staff users fixed successfully');

        console.log('Data fix complete!');
        process.exit(0);
    } catch (err) {
        console.error('Error fixing data:', err);
        process.exit(1);
    }
}

fixData();
