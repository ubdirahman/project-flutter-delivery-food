const http = require('http');

// Helper to make HTTP requests
const httpRequest = (method, path, body, token, headers = {}) => {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: 5000,
            path,
            method,
            headers: {
                'Content-Type': 'application/json',
                ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
                ...headers
            }
        };

        const req = http.request(options, res => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    const parsed = data ? JSON.parse(data) : {};
                    resolve({ statusCode: res.statusCode, body: parsed });
                } catch (e) {
                    resolve({ statusCode: res.statusCode, body: data });
                }
            });
        });

        req.on('error', reject);
        if (body) req.write(JSON.stringify(body));
        req.end();
    });
};

const superAdmin = { email: 'admin@example.com', password: 'adminpassword' };

async function runTest() {
    try {
        console.log('1. Login Superadmin...');
        const loginRes = await httpRequest('POST', '/api/users/login', superAdmin);
        if (loginRes.statusCode !== 200) {
            console.log('Login failed:', loginRes.body);
            throw new Error('Superadmin login failed');
        }
        const token = loginRes.body.token;
        const superAdminId = loginRes.body.user._id;

        // --- Fetch All Restaurants ---
        console.log('2. Fetching All Restaurants...');
        const restsRes = await httpRequest('GET', '/api/admin/restaurants', null, null); // Public endpoint
        if (restsRes.statusCode !== 200) {
            console.log('Fetch restaurants failed:', restsRes.body);
            throw new Error('Fetch restaurants failed');
        }

        const restaurants = restsRes.body;
        console.log(`   Found ${restaurants.length} restaurants.`);

        console.log('\n--- Restaurant Stats Summary ---\n');
        console.log('Name'.padEnd(30) + ' | ' + 'Total Orders'.padEnd(15) + ' | ' + 'Revenue'.padEnd(15));
        console.log('-'.repeat(66));

        for (const rest of restaurants) {
            const statsRes = await httpRequest(
                'GET',
                `/api/admin/stats?restaurantId=${rest._id}`,
                null,
                token,
                { 'user-id': superAdminId }
            );

            if (statsRes.statusCode === 200) {
                const stats = statsRes.body;
                console.log(
                    rest.name.padEnd(30) + ' | ' +
                    stats.totalOrders.toString().padEnd(15) + ' | ' +
                    `$${stats.totalRevenue}`.padEnd(15)
                );
            } else {
                console.log(rest.name.padEnd(30) + ' | ' + 'ERROR fetching stats');
            }
        }
        console.log('-'.repeat(66));

    } catch (e) {
        console.error('ERROR:', e);
    }
}

runTest();
