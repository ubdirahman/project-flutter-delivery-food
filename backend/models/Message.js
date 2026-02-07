const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
    senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    receiverId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // Optional if targeting a restaurant admin
    restaurantId: { type: mongoose.Schema.Types.ObjectId, ref: 'Restaurant', required: true },
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
    content: { type: String, required: true },
    type: { type: String, enum: ['delay_report', 'feedback', 'general', 'reply'], default: 'general' },
    isRead: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model('Message', messageSchema);
