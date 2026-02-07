const http = require('http');

const superAdminCreds = { email: 'admin@example.com', password: 'adminpassword' };
const jaseeraId = '698616a3e96ae9435c824545'; // The existing restaurant to try and spy on

const httpRequest = (method, path, body, token, headers = {}) => {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: 5004, // Use a new temp port
            path,
            method,
            headers: {
                'Content-Type': 'application/json',
                ...headers
            }
        };

        if (token) {
            // Our auth middleware checks user-id header primarily in this dev setup
            // But let's send both just to be safe if we were using JWT
            options.headers['Authorization'] = `Bearer ${token}`;
        }

        if (headers['user-id']) {
            options.headers['user-id'] = headers['user-id'];
        }

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

async function runTest() {
    try {
        console.log('1. Login Superadmin...');
        const loginRes = await httpRequest('POST', '/api/users/login', superAdminCreds);
        if (loginRes.statusCode !== 200) throw new Error('Superadmin login failed');
        const superUserId = loginRes.body.user._id;

        console.log('2. Create Test Restaurant & Admin...');
        const newRestData = {
            name: `IsoTest-${Date.now()}`,
            address: 'Test Addr',
            phone: '1234567890',
            image: 'https://placehold.co/600x400',
            description: 'Test',
            adminEmail: `isotest-${Date.now()}@example.com`,
            adminPassword: 'password123',
            adminUsername: `iso_${Date.now()}`
        };
        const createRes = await httpRequest('POST', '/api/admin/restaurants', newRestData, null, { 'user-id': superUserId });
        if (createRes.statusCode !== 201) throw new Error('Create restaurant failed: ' + JSON.stringify(createRes.body));

        const testRestId = createRes.body.restaurant._id;
        console.log(`   Created Restaurant: ${testRestId}`);

        console.log('3. Login as New Test Admin...');
        const testAdminLoginRes = await httpRequest('POST', '/api/users/login', {
            email: newRestData.adminEmail,
            password: newRestData.adminPassword
        });
        const testAdminId = testAdminLoginRes.body.user._id;
        const testAdminRestId = testAdminLoginRes.body.user.restaurantId;
        console.log(`   Logged in as: ${testAdminId}, Linked to: ${testAdminRestId}`);

        if (testAdminRestId !== testRestId) throw new Error('Test Admin not linked to correct restaurant');

        console.log('4. Verify Isolation (Attempting to spy on Jaseera)...');

        // Test Params
        const headers = { 'user-id': testAdminId };
        const query = `?restaurantId=${jaseeraId}`;

        // A. Stats
        const statsRes = await httpRequest('GET', `/api/admin/stats${query}`, null, null, headers);
        console.log(`   GET /stats${query} -> ${statsRes.statusCode}`);
        if (statsRes.statusCode === 200) {
            // Should return data for OUR restaurant (TestRest), which should be empty/zero
            // If it returns Jaseera's data (which likely has orders), it failed.
            // But since TestRest is new, everything is 0. 
            // How do we know it didn't return Jaseera's?
            // Jaseera has data? Let's assume Jaseera has >0 orders.
            // If totalOrders == 0, it isolated correctly. 
            console.log(`   Stats TotalOrders: ${statsRes.body.totalOrders}`);
            if (statsRes.body.totalOrders !== 0) console.error('   FAIL: Saw data from other restaurant!');
            else console.log('   PASS: Stats isolated');
        } else {
            console.error('   FAIL: Stats request failed');
        }

        // B. Orders
        const ordersRes = await httpRequest('GET', `/api/admin/orders${query}`, null, null, headers);
        console.log(`   GET /orders${query} -> ${ordersRes.statusCode}`);
        if (ordersRes.statusCode === 200) {
            console.log(`   Orders Count: ${ordersRes.body.length}`);
            if (ordersRes.body.length !== 0) console.error('   FAIL: Saw orders from other restaurant!');
            else console.log('   PASS: Orders isolated');
        }

        // C. Performance
        const perfRes = await httpRequest('GET', `/api/admin/performance${query}`, null, null, headers);
        console.log(`   GET /performance${query} -> ${perfRes.statusCode}`);
        if (perfRes.statusCode === 200) {
            const hasRevenue = perfRes.body.some(d => d.revenue > 0);
            if (hasRevenue) console.error('   FAIL: Saw revenue from other restaurant!');
            else console.log('   PASS: Performance isolated');
        }

        // D. Staff
        const staffRes = await httpRequest('GET', `/api/admin/staff`, null, null, headers); // No query param needed, should force self
        console.log(`   GET /staff -> ${staffRes.statusCode}`);
        if (staffRes.statusCode === 200) {
            // Should only see staff from TestRest (which is 0 initially? Or just me? No, I am admin, staff endpoint returns role='staff')
            const alienStaff = staffRes.body.find(s => s.restaurantId !== testRestId);
            if (alienStaff) console.error('   FAIL: Saw staff from other restaurant!');
            else console.log('   PASS: Staff isolated');
        }

        console.log('5. Cleanup...');
        await httpRequest('DELETE', `/api/admin/restaurants/${testRestId}`, null, null, { 'user-id': superUserId });
        console.log('   Cleanup done.');

    } catch (e) {
        console.error('TEST ERROR:', e);
    }
}

runTest();
