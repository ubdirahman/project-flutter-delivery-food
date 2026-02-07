const mongoose = require('mongoose');
const Order = require('./models/Order');
const Restaurant = require('./models/Restaurant');
const User = require('./models/User');
require('dotenv').config();

async function checkData() {
    try {
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/food_delivery');
        console.log('Connected to DB');

        const orderCount = await Order.countDocuments();
        console.log('Total Orders in DB:', orderCount);

        const restaurants = await Restaurant.find({}, 'name _id');
        console.log('\nRestaurants:');
        for (const r of restaurants) {
            const count = await Order.countDocuments({ restaurantId: r._id });
            console.log(`- ${r.name} (${r._id}): ${count} orders`);
        }

        const staff = await User.find({ role: 'staff' }, 'username email restaurantId');
        console.log('\nStaff Members:');
        for (const s of staff) {
            console.log(`- ${s.username} (${s.email}): Assigned to ${s.restaurantId}`);
        }

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

checkData();
