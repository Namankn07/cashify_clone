import React, { useState } from 'react';
import { createOrder, validateIMEI } from '../services/api';
import { CheckCircle2, AlertCircle, PhoneCall } from 'lucide-react';

export default function SellDevice() {
  const [brand, setBrand] = useState('Apple');
  const [model, setModel] = useState('iPhone 13 (128 GB)');
  const [quote, setQuote] = useState(36000);
  
  // IMEI States
  const [imei, setImei] = useState('');
  const [imeiStatus, setImeiStatus] = useState({ valid: null, message: '', loading: false });
  const [submitLoading, setSubmitLoading] = useState(false);

  // Dynamic price quote calculation
  const handleModelChange = (e) => {
    const val = e.target.value;
    setModel(val);
    if (val.includes('14 Pro')) setQuote(62000);
    else if (val.includes('S23 Ultra')) setQuote(58000);
    else if (val.includes('OnePlus 11')) setQuote(33000);
    else setQuote(36000);
  };

  // Frontend & Backend IMEI Verification
  const handleVerifyIMEI = async () => {
    if (imei.length !== 15) {
      setImeiStatus({ valid: false, message: 'IMEI must be exactly 15 digits.', loading: false });
      return;
    }

    setImeiStatus({ valid: null, message: 'Verifying with server...', loading: true });

    try {
      const response = await validateIMEI(imei);
      if (response.data.valid) {
        setImeiStatus({ valid: true, message: response.data.message, loading: false });
      }
    } catch (error) {
      const errMsg = error.response?.data?.message || 'IMEI verification failed.';
      setImeiStatus({ valid: false, message: errMsg, loading: false });
    }
  };

  // Handle Order Submit
  const handleSell = async () => {
    if (!imeiStatus.valid) {
      alert("Please verify a valid 15-digit IMEI number before scheduling pickup.");
      return;
    }

    setSubmitLoading(true);
    try {
      const orderData = {
        title: `SELL: ${brand} ${model}`,
        type: 'sell',
        offered_price: quote,
        imei_number: imei,
        status: 'Pickup Scheduled',
        payment_mode: 'UPI'
      };

      await createOrder(orderData);
      alert(`🎉 Pickup Scheduled Successfully!\nDevice: ${brand} ${model}\nIMEI: ${imei}\nPrice: ₹${quote}`);
      
      // Reset Form
      setImei('');
      setImeiStatus({ valid: null, message: '', loading: false });
    } catch (error) {
      console.error(error);
      alert("❌ Order creation failed. Check backend connection.");
    } finally {
      setSubmitLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto py-8 px-4">
      <h1 className="text-3xl font-bold mb-6 text-gray-800 text-center">Cashify Instant Sell</h1>

      <div className="bg-white p-8 rounded-2xl border border-gray-200 shadow-sm space-y-6">
        
        {/* Step 1: Select Brand */}
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-2">1. Select Brand</label>
          <select 
            value={brand} 
            onChange={(e) => setBrand(e.target.value)}
            className="w-full border border-gray-300 rounded-lg p-3 outline-none focus:border-teal-500 focus:ring-1 focus:ring-teal-500 bg-gray-50"
          >
            <option>Apple</option>
            <option>Samsung</option>
            <option>OnePlus</option>
            <option>Xiaomi</option>
            <option>Vivo</option>
            <option>Realme</option>
          </select>
        </div>

        {/* Step 2: Select Model */}
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-2">2. Select Exact Model</label>
          <select 
            value={model} 
            onChange={handleModelChange}
            className="w-full border border-gray-300 rounded-lg p-3 outline-none focus:border-teal-500 focus:ring-1 focus:ring-teal-500 bg-gray-50"
          >
            <option>iPhone 13 (128 GB)</option>
            <option>iPhone 14 Pro (128 GB)</option>
            <option>Galaxy S23 Ultra (256 GB)</option>
            <option>OnePlus 11 5G (256 GB)</option>
          </select>
        </div>

        {/* Step 3: IMEI Verification Field */}
        <div>
          <div className="flex justify-between items-center mb-2">
            <label className="block text-sm font-semibold text-gray-700">3. Enter Device IMEI Number</label>
            <span className="text-xs text-teal-600 font-medium flex items-center gap-1">
              <PhoneCall size={12} /> Dial *#06# to get IMEI
            </span>
          </div>

          <div className="flex gap-2">
            <input 
              type="text"
              maxLength={15}
              placeholder="Enter 15-digit IMEI number"
              value={imei}
              onChange={(e) => {
                const val = e.target.value.replace(/\D/g, ''); // Digits only
                setImei(val);
                setImeiStatus({ valid: null, message: '', loading: false });
              }}
              className="flex-1 border border-gray-300 rounded-lg p-3 font-mono text-gray-900 outline-none focus:border-teal-500 bg-gray-50"
            />
            <button
              type="button"
              onClick={handleVerifyIMEI}
              disabled={imei.length !== 15 || imeiStatus.loading}
              className="bg-teal-600 hover:bg-teal-700 text-white font-semibold px-5 py-3 rounded-lg disabled:bg-gray-300 transition"
            >
              {imeiStatus.loading ? 'Checking...' : 'Verify'}
            </button>
          </div>

          {/* Validation Status Message */}
          {imeiStatus.message && (
            <div className={`mt-2 flex items-center gap-2 text-sm font-medium ${imeiStatus.valid ? 'text-green-600' : 'text-red-600'}`}>
              {imeiStatus.valid ? <CheckCircle2 size={16} /> : <AlertCircle size={16} />}
              <span>{imeiStatus.message}</span>
            </div>
          )}
        </div>

        {/* Valuation Display */}
        <div className="bg-teal-50 p-6 rounded-xl border border-teal-100 text-center">
          <p className="text-sm text-teal-800 font-medium mb-1">Guaranteed Cash Price</p>
          <p className="text-4xl font-extrabold text-teal-600">₹{quote.toLocaleString()}</p>
        </div>

        {/* Submit Button */}
        <button 
          onClick={handleSell}
          disabled={!imeiStatus.valid || submitLoading}
          className="w-full bg-teal-600 hover:bg-teal-700 text-white font-bold py-4 px-4 rounded-xl transition shadow-md disabled:bg-gray-300 disabled:cursor-not-allowed cursor-pointer"
        >
          {submitLoading ? 'Scheduling Pickup...' : 'Schedule Free Doorstep Pickup'}
        </button>

      </div>
    </div>
  );
}