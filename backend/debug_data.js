const mongoose = require('mongoose');
const User = require('./models/User');
const Restaurant = require('./models/Restaurant');
require('dotenv').config();

const debugData = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        const users = await User.find({}, 'username email role');
        console.log('Existing Users:');
        users.forEach(u => console.log(`- ${u.username} (${u.email}) [${u.role}]`));

        const restaurants = await Restaurant.find({}, 'name');
        console.log('Existing Restaurants:');
        restaurants.forEach(r => console.log(`- ${r.name}`));

        process.exit(0);
    } catch (err) {
        console.error('Debug error:', err);
        process.exit(1);
    }
};

debugData();
