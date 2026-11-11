import React, { useEffect, useState } from 'react';
import { fetchProducts } from '../services/api';
import { useApp } from '../context/AppContext';

export default function BuyStore() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const { addToCart } = useApp();

  useEffect(() => {
    fetchProducts()
      .then((res) => {
        setProducts(res.data);
        setLoading(false);
      })
      .catch((err) => {
        console.error("API Fetch Error:", err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="p-8 text-center text-gray-500">Loading catalogue...</div>;

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6 text-gray-800">Refurbished Smartphones</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {products.map((item) => (
          <div key={item.id} className="bg-white border border-gray-200 rounded-xl p-4 shadow-sm hover:shadow-md transition">
            <img 
              src={item.image_url || 'https://via.placeholder.com/150'} 
              alt={item.title} 
              className="w-full h-40 object-contain mb-3" 
            />
            <span className="text-xs font-semibold bg-teal-100 text-teal-800 px-2 py-0.5 rounded">
              32-Point Checked
            </span>
            <h3 className="font-semibold text-lg mt-2 text-gray-900">{item.title}</h3>
            <p className="text-sm text-gray-500 capitalize">{item.condition_grade} Condition</p>
            <div className="flex items-center justify-between mt-4">
              <span className="text-xl font-bold text-gray-900">₹{item.price}</span>
              <button 
                onClick={() => addToCart(item)}
                className="bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition cursor-pointer">
                Add to Cart
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}