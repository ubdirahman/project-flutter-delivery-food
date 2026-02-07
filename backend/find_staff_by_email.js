const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

const findStaffByEmail = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB\n');

        // Find staff user by the email used in the app
        const staff = await User.findOne({ email: 'staff@example.com' });

        if (!staff) {
            console.log('ERROR: No staff user found with email staff@example.com');
            console.log('Available staff users:');
            const allStaff = await User.find({ role: 'staff' });
            allStaff.forEach(s => console.log(`  - ${s.email}`));
        } else {
            console.log('Found staff user:');
            console.log(`  Username: ${staff.username}`);
            console.log(`  Email: ${staff.email}`);
            console.log(`  ID: ${staff._id}`);
            console.log(`  Role: ${staff.role}`);
            console.log(`  Restaurant ID: ${staff.restaurantId || 'NOT SET'}`);
        }

        process.exit(0);
    } catch (err) {
        console.error('Error:', err);
        process.exit(1);
    }
};

findStaffByEmail();
