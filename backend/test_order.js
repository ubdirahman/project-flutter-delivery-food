const axios = require('axios');

async function testOrder() {
    const userId = '6985fe9549db152da44fb762'; // Superadmin from our previous tests
    const foodId = '69848278d9e228cea7e56565'; // From user error log
    const baseUrl = 'http://localhost:5000/api';

    const headers = {
        'user-id': userId,
        'Content-Type': 'application/json'
    };

    try {
        console.log('Testing Order Creation...');
        const orderData = {
            userId: userId,
            items: [
                {
                    foodId: foodId,
                    name: "Test Food",
                    price: 10,
                    quantity: 1
                }
            ],
            totalAmount: 15,
            paymentMethod: 'Cash on Delivery',
            address: 'Mogadishu'
        };

        const createRes = await axios.post(`${baseUrl}/orders`, orderData, { headers });
        console.log('Order Creation Success:', createRes.data.success);

        console.log('\nTesting Order Retrieval...');
        const fetchRes = await axios.get(`${baseUrl}/orders/user/${userId}`, { headers });
        console.log('Order Retrieval Success. Found:', fetchRes.data.length, 'orders');

    } catch (err) {
        console.error('Test Failed:', err.response ? err.response.data : err.message);
    }
}

testOrder();
