const mongoose = require('mongoose');
const Restaurant = require('./models/Restaurant');
require('dotenv').config();

const sampleRestaurants = [
    {
        name: 'Xamar Restaurant',
        address: 'Bakara Market, Mogadishu',
        phone: '+252 61 234 5678',
        image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500',
        rating: 4.5,
        description: 'Traditional Somali cuisine with modern twist'
    },
    {
        name: 'Jazeera Palace',
        address: 'Lido Beach, Mogadishu',
        phone: '+252 61 345 6789',
        image: 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=500',
        rating: 4.8,
        description: 'Seafood and international dishes with ocean view'
    },
    {
        name: 'Banadir Restaurant',
        address: 'KM4, Mogadishu',
        phone: '+252 61 456 7890',
        image: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=500',
        rating: 4.3,
        description: 'Family-friendly restaurant serving authentic Somali food'
    },
    {
        name: 'Blue Sky Cafe',
        address: 'Hamarweyne, Mogadishu',
        phone: '+252 61 567 8901',
        image: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
        rating: 4.6,
        description: 'Cozy cafe with great coffee and pastries'
    },
    {
        name: 'Safari Restaurant',
        address: 'Hodan District, Mogadishu',
        phone: '+252 61 678 9012',
        image: 'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=500',
        rating: 4.4,
        description: 'Grilled meats and traditional Somali dishes'
    }
];

async function seedRestaurants() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('MongoDB Connected');

        // Clear existing restaurants
        await Restaurant.deleteMany({});
        console.log('Cleared existing restaurants');

        // Insert sample restaurants
        await Restaurant.insertMany(sampleRestaurants);
        console.log('Sample restaurants added successfully!');

        mongoose.connection.close();
        console.log('Database connection closed');
    } catch (error) {
        console.error('Error seeding restaurants:', error);
        process.exit(1);
    }
}

seedRestaurants();
