const http = require('http');

// 1. Login as waa_admin
const loginData = JSON.stringify({
    email: 'waa_admin@example.com',
    password: 'password123'
});

const loginOptions = {
    hostname: 'localhost',
    port: 5002,
    path: '/api/users/login',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': loginData.length
    }
};

console.log('Attempting to login as waa_admin...');

const reqLogin = http.request(loginOptions, res => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
        if (res.statusCode !== 200) {
            console.error('Login failed:', res.statusCode, data);
            process.exit(1);
        }

        let responseBody;
        try {
            responseBody = JSON.parse(data);
        } catch (e) {
            console.error('Failed to parse login:', data);
            process.exit(1);
        }

        const user = responseBody.user;
        const userId = user._id; // For simple auth check if token missing
        const token = responseBody.token; // If JWT used

        console.log(`Login successful. User: ${user.email}, Restaurant: ${user.restaurantId}`);

        // 2. Try to update Jaseera's food (ID: 69861800e96ae9435c8245b5)
        updateOtherRestaurantFood(userId);

        // 3. Try to get Jaseera's stats
        getStatsForOtherRestaurant(userId);
    });
});

reqLogin.on('error', error => {
    console.error('Login connection error:', error);
});

reqLogin.write(loginData);
reqLogin.end();

function updateOtherRestaurantFood(userId) {
    const foodId = '69861800e96ae9435c8245b5'; // Belongs to Jaseera
    const updateData = JSON.stringify({
        price: 9999 // Malicious update
    });

    const options = {
        hostname: 'localhost',
        port: 5002,
        path: `/api/foods/${foodId}`,
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': updateData.length,
            'user-id': userId // Custom auth
        }
    };

    const req = http.request(options, res => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
            console.log(`Update Food (${foodId}) Status:`, res.statusCode);
            if (res.statusCode === 403) {
                console.log('PASS: Unauthorized update blocked.');
            } else {
                console.log('FAIL: Update allowed or unexpected status:', res.statusCode);
            }
        });
    });
    req.write(updateData);
    req.end();
}

function getStatsForOtherRestaurant(userId) {
    const otherRestaurantId = '698616a3e96ae9435c824545'; // Jaseera
    const options = {
        hostname: 'localhost',
        port: 5000,
        path: `/api/admin/stats?restaurantId=${otherRestaurantId}`,
        method: 'GET',
        headers: {
            'user-id': userId
        }
    };

    const req = http.request(options, res => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
            console.log(`Get Stats Status:`, res.statusCode);
            // We expect it to return stats for WAA (user's restaurant) despite requesting Jaseera
            // OR return Jaseera's stats IF logic is broken.
            // Since WAA is new, it likely has 0 orders. Jaseera might have orders.
            // If we see low numbers/zeros, it likely returned WAA stats (Good).
            console.log('Stats Response:', data);
        });
    });
    req.end();
}
