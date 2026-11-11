import axios from 'axios';

const API = axios.create({
  baseURL: 'http://localhost:5000/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

export const fetchProducts = () => API.get('/products');
export const fetchAccessories = () => API.get('/accessories');
export const createOrder = (orderData) => API.post('/orders', orderData);
export const saveDiagnostic = (data) => API.post('/diagnostics', data);
export const getWalletBalance = (userId) => API.get(`/wallets/${userId}`);

// IMEI Validation API
export const validateIMEI = (imei) => API.post('/validate-imei', { imei });

export default API;