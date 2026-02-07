const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const User = require('../models/User');
const { protect, authorize } = require('../middleware/auth');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

// Login
router.post('/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const user = await User.findOne({ email });
        if (user && await user.comparePassword(password)) {
            res.json({ success: true, user });
        } else {
            res.status(401).json({ success: false, message: 'Invalid credentials' });
        }
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Register
router.post('/register', async (req, res) => {
    const { username, email, password } = req.body;
    console.log('Register request body:', req.body);
    try {
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            console.log('Registration failed: User already exists', email);
            return res.status(400).json({ success: false, message: 'User already exists' });
        }
        const user = new User({ username, email, password });
        await user.save();
        console.log('User registered successfully:', user._id);
        res.status(201).json({ success: true, user });
    } catch (err) {
        console.error('Registration error:', err.message);
        res.status(500).json({ message: err.message });
    }
});

// Seed admin
router.post('/seed-admin', protect, authorize('superadmin'), async (req, res) => {
    try {
        const admin = new User({
            username: "admin",
            email: "admin@example.com",
            password: "adminpassword",
            role: "superadmin"
        });
        await admin.save();
        res.status(201).json({ message: "SuperAdmin created", admin });
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Seed user
router.post('/seed', protect, authorize('superadmin'), async (req, res) => {
    try {
        await User.deleteMany();
        const user = new User({
            username: "testuser",
            email: "test@example.com",
            password: "password123"
        });
        await user.save();
        res.status(201).json(user);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Get profile
router.get('/profile/:id', protect, async (req, res) => {
    try {
        if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
            return res.status(400).json({ success: false, message: 'Invalid User ID format' });
        }
        const user = await User.findById(req.params.id);
        res.json(user);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Update profile
router.put('/profile/:id', protect, async (req, res) => {
    // Only allow user to update their own profile unless superadmin
    if (req.user._id.toString() !== req.params.id && req.user.role !== 'superadmin') {
        return res.status(403).json({ success: false, message: 'Unauthorized' });
    }
    try {
        if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
            return res.status(400).json({ success: false, message: 'Invalid User ID format' });
        }
        const { username, email, profileImage } = req.body;
        const user = await User.findByIdAndUpdate(
            req.params.id,
            { username, email, profileImage },
            { new: true }
        );
        res.json({ success: true, user });
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Upload image - with specific error handling for multer
router.post('/upload', protect, (req, res, next) => {
    upload.single('image')(req, res, (err) => {
        if (err instanceof multer.MulterError) {
            console.error('Multer Error:', err);
            return res.status(400).json({ success: false, message: `Upload error: ${err.message}` });
        } else if (err) {
            console.error('Unknown Upload Error:', err);
            return res.status(500).json({ success: false, message: err.message });
        }

        try {
            if (!req.file) {
                console.log('Upload failed: No file provided correctly in "image" field');
                return res.status(400).json({ success: false, message: 'No file uploaded' });
            }
            console.log('File uploaded successfully:', req.file.filename);
            const imageUrl = `http://localhost:5000/uploads/${req.file.filename}`;
            res.json({ success: true, imageUrl });
        } catch (innerErr) {
            console.error('Upload processing error:', innerErr);
            res.status(500).json({ message: innerErr.message });
        }
    });
});

module.exports = router;
