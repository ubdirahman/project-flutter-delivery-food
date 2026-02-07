const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

const checkUser = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        const user = await User.findOne({ email: 'admin@example.com' });
        if (!user) {
            console.log('User admin@example.com not found');
        } else {
            console.log('User found:', user.username);
            console.log('Role:', user.role);
            console.log('Password length:', user.password.length);
            console.log('Is password hashed? (starts with $2):', user.password.startsWith('$2'));

            const isMatch = await user.comparePassword('adminpassword');
            console.log('Does "adminpassword" match?', isMatch);
        }

        process.exit(0);
    } catch (err) {
        console.error('Error checking user:', err);
        process.exit(1);
    }
};

checkUser();
