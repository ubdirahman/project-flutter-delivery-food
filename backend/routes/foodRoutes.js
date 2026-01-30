const express = require('express');
const router = express.Router();
const Food = require('../models/Food');

// Get all food items
router.get('/', async (req, res) => {
    try {
        const foods = await Food.find();
        res.json(foods);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Seed data route (Initial items)
router.post('/seed', async (req, res) => {
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
router.post('/', async (req, res) => {
    const food = new Food({
        name: req.body.name,
        description: req.body.description,
        price: req.body.price,
        image: req.body.image,
        category: req.body.category,
        isPopular: req.body.isPopular || false
    });

    try {
        const newFood = await food.save();
        res.status(201).json(newFood);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Update a food item
router.put('/:id', async (req, res) => {
    try {
        const food = await Food.findById(req.params.id);
        if (food) {
            food.name = req.body.name || food.name;
            food.description = req.body.description || food.description;
            food.price = req.body.price || food.price;
            food.image = req.body.image || food.image;
            food.category = req.body.category || food.category;
            food.isPopular = req.body.isPopular !== undefined ? req.body.isPopular : food.isPopular;

            const updatedFood = await food.save();
            res.json(updatedFood);
        } else {
            res.status(404).json({ message: 'Food not found' });
        }
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Delete a food item
router.delete('/:id', async (req, res) => {
    try {
        const food = await Food.findByIdAndDelete(req.params.id);
        if (food) {
            res.json({ message: 'Food removed' });
        } else {
            res.status(404).json({ message: 'Food not found' });
        }
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
