const API_BASE = 'http://localhost:8000/api';

// Auth helpers
function getToken() {
    return localStorage.getItem('auth_token');
}

function setToken(token) {
    localStorage.setItem('auth_token', token);
}

function clearToken() {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user_name');
    localStorage.removeItem('user_role');
}

function isLoggedIn() {
    return !!getToken();
}

function getUserName() {
    return localStorage.getItem('user_name') || '';
}

function getUserRole() {
    return localStorage.getItem('user_role') || '';
}

// API request helper
async function apiRequest(path, options = {}) {
    const token = getToken();
    const headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
        ...options.headers,
    };

    const response = await fetch(`${API_BASE}${path}`, {
        ...options,
        headers,
    });

    if (!response.ok) {
        const error = await response.json().catch(() => ({}));
        throw new Error(error.message || `API Error: ${response.statusCode}`);
    }

    return response.json();
}

// Login
async function login(email, password) {
    const data = await apiRequest('/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
    });
    setToken(data.token);
    localStorage.setItem('user_name', data.user.name);
    localStorage.setItem('user_role', data.user.role);
    return data;
}

// Register
async function register(name, email, password) {
    const data = await apiRequest('/register', {
        method: 'POST',
        body: JSON.stringify({ name, email, password, password_confirmation: password }),
    });
    setToken(data.token);
    localStorage.setItem('user_name', data.user.name);
    localStorage.setItem('user_role', data.user.role);
    return data;
}

// Logout
async function logout() {
    try {
        await apiRequest('/logout', { method: 'POST' });
    } catch (_) {}
    clearToken();
}

// Cart API
async function getCart() {
    if (!isLoggedIn()) return [];
    try {
        const data = await apiRequest('/cart');
        return data.cart || [];
    } catch (_) {
        return [];
    }
}

async function addToCartApi(productId, color, size, quantity = 1) {
    if (!isLoggedIn()) throw new Error('Login required');
    return apiRequest('/cart', {
        method: 'POST',
        body: JSON.stringify({ product_id: productId, color, size, quantity }),
    });
}

async function updateCartItem(cartItemId, quantity) {
    if (!isLoggedIn()) throw new Error('Login required');
    return apiRequest(`/cart/${cartItemId}`, {
        method: 'PUT',
        body: JSON.stringify({ quantity }),
    });
}

async function removeCartItem(cartItemId) {
    if (!isLoggedIn()) throw new Error('Login required');
    return apiRequest(`/cart/${cartItemId}`, { method: 'DELETE' });
}

async function clearCart() {
    if (!isLoggedIn()) throw new Error('Login required');
    return apiRequest('/cart', { method: 'DELETE' });
}

// Update cart badge on all pages
async function updateCartBadge() {
    const badge = document.getElementById('cartBadge');
    if (!badge) return;

    if (!isLoggedIn()) {
        badge.classList.add('hidden');
        return;
    }

    try {
        const cart = await getCart();
        const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
        badge.innerText = totalItems;
        if (totalItems === 0) {
            badge.classList.add('hidden');
        } else {
            badge.classList.remove('hidden');
        }
    } catch (_) {
        badge.classList.add('hidden');
    }
}

// Update header auth state
function updateHeaderAuth() {
    const signInLink = document.querySelector('a[href="login.html"]');
    if (!signInLink) return;

    if (isLoggedIn()) {
        signInLink.textContent = getUserName() || 'Profile';
        signInLink.href = 'user_dashboard.html';
    } else {
        signInLink.textContent = 'Sign In';
        signInLink.href = 'login.html';
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    updateCartBadge();
    updateHeaderAuth();
});
