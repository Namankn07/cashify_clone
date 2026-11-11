import axios from 'axios';

// Centralized Axios Instance
const API = axios.create({
    baseURL: 'http://localhost:5000/api', // Aapka backend URL
    headers: {
        'Content-Type': 'application/json'
    }
});

export default API;