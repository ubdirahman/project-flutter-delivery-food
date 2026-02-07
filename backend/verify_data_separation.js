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
let token = '';
let superAdminId = '';

async function runTest() {
    try {
        console.log('1. Login Superadmin...');
        const loginRes = await httpRequest('POST', '/api/users/login', superAdmin);
        if (loginRes.statusCode !== 200) throw new Error('Superadmin login failed');
        token = loginRes.body.token;
        superAdminId = loginRes.body.user._id;

        // --- Create Restaurant A ---
        console.log('2. Creating Restaurant A & Admin A...');
        const restA = {
            name: `RestA_${Date.now()}`,
            address: 'Somalia',
            phone: '123',
            image: 'http://img.com',
            description: 'Desc',
            adminEmail: `adminA_${Date.now()}@test.com`,
            adminPassword: 'password123',
            adminUsername: `adminA_${Date.now()}`
        };
        const restARes = await httpRequest('POST', '/api/admin/restaurants', restA, token, { 'user-id': superAdminId });
        if (restARes.statusCode !== 201) {
            console.log('RestA Creation Failed:', JSON.stringify(restARes.body, null, 2));
            throw new Error('RestA creation failed');
        }
        const restAId = restARes.body.restaurant._id;
        console.log(`   Restaurant A ID: ${restAId}`);

        // Login as Admin A
        const loginARes = await httpRequest('POST', '/api/users/login', { email: restA.adminEmail, password: restA.adminPassword });
        const tokenA = loginARes.body.token;
        const userAId = loginARes.body.user._id;

        // --- Create Restaurant B ---
        console.log('3. Creating Restaurant B & Admin B...');
        const restB = {
            name: `RestB_${Date.now()}`,
            address: 'Somalia',
            phone: '456',
            image: 'http://img.com',
            description: 'Desc',
            adminEmail: `adminB_${Date.now()}@test.com`,
            adminPassword: 'password123',
            adminUsername: `adminB_${Date.now()}`
        };
        const restBRes = await httpRequest('POST', '/api/admin/restaurants', restB, token, { 'user-id': superAdminId });
        if (restBRes.statusCode !== 201) throw new Error('RestB creation failed');
        const restBId = restBRes.body.restaurant._id;
        console.log(`   Restaurant B ID: ${restBId}`);

        // Login as Admin B
        const loginBRes = await httpRequest('POST', '/api/users/login', { email: restB.adminEmail, password: restB.adminPassword });
        const tokenB = loginBRes.body.token;
        const userBId = loginBRes.body.user._id;

        // --- Create Food for Restaurant A ---
        console.log('3.5 Creating Food for Restaurant A...');
        const foodA = {
            name: 'Food A',
            description: 'Desc',
            price: 10,
            image: 'http://img.com',
            category: 'Main',
            restaurantId: restAId,
            quantity: 100
        };
        const foodARes = await httpRequest('POST', '/api/foods', foodA, token, { 'user-id': userAId });
        if (restARes.statusCode !== 201 && foodARes.statusCode !== 201) {
            console.log('Food creation failed:', foodARes.body);
            throw new Error('Food creation failed');
        }
        const foodAId = foodARes.body._id;
        console.log(`   Food A ID: ${foodAId}`);

        // --- Place Order for Restaurant A ---
        console.log('4. Placing Order for Restaurant A...');
        const orderData = {
            userId: userAId, // Admin A acts as customer for simplicity
            restaurantId: restAId,
            items: [{ name: 'Food A', price: 10, quantity: 2, image: 'img', foodId: foodAId }],
            totalAmount: 20,
            status: 'Pending',
            address: 'Loc A'
        };
        // Using public order endpoint (assuming no auth or user auth, let's use Admin A token as user)
        const orderRes = await httpRequest('POST', '/api/orders', orderData, tokenA, { 'user-id': userAId });
        if (orderRes.statusCode !== 201) {
            console.log('Order creation failed:', orderRes.body);
            throw new Error('Order creation failed');
        }
        console.log('   Order placed successfully for Rest A.');

        // --- Verify stats ---
        console.log('5. Verifying Dashboards...');

        // Check Admin A Stats
        const statsA = await httpRequest('GET', '/api/admin/stats', null, tokenA, { 'user-id': userAId });
        console.log(`   Admin A Stats (Expect 1 order): ${statsA.body.totalOrders}`);

        // Check Admin B Stats
        const statsB = await httpRequest('GET', '/api/admin/stats', null, tokenB, { 'user-id': userBId });
        console.log(`   Admin B Stats (Expect 0 orders): ${statsB.body.totalOrders}`);

        if (statsA.body.totalOrders === 1 && statsB.body.totalOrders === 0) {
            console.log('PASS: Data is correctly separated!');
        } else {
            console.error('FAIL: Data leakage or missing data.');
        }

    } catch (e) {
        console.error('ERROR:', e);
    }
}

runTest();
