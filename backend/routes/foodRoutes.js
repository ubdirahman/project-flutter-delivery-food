const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const Food = require('../models/Food');
const { protect, authorize } = require('../middleware/auth');

// Get food items (with optional restaurant filtering)
router.get('/', async (req, res) => {
    try {
        const { restaurantId } = req.query;
        let query = {};
        if (restaurantId) {
            query.restaurantId = restaurantId;
        }
        const foods = await Food.find(query);
        res.json(foods);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Seed data route (Initial items)
router.post('/seed', protect, authorize('superadmin'), async (req, res) => {
    const initialFoods = [
        {
            name: "Bariis with Goat Meat",
            description: "Traditional Somali rice with tender seasoned goat meat and side salad.",
            price: 15,
            image: "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=400&q=80",
            category: "Bariis",
            isPopular: true
        },
        {
            name: "Baasto Salpicon",
            description: "Somali style pasta with spicy meat sauce and vegetables.",
            price: 12,
            image: "https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=400&q=80",
            category: "Baasto",
            isPopular: true
        },
        {
            name: "Sambuusa (Beef)",
            description: "Crispy pastry filled with spiced minced beef and onions.",
            price: 5,
            image: "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=400&q=80",
            category: "Appetizer",
            isPopular: true
        },
        {
            name: "Surbiyaan",
            description: "Traditional Somali lamb and rice dish with aromatic spices.",
            price: 18,
            image: "https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?auto=format&fit=crop&w=400&q=80",
            category: "Bariis",
            isPopular: false
        },
        {
            name: "Somali Tea",
            description: "Spiced tea with cardamom, cinnamon and milk.",
            price: 3,
            image: "https://images.unsplash.com/photo-1594631252845-29fc45862d6f?auto=format&fit=crop&w=400&q=80",
            category: "Drinks",
            isPopular: true
        }
    ];

    try {
        await Food.deleteMany();
        const savedFoods = await Food.insertMany(initialFoods);
        res.status(201).json(savedFoods);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Create a new food item
router.post('/', protect, authorize('admin', 'staff', 'superadmin'), async (req, res) => {
    // Determine restaurantId: 
    // Superadmin provides it in body, others use their own restaurantId
    let restaurantId = req.body.restaurantId;
    if (req.user.role !== 'superadmin' && req.user.restaurantId) {
        restaurantId = req.user.restaurantId;
    }

    if (!restaurantId && req.user.role !== 'superadmin') {
        return res.status(400).json({ success: false, message: 'You must be associated with a restaurant to add food.' });
    }

    const food = new Food({
        name: req.body.name,
        description: req.body.description,
        price: req.body.price,
        image: req.body.image,
        category: req.body.category,
        quantity: req.body.quantity || 0,
        restaurantId: restaurantId,
        isPopular: req.body.isPopular || false,
        size: req.body.size || ''
    });

    try {
        const newFood = await food.save();
        res.status(201).json(newFood);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Update a food item
router.put('/:id', protect, authorize('admin', 'superadmin'), async (req, res) => {
    console.log(`PUT food request for ID: ${req.params.id}`);
    console.log(`Update data:`, JSON.stringify(req.body, null, 2));
    try {
        if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
            return res.status(400).json({ success: false, message: 'Invalid Food ID format' });
        }
        const food = await Food.findById(req.params.id);
        if (food) {
            // Check ownership
            if (req.user.role !== 'superadmin' &&
                req.user.restaurantId &&
                food.restaurantId.toString() !== req.user.restaurantId.toString()) {
                return res.status(403).json({ success: false, message: 'Unauthorized: You can only update food for your own restaurant' });
            }
            food.name = req.body.name || food.name;
            food.description = req.body.description || food.description;
            food.price = req.body.price !== undefined ? req.body.price : food.price;
            food.image = req.body.image || food.image;
            food.category = req.body.category || food.category;
            food.quantity = req.body.quantity !== undefined ? req.body.quantity : food.quantity;
            food.isPopular = req.body.isPopular !== undefined ? req.body.isPopular : food.isPopular;
            food.size = req.body.size !== undefined ? req.body.size : food.size;
            if (req.body.restaurantId) {
                food.restaurantId = req.body.restaurantId;
            }

            const updatedFood = await food.save();
            console.log(`Food updated successfully: ${updatedFood._id}`);
            res.json(updatedFood);
        } else {
            console.log(`Food NOT FOUND for update: ${req.params.id}`);
            res.status(404).json({ message: 'Food not found' });
        }
    } catch (err) {
        console.error(`Food update error for ${req.params.id}:`, err);
        res.status(400).json({
            success: false,
            message: err.name === 'ValidationError' ? 'Validation Failed' : err.message,
            errors: err.errors
        });
    }
});

// Delete a food item
router.delete('/:id', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
            return res.status(400).json({ success: false, message: 'Invalid Food ID format' });
        }
        const food = await Food.findById(req.params.id);
        if (food) {
            // Check ownership
            if (req.user.role !== 'superadmin' &&
                req.user.restaurantId &&
                food.restaurantId.toString() !== req.user.restaurantId.toString()) {
                return res.status(403).json({ success: false, message: 'Unauthorized: You can only delete food for your own restaurant' });
            }

            await Food.findByIdAndDelete(req.params.id);
            res.json({ message: 'Food removed' });
        } else {
            res.status(404).json({ message: 'Food not found' });
        }
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
