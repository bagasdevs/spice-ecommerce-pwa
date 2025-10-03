const axios = require('axios');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const BASE_URL = 'http://localhost:3001/api';

async function testLogin() {
  console.log('🧪 Testing Login Endpoint...\n');

  // Test credentials from seed data
  const testCredentials = [
    {
      email: 'admin@spice.com',
      password: 'password123',
      role: 'ADMIN'
    },
    {
      email: 'budi@petanirempah.com',
      password: 'password123',
      role: 'SELLER'
    },
    {
      email: 'dewi@buyer.com',
      password: 'password123',
      role: 'BUYER'
    }
  ];

  // Test health endpoint first
  try {
    console.log('1. Testing health endpoint...');
    const healthResponse = await axios.get(`${BASE_URL}/health`);
    console.log('✅ Health check:', healthResponse.data);
    console.log('');
  } catch (error) {
    console.log('❌ Health check failed:', error.message);
    console.log('Make sure backend is running on port 3001');
    return;
  }

  // Test login for each user
  for (const credential of testCredentials) {
    try {
      console.log(`2. Testing login for ${credential.role}: ${credential.email}`);

      const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
        email: credential.email,
        password: credential.password
      }, {
        headers: {
          'Content-Type': 'application/json'
        }
      });

      console.log('✅ Login successful!');
      console.log('📋 Response data:');
      console.log('   Message:', loginResponse.data.message);
      console.log('   User ID:', loginResponse.data.user?.id);
      console.log('   User Name:', loginResponse.data.user?.name);
      console.log('   User Role:', loginResponse.data.user?.role);
      console.log('   Token:', loginResponse.data.token ? '✅ Present' : '❌ Missing');
      console.log('   Token Type:', loginResponse.data.tokenType);
      console.log('');

      // Test protected endpoint with token
      if (loginResponse.data.token) {
        try {
          console.log('3. Testing protected endpoint /auth/me...');
          const profileResponse = await axios.get(`${BASE_URL}/auth/me`, {
            headers: {
              'Authorization': `Bearer ${loginResponse.data.token}`
            }
          });
          console.log('✅ Protected endpoint works!');
          console.log('📋 Profile data:', profileResponse.data.user?.name);
          console.log('');
        } catch (profileError) {
          console.log('❌ Protected endpoint failed:', profileError.response?.data?.message || profileError.message);
          console.log('');
        }
      }

    } catch (error) {
      console.log('❌ Login failed!');
      console.log('📋 Error details:');
      console.log('   Status:', error.response?.status);
      console.log('   Message:', error.response?.data?.message || error.message);
      console.log('   Error:', error.response?.data?.error);
      if (error.response?.data?.details) {
        console.log('   Details:', error.response.data.details);
      }
      console.log('');
    }
  }

  // Test invalid login
  try {
    console.log('4. Testing invalid login...');
    await axios.post(`${BASE_URL}/auth/login`, {
      email: 'wrong@email.com',
      password: 'wrongpassword'
    });
  } catch (error) {
    console.log('✅ Invalid login correctly rejected');
    console.log('📋 Error message:', error.response?.data?.message);
    console.log('');
  }

  console.log('🏁 Test completed!');
}

// Check if JWT_SECRET is set
if (!process.env.JWT_SECRET) {
  console.log('⚠️  WARNING: JWT_SECRET not found in environment variables');
  console.log('Make sure you have a .env file with JWT_SECRET set');
  console.log('');
}

// Run test
testLogin().catch(console.error);
