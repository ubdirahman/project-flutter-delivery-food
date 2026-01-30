const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');

dotenv.config();

mongoose.connect(process.env.MONGODB_URI)
    .then(async () => {
        console.log('MongoDB Connected for Seeding Staff');

        // Remove existing staff if any (optional, or just create new)
        // await User.deleteMany({ role: 'staff' });

        const staffMember = new User({
            username: "staff_responder",
            email: "staff@example.com",
            password: "staffpassword",
            role: "staff"
        });

        await staffMember.save();
        console.log('Staff User Created:');
        console.log('Email: staff@example.com');
        console.log('Password: staffpassword');

        process.exit();
    })
    .catch(err => {
        console.error('Seeding Error:', err);
        process.exit(1);
    });
