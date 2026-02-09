const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    items: [{
        foodId: { type: mongoose.Schema.Types.ObjectId, ref: 'Food' },
        name: String,
        description: String,
        price: Number,
        quantity: Number,
        image: String,
        size: String
    }],
    restaurantId: { type: mongoose.Schema.Types.ObjectId, ref: 'Restaurant' },
    totalAmount: { type: Number, required: true },
    deliveryFees: { type: Number, default: 5 },
    status: {
        type: String,
        enum: ['Pending', 'Accepted', 'Preparing', 'Ready', 'Handed to Delivery', 'Delivered', 'Cancelled', 'Rejected'],
        default: 'Pending'
    },
    staffId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    deliveryId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    rejectionReason: { type: String, default: '' },
    paymentMethod: { type: String, enum: ['Cash on Delivery', 'Credit Card', 'Debit Card', 'Mobile Money', 'EVC-PLUS', 'SAHAL'], default: 'Cash on Delivery' },
    paymentStatus: { type: String, enum: ['Pending', 'Paid', 'Failed'], default: 'Pending' },
    address: { type: String, default: 'Mogadishu, Somalia' },
    deliveryRating: { type: Number, min: 1, max: 5 },
    deliveryReview: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema);
