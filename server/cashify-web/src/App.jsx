import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import { ShoppingBag, Smartphone } from 'lucide-react';

// Pages - (Inhe hum agle steps me create karenge)
import Home from './pages/Home';
import BuyStore from './pages/BuyStore';
import SellDevice from './pages/SellDevice';

export default function App() {
  return (
    <Router>
      <div className="min-h-screen bg-gray-50 flex flex-col font-sans">
        {/* Top Navigation Bar */}
        <header className="bg-white border-b sticky top-0 z-50 shadow-sm">
          <div className="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between">
            <Link to="/" className="text-2xl font-bold text-teal-600 tracking-tight">
              Cashify<span className="text-orange-500">Clone</span>
            </Link>

            <nav className="flex space-x-6">
              <Link to="/sell" className="flex items-center gap-1 text-gray-700 hover:text-teal-600 font-medium transition">
                <Smartphone size={18} /> Sell Phone
              </Link>
              <Link to="/buy" className="flex items-center gap-1 text-gray-700 hover:text-teal-600 font-medium transition">
                <ShoppingBag size={18} /> Buy Refurbished
              </Link>
            </nav>
          </div>
        </header>

        {/* Main Route Body */}
        <main className="flex-1 max-w-7xl w-full mx-auto p-4">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/buy" element={<BuyStore />} />
            <Route path="/sell" element={<SellDevice />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}