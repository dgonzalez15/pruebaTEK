// Test simple para verificar endpoints
const baseUrl = 'http://localhost:8000/api';

// Función para hacer login y obtener token
async function login() {
    try {
        const response = await fetch(`${baseUrl}/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                email: 'anita@peluqueria.com',
                password: 'password123'
            })
        });
        
        const data = await response.json();
        console.log('🔐 Login response:', data);
        return data.data?.access_token;
    } catch (error) {
        console.error('❌ Login error:', error);
        return null;
    }
}

// Función para probar endpoint de clientes
async function testClients(token) {
    try {
        const response = await fetch(`${baseUrl}/clients?is_active=true`, {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Accept': 'application/json'
            }
        });
        
        const data = await response.json();
        console.log('👥 Clients response:', data);
        console.log(`📊 Found ${data.data?.data?.length || 0} active clients`);
        return data.data?.data || [];
    } catch (error) {
        console.error('❌ Clients error:', error);
        return [];
    }
}

// Función para probar endpoint de estilistas
async function testStylists(token) {
    try {
        const response = await fetch(`${baseUrl}/stylists`, {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Accept': 'application/json'
            }
        });
        
        const data = await response.json();
        console.log('👨‍💼 Stylists response:', data);
        console.log(`📊 Found ${data.data?.length || 0} stylists`);
        return data.data || [];
    } catch (error) {
        console.error('❌ Stylists error:', error);
        return [];
    }
}

// Función principal de test
async function runTests() {
    console.log('🚀 Starting endpoint tests...');
    
    const token = await login();
    if (!token) {
        console.error('❌ Could not get token, stopping tests');
        return;
    }
    
    console.log('✅ Token obtained successfully');
    
    const clients = await testClients(token);
    const stylists = await testStylists(token);
    
    console.log('\n📋 Test Summary:');
    console.log(`- Token: ${token ? '✅' : '❌'}`);
    console.log(`- Clients: ${clients.length > 0 ? '✅' : '❌'} (${clients.length} found)`);
    console.log(`- Stylists: ${stylists.length > 0 ? '✅' : '❌'} (${stylists.length} found)`);
    
    if (clients.length > 0) {
        console.log('\n👥 Sample client:', clients[0]);
    }
    
    if (stylists.length > 0) {
        console.log('\n👨‍💼 Sample stylist:', stylists[0]);
    }
}

// Ejecutar tests
runTests();