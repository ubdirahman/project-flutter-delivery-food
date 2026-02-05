const mongoose = require('mongoose');

const restaurantSchema = new mongoose.Schema({
    name: { type: String, required: [true, 'Restaurant name is required'], trim: true },
    address: { type: String, required: [true, 'Address is required'] },
    phone: { type: String, required: [true, 'Phone number is required'] },
    image: { type: String, required: [true, 'Image URL is required'] },
    rating: { type: Number, default: 0, min: 0, max: 5 },
    description: { type: String, default: '' }
}, { timestamps: true });

module.exports = mongoose.model('Restaurant', restaurantSchema);
