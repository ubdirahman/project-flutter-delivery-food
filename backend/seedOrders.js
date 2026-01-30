const mongoose = require('mongoose');
const User = require('./models/User');
const Order = require('./models/Order');
const Food = require('./models/Food');
require('dotenv').config();

const seedSampleOrders = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/food_delivery');
        console.log('Connected to MongoDB');

        // 1. Get or create a sample user
        let user = await User.findOne({ role: 'user' });
        if (!user) {
            console.log('No user found. Creating sample user...');
            user = new User({
                username: 'sample_customer',
                email: 'customer@example.com',
                password: 'password123',
                role: 'user'
            });
            await user.save();
        }

        // 2. Get or create some foods
        let foods = await Food.find();
        if (foods.length === 0) {
            console.log('No foods found. Creating sample foods...');
            const sampleFood = new Food({
                name: 'Sample Burger',
                price: 15.99,
                category: 'Burgers',
                description: 'A delicious sample burger',
                image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd'
            });
            await sampleFood.save();
            foods = [sampleFood];
        }

        console.log('Seeding sample orders for the last 7 days...');

        // 3. Delete existing sample orders if needed (optional)
        // await Order.deleteMany({ status: 'Delivered' }); 

        const statuses = ['Delivered', 'Pending', 'Preparing', 'Ready', 'Accepted'];

        for (let i = 0; i < 20; i++) {
            const daysAgo = Math.floor(Math.random() * 7);
            const date = new Date();
            date.setDate(date.getDate() - daysAgo);

            const sampleItems = [];
            const itemCount = Math.floor(Math.random() * 3) + 1;
            let totalAmount = 0;

            for (let j = 0; j < itemCount; j++) {
                const food = foods[Math.floor(Math.random() * foods.length)];
                sampleItems.push({
                    name: food.name,
                    quantity: Math.floor(Math.random() * 2) + 1,
                    price: food.price,
                    image: food.image
                });
                totalAmount += food.price * sampleItems[j].quantity;
            }

            const order = new Order({
                userId: user._id,
                items: sampleItems,
                totalAmount: totalAmount,
                status: statuses[Math.floor(Math.random() * statuses.length)],
                paymentMethod: 'Cash on Delivery',
                paymentStatus: 'Paid',
                deliveryAddress: 'Main St ' + (i + 100),
                createdAt: date
            });

            await order.save();
        }

        console.log('Successfully seeded 20 sample orders!');
        process.exit();
    } catch (err) {
        console.error('Error seeding orders:', err);
        process.exit(1);
    }
};

seedSampleOrders();
