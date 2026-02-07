const mongoose = require('mongoose');
const User = require('./models/User');
const Restaurant = require('./models/Restaurant');
const Food = require('./models/Food');
require('dotenv').config();

const debugIsolationData = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        const restaurants = await Restaurant.find({}, '_id name');
        console.log('\n--- Restaurants ---');
        restaurants.forEach(r => console.log(`ID: ${r._id}, Name: ${r.name}`));

        const users = await User.find({ role: { $in: ['admin', 'superadmin'] } }, '_id username email role restaurantId');
        console.log('\n--- Admins ---');
        users.forEach(u => console.log(`ID: ${u._id}, Email: ${u.email}, Role: ${u.role}, RestaurantID: ${u.restaurantId}`));

        const foods = await Food.find({}, '_id name restaurantId').limit(5);
        console.log('\n--- Foods (Sample) ---');
        foods.forEach(f => console.log(`ID: ${f._id}, Name: ${f.name}, RestaurantID: ${f.restaurantId}`));

        process.exit(0);
    } catch (err) {
        console.error('Error:', err);
        process.exit(1);
    }
};

debugIsolationData();
