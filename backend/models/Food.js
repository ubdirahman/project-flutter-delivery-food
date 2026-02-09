const mongoose = require('mongoose');

const foodSchema = new mongoose.Schema({
    name: { type: String, required: [true, 'Food name is required'], trim: true },
    description: { type: String, required: [true, 'Description is required'] },
    price: { type: Number, required: [true, 'Price is required'], min: [0, 'Price cannot be negative'] },
    image: { type: String, required: [true, 'Image URL is required'] },
    category: { type: String, required: [true, 'Category is required'] },
    restaurantId: { type: mongoose.Schema.Types.ObjectId, ref: 'Restaurant', required: [true, 'Restaurant ID is required'] },
    rating: { type: Number, default: 0, min: 0, max: 5 },
    quantity: { type: Number, default: 0, min: [0, 'Quantity cannot be negative'] },
    isPopular: { type: Boolean, default: false },
    size: { type: String, trim: true }
}, { timestamps: true });

module.exports = mongoose.model('Food', foodSchema);
