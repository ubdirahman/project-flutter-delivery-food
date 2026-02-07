const User = require('../models/User');

const protect = async (req, res, next) => {
    // In a real app, we would check for a JWT token here.
    // Since the frontend is currently sending userId or we might want a simpler check first:
    // We will expect a 'user-id' header or similar for now if we haven't implemented JWT.
    // For now, let's assume the request body or query might contain the userId for simplicity in this specific project setup,
    // although JWT is much better.

    // HOWEVER, the user's current frontend doesn't seem to send a token.
    // Let's implement a simple check for now based on the userId passed in query or body.

    const userId = req.headers['user-id'] || (req.query && req.query.userId) || (req.body && req.body.userId);

    if (!userId) {
        return res.status(401).json({ success: false, message: 'Not authorized, no user ID' });
    }

    try {
        const user = await User.findById(userId);
        if (!user) {
            console.log(`Auth Failed: User with ID ${userId} not found`);
            return res.status(401).json({ success: false, message: 'User not found' });
        }
        console.log(`Auth Success: User ${user.email} (${user.role}) accessing ${req.method} ${req.originalUrl}`);
        req.user = user;
        next();
    } catch (err) {
        console.error('Auth protect error:', err);
        res.status(401).json({ success: false, message: 'Not authorized' });
    }
};

const authorize = (...roles) => {
    return (req, res, next) => {
        if (!req.user) {
            console.log(`Auth Failed: No user found in request during authorization check`);
            return res.status(401).json({ success: false, message: 'Not authorized' });
        }
        if (!roles.includes(req.user.role)) {
            console.log(`Auth Failed: User ${req.user.email} (${req.user.role}) is not one of [${roles}]`);
            return res.status(403).json({
                success: false,
                message: `User role ${req.user.role} is not authorized to access this route`
            });
        }
        next();
    };
};

module.exports = { protect, authorize };
