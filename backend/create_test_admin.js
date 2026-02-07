const mongoose = require('mongoose');
const User = require('./models/User');
const Restaurant = require('./models/Restaurant');
require('dotenv').config();

const createTestAdmin = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);

        const waaRestaurant = await Restaurant.findOne({ name: 'waa' });
        if (!waaRestaurant) {
            console.log('Restaurant "waa" not found');
            process.exit(1);
        }

        // Delete if exists
        await User.deleteOne({ email: 'waa_admin@example.com' });

        const admin = new User({
            username: 'waa_admin',
            email: 'waa_admin@example.com',
            password: 'password123',
            role: 'admin',
            restaurantId: waaRestaurant._id
        });

        await admin.save();
        console.log('Test Admin created:', admin.email);
        console.log('Restaurant ID:', waaRestaurant._id);

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

createTestAdmin();
