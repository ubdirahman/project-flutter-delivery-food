const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

const seedAdmin = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        // Delete existing superadmins to avoid conflict
        await User.deleteMany({ role: 'superadmin' });

        const superAdmin = new User({
            username: 'superadmin',
            email: 'admin@example.com',
            password: 'adminpassword',
            role: 'superadmin'
        });

        await superAdmin.save();
        console.log('SuperAdmin created successfully');

        process.exit(0);
    } catch (err) {
        console.error('Error seeding admin:', err);
        process.exit(1);
    }
};

seedAdmin();
