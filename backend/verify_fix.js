const http = require('http');

// 1. Login to get token
const loginData = JSON.stringify({
    email: 'admin@example.com',
    password: 'adminpassword'
});

const loginOptions = {
    hostname: 'localhost',
    port: 5001,
    path: '/api/users/login',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': loginData.length
    }
};

console.log('Attempting to login...');

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
            console.error('Failed to parse login response:', data);
            process.exit(1);
        }

        const { token, _id } = responseBody;
        if (!token) {
            // Some auth implementations return { token, user: { _id } } or similar
            // Adjust based on typical response if needed, but assuming { token, ... }
            if (responseBody.user && responseBody.token) {
                // ok
            } else {
                console.error('Token not found in response', responseBody);
            }
        }

        console.log('Login successful. Sending message...');
        sendMessage(token, responseBody.user ? responseBody.user._id : _id);
    });
});

reqLogin.on('error', error => {
    console.error('Login connection error:', error);
});

reqLogin.write(loginData);
reqLogin.end();

function sendMessage(token, senderId) {
    // 2. Send Message
    const messageData = JSON.stringify({
        senderId: senderId,
        restaurantId: '698616a3e96ae9435c824545', // Hardcoded from debug check
        content: 'Test message from verification script ' + new Date().toISOString(),
        type: 'general'
    });

    const messageOptions = {
        hostname: 'localhost',
        port: 5001,
        path: '/api/messages',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': messageData.length,
            'user-id': senderId // Custom auth middleware expects this
        }
    };

    const reqMessage = http.request(messageOptions, res => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
            console.log('Message Status:', res.statusCode);
            console.log('Message Response:', data);
            if (res.statusCode === 201) {
                console.log('VERIFICATION PASSED');
            } else {
                console.log('VERIFICATION FAILED');
            }
        });
    });

    reqMessage.on('error', error => {
        console.error('Message connection error:', error);
    });

    reqMessage.write(messageData);
    reqMessage.end();
}
