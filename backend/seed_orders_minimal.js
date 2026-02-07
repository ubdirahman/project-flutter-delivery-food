const mongoose = require('mongoose');
const Order = require('./models/Order');
const Restaurant = require('./models/Restaurant');
const User = require('./models/User');
const Food = require('./models/Food');
require('dotenv').config();

async function seedOrders() {
    try {
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/food_delivery');
        console.log('Connected to DB');

        const restaurant = await Restaurant.findOne({ name: 'zamzam' });
        if (!restaurant) {
            console.log('Restaurant "zamzam" not found');
            process.exit(1);
        }

        const user = await User.findOne({ role: 'user' }) || await User.findOne({ email: 'ali@gmail.com' });
        if (!user) {
            console.log('No user found to assign orders to');
            process.exit(1);
        }

        const foods = await Food.find({ restaurantId: restaurant._id });
        if (foods.length === 0) {
            console.log('No food found for zamzam, please add food first');
            // Create dummy food
            const dummyFood = new Food({
                name: 'Test Pizza',
                price: 15.00,
                category: 'Pizza',
                restaurantId: restaurant._id,
                description: 'Tasty pizza'
            });
            await dummyFood.save();
            foods.push(dummyFood);
        }

        console.log('Deleting existing orders...');
        await Order.deleteMany();

        console.log('Creating test orders...');
        const orders = [
            {
                userId: user._id,
                restaurantId: restaurant._id,
                totalAmount: 45.00,
                status: 'Delivered',
                items: [{ foodId: foods[0]._id, name: foods[0].name, price: 15, quantity: 3 }]
            },
            {
                userId: user._id,
                restaurantId: restaurant._id,
                totalAmount: 30.00,
                status: 'Pending',
                items: [{ foodId: foods[0]._id, name: foods[0].name, price: 15, quantity: 2 }]
            },
            {
                userId: user._id,
                restaurantId: restaurant._id,
                totalAmount: 15.00,
                status: 'Accepted',
                items: [{ foodId: foods[0]._id, name: foods[0].name, price: 15, quantity: 1 }]
            }
        ];

        await Order.insertMany(orders);
        console.log('Successfully seeded 3 orders for zamzam');

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

seedOrders();
