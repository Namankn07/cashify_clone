import React from 'react';
import { Link } from 'react-router-dom';
import { 
  MapPin, Bell, Search, ShoppingCart, 
  Smartphone, ShoppingBag, Wrench, Headphones, User, 
  Heart, Sparkles, ChevronRight 
} from 'lucide-react';

export default function Home() {
  return (
    <div className="max-w-4xl mx-auto space-y-6 pb-12 font-sans">
      
      {/* 1. Header Bar */}
      <div className="flex items-center justify-between bg-white p-4 rounded-2xl border border-gray-100 shadow-sm">
        <div>
          <div className="flex items-center gap-1 font-black text-xl text-emerald-600 tracking-tight">
            CASHIFY <span className="bg-emerald-100 text-emerald-800 text-xs px-2 py-0.5 rounded-full font-bold ml-1">PRO</span>
          </div>
          <div className="flex items-center text-xs text-gray-500 font-medium mt-0.5 cursor-pointer hover:text-emerald-600">
            <MapPin size={12} className="text-emerald-600 mr-1" />
            Bengaluru <span className="ml-1 text-[10px]">▼</span>
          </div>
        </div>

        <div className="flex items-center gap-3 text-gray-600">
          <button className="p-2 bg-gray-50 hover:bg-gray-100 rounded-full transition cursor-pointer">
            <Bell size={18} />
          </button>
          <button className="p-2 bg-gray-50 hover:bg-gray-100 rounded-full transition cursor-pointer">
            <Search size={18} />
          </button>
          <Link to="/buy" className="p-2 bg-gray-50 hover:bg-gray-100 rounded-full transition cursor-pointer">
            <ShoppingCart size={18} />
          </Link>
        </div>
      </div>

      {/* 2. Banner Section */}
      <div className="bg-gradient-to-r from-emerald-600 via-teal-600 to-emerald-800 rounded-2xl p-6 text-white shadow-md relative overflow-hidden">
        <div className="inline-flex items-center gap-1 bg-yellow-400 text-gray-900 text-xs font-black px-3 py-1 rounded-md mb-3 uppercase tracking-wider">
          <Sparkles size={12} /> SUPER FEST 2026
        </div>
        <h2 className="text-2xl md:text-3xl font-extrabold mb-2">
          Get Extra ₹2,500 Bonus
        </h2>
        <p className="text-sm text-emerald-100 mb-4">
          Instant cash evaluation & free doorstep pickup in 60 mins
        </p>
        <Link to="/sell" className="inline-flex items-center gap-2 bg-white text-emerald-800 font-bold px-5 py-2.5 rounded-xl shadow hover:bg-emerald-50 transition text-sm">
          Sell Old Phone Now <ChevronRight size={16} />
        </Link>
      </div>

      {/* 3. Explore Services */}
      <div>
        <h3 className="text-lg font-bold text-gray-800 mb-4">Explore Services</h3>
        <div className="grid grid-cols-5 gap-3 text-center">
          <Link to="/sell" className="bg-emerald-50/60 border border-emerald-100 hover:border-emerald-300 p-3 rounded-2xl flex flex-col items-center justify-center transition">
            <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center text-emerald-600 shadow-sm mb-2">
              <Smartphone size={22} />
            </div>
            <span className="text-xs font-semibold text-gray-800">Sell Phone</span>
          </Link>

          <Link to="/buy" className="bg-blue-50/60 border border-blue-100 hover:border-blue-300 p-3 rounded-2xl flex flex-col items-center justify-center transition">
            <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center text-blue-600 shadow-sm mb-2">
              <ShoppingBag size={22} />
            </div>
            <span className="text-xs font-semibold text-gray-800">Buy Refurb</span>
          </Link>

          <div className="bg-amber-50/60 border border-amber-100 p-3 rounded-2xl flex flex-col items-center justify-center opacity-80">
            <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center text-amber-600 shadow-sm mb-2">
              <Wrench size={22} />
            </div>
            <span className="text-xs font-semibold text-gray-800">Repairs</span>
          </div>

          <div className="bg-rose-50/60 border border-rose-100 p-3 rounded-2xl flex flex-col items-center justify-center opacity-80">
            <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center text-rose-600 shadow-sm mb-2">
              <Headphones size={22} />
            </div>
            <span className="text-xs font-semibold text-gray-800">Accessories</span>
          </div>

          <div className="bg-purple-50/60 border border-purple-100 p-3 rounded-2xl flex flex-col items-center justify-center opacity-80">
            <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center text-purple-600 shadow-sm mb-2">
              <User size={22} />
            </div>
            <span className="text-xs font-semibold text-gray-800">My Account</span>
          </div>
        </div>
      </div>

      {/* 4. Refurbished Flagships */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <h3 className="text-lg font-bold text-gray-800">Refurbished Flagships</h3>
            <span className="text-xs font-medium text-orange-600 bg-orange-100 px-2 py-0.5 rounded-full">🔥 Top Picks</span>
          </div>
          <Link to="/buy" className="text-xs font-bold text-emerald-600 hover:underline">
            View All
          </Link>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
          <div className="bg-white border border-gray-100 rounded-2xl p-3 shadow-sm hover:shadow-md transition relative">
            <button className="absolute top-3 right-3 p-1.5 bg-white/80 rounded-full text-gray-400 hover:text-red-500 shadow-sm z-10">
              <Heart size={16} />
            </button>
            <div className="relative mb-2 overflow-hidden rounded-xl bg-gray-50 h-36 flex items-center justify-center">
              <span className="absolute top-2 left-2 text-[10px] font-bold bg-emerald-600 text-white px-2 py-0.5 rounded-md">
                32-Point Checked
              </span>
              <img 
                src="https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=400&q=80" 
                alt="iPhone 15" 
                className="h-28 object-contain"
              />
            </div>
            <h4 className="font-bold text-sm text-gray-900 truncate">iPhone 15 (128 GB)</h4>
            <p className="text-xs text-gray-500">Superb Condition</p>
            <div className="flex items-center justify-between mt-2">
              <span className="font-extrabold text-base text-gray-900">₹58,999</span>
              <Link to="/buy" className="bg-emerald-600 text-white text-xs px-3 py-1.5 rounded-lg font-semibold hover:bg-emerald-700 transition">
                Buy
              </Link>
            </div>
          </div>

          <div className="bg-white border border-gray-100 rounded-2xl p-3 shadow-sm hover:shadow-md transition relative">
            <button className="absolute top-3 right-3 p-1.5 bg-white/80 rounded-full text-gray-400 hover:text-red-500 shadow-sm z-10">
              <Heart size={16} />
            </button>
            <div className="relative mb-2 overflow-hidden rounded-xl bg-gray-50 h-36 flex items-center justify-center">
              <span className="absolute top-2 left-2 text-[10px] font-bold bg-emerald-600 text-white px-2 py-0.5 rounded-md">
                32-Point Checked
              </span>
              <img 
                src="https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=400&q=80" 
                alt="MacBook" 
                className="h-28 object-contain"
              />
            </div>
            <h4 className="font-bold text-sm text-gray-900 truncate">MacBook Air M2</h4>
            <p className="text-xs text-gray-500">Like New Condition</p>
            <div className="flex items-center justify-between mt-2">
              <span className="font-extrabold text-base text-gray-900">₹68,999</span>
              <Link to="/buy" className="bg-emerald-600 text-white text-xs px-3 py-1.5 rounded-lg font-semibold hover:bg-emerald-700 transition">
                Buy
              </Link>
            </div>
          </div>
        </div>
      </div>

    </div>
  );
}