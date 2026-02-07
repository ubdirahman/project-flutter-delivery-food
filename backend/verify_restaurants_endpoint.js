const http = require('http');

const httpRequest = (method, path, body, token) => {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: 5000,
            path,
            method,
            headers: {
                'Content-Type': 'application/json',
                ...(token ? { 'Authorization': `Bearer ${token}` } : {})
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
        if (loginRes.statusCode !== 200) throw new Error('Login failed');
        const token = loginRes.body.token;

        console.log('2. Fetching Restaurants with Stats...');
        // Pass userId in a way that headers can pick it up or modify httpRequest to accept headers
        const res = await httpRequest('GET', '/api/admin/restaurants-with-stats', { userId: loginRes.body.user._id }, token);

        if (res.statusCode === 200) {
            console.log('SUCCESS: Retrieved data.');

            console.log('\n--- Restaurant Stats (Backend Data) ---\n');
            console.log('Name'.padEnd(30) + ' | ' + 'Orders'.padEnd(10) + ' | ' + 'Revenue'.padEnd(15));
            console.log('-'.repeat(60));

            res.body.forEach(rest => {
                const name = rest.name || 'Unknown';
                const orders = rest.stats?.totalOrders ?? 0;
                const revenue = rest.stats?.totalRevenue ?? 0;

                console.log(
                    name.padEnd(30) + ' | ' +
                    orders.toString().padEnd(10) + ' | ' +
                    `$${revenue}`.padEnd(15)
                );
            });
            console.log('-'.repeat(60));
            console.log(`\nTotal Restaurants found: ${res.body.length}`);
        } else {
            console.log('FAIL: Endpoint returned', res.statusCode, res.body);
        }

    } catch (e) {
        console.error('ERROR:', e);
    }
}

runTest();
