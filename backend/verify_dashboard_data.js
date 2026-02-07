const http = require('http');

// Use an ID that likely exists or was created in previous steps, or utilize the one from the user's error message (which was likely valid but empty)
// 698616a3e96ae9435c824545 (Jaseera)
// 69860c69bb2654a6ee2fa1f4 (The one that caused the dropdown error, likely deleted or invalid, but let's try Jaseera)
const restaurantId = '698616a3e96ae9435c824545';
const superAdminCreds = { email: 'admin@example.com', password: 'adminpassword' };

const httpRequest = (method, path, body, token, headers = {}) => {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: 5000,
            path,
            method,
            headers: {
                'Content-Type': 'application/json',
                ...headers
            }
        };

        if (token) {
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
        if (loginRes.statusCode !== 200) throw new Error('Login failed');
        const token = loginRes.body.token; // If using JWT
        const userId = loginRes.body.user._id;

        console.log(`2. Fetch Dashboard Stats for Restaurant ID: ${restaurantId}...`);
        // Simulating what the dashboard calls
        const statsRes = await httpRequest('GET', `/api/admin/stats?restaurantId=${restaurantId}`, null, token, { 'user-id': userId });

        console.log('--- DASHBOARD DATA FROM DB ---');
        console.log(JSON.stringify(statsRes.body, null, 2));
        console.log('------------------------------');

        if (statsRes.statusCode === 200) {
            const keys = ['totalOrders', 'totalRevenue', 'ongoingOrders', 'totalStaff', 'totalDelivery'];
            const missing = keys.filter(k => statsRes.body[k] === undefined);
            if (missing.length > 0) {
                console.error('FAIL: Missing keys in response:', missing);
            } else {
                console.log('PASS: Data structure is correct for Dashboard display.');
            }
        } else {
            console.error('FAIL: Could not fetch stats:', statsRes.statusCode);
        }

    } catch (e) {
        console.error('ERROR:', e);
    }
}

runTest();
