const mongoose = require('mongoose');
const User = require('./models/User');
const Restaurant = require('./models/Restaurant');
require('dotenv').config();

const getIds = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        const user = await User.findOne({ username: 'farxiyo' });
        const restaurant = await Restaurant.findOne({ name: 'jaseera' });

        if (user && restaurant) {
            console.log(`USER_ID: ${user._id}`);
            console.log(`RESTAURANT_ID: ${restaurant._id}`);
        } else {
            console.log('Could not find user or restaurant');
        }

        process.exit(0);
    } catch (err) {
        console.error('Error:', err);
        process.exit(1);
    }
};

getIds();
