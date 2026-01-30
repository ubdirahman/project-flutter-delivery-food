const mongoose = require('mongoose');

const restaurantSchema = new mongoose.Schema({
    name: { type: String, required: true },
    address: { type: String, required: true },
    phone: { type: String, required: true },
    image: { type: String, required: true },
    rating: { type: Number, default: 0 },
    description: { type: String, default: '' }
}, { timestamps: true });

module.exports = mongoose.model('Restaurant', restaurantSchema);
