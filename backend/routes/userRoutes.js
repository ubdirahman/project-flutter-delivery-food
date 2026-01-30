const express = require('express');
const router = express.Router();
const User = require('../models/User');
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
        if (user && user.password === password) {
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
    try {
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ success: false, message: 'User already exists' });
        }
        const user = new User({ username, email, password });
        await user.save();
        res.status(201).json({ success: true, user });
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Seed admin
router.post('/seed-admin', async (req, res) => {
    try {
        const admin = new User({
            username: "admin",
            email: "admin@example.com",
            password: "adminpassword",
            role: "admin"
        });
        await admin.save();
        res.status(201).json({ message: "Admin created", admin });
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Seed user
router.post('/seed', async (req, res) => {
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
router.get('/profile/:id', async (req, res) => {
    try {
        const user = await User.findById(req.params.id);
        res.json(user);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Update profile
router.put('/profile/:id', async (req, res) => {
    try {
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

// Upload image
router.post('/upload', upload.single('image'), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ success: false, message: 'No file uploaded' });
        }
        const imageUrl = `http://localhost:5000/uploads/${req.file.filename}`;
        res.json({ success: true, imageUrl });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
