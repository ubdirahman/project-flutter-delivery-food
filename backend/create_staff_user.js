const mongoose = require('mongoose');
const User = require('./models/User');
const Restaurant = require('./models/Restaurant');
require('dotenv').config();

const createOrUpdateStaffUser = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB\n');

        // Get first restaurant
        const restaurant = await Restaurant.findOne({});
        if (!restaurant) {
            console.log('ERROR: No restaurants found. Please create a restaurant first.');
            process.exit(1);
        }

        console.log(`Found restaurant: ${restaurant.name} (ID: ${restaurant._id})\n`);

        // Check if staff@example.com exists
        let staff = await User.findOne({ email: 'staff@example.com' });

        if (staff) {
            console.log('Updating existing staff@example.com user...');
            staff.restaurantId = restaurant._id;
            staff.password = 'staffpassword'; // Will be hashed by pre-save hook
            await staff.save();
            console.log('Updated staff@example.com with restaurantId');
        } else {
            console.log('Creating new staff@example.com user...');
            staff = new User({
                username: 'staff_user',
                email: 'staff@example.com',
                password: 'staffpassword',
                role: 'staff',
                restaurantId: restaurant._id
            });
            await staff.save();
            console.log('Created new staff@example.com user');
        }

        console.log('\n=== STAFF USER DETAILS ===');
        console.log(`Email: staff@example.com`);
        console.log(`Password: staffpassword`);
        console.log(`Username: ${staff.username}`);
        console.log(`ID: ${staff._id}`);
        console.log(`Restaurant ID: ${staff.restaurantId}`);
        console.log(`Restaurant Name: ${restaurant.name}`);

        console.log('\n✅ Staff user ready! You can now login with:');
        console.log('   Email: staff@example.com');
        console.log('   Password: staffpassword');

        process.exit(0);
    } catch (err) {
        console.error('Error:', err);
        process.exit(1);
    }
};

createOrUpdateStaffUser();
