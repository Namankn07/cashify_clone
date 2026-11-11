import React, { useState, useEffect } from 'react';
import API from '../api/axiosInstance';

const AdminDashboard = () => {
  const [issueName, setIssueName] = useState('');
  const [deductionVal, setDeductionVal] = useState('');
  const [pincode, setPincode] = useState('');
  const [cityName, setCityName] = useState('');

  // 1. Add Dynamic Pricing Deduction Rule
  const handleAddPricingRule = async () => {
    if (!issueName || !deductionVal) {
      alert('Please fill issue name and deduction percentage');
      return;
    }
    try {
      const res = await fetch('http://localhost:5000/api/admin/pricing-rules', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ category: 'Mobiles', issueName, deductionValue: deductionVal })
      });
      const data = await res.json();
      if (data.success) {
        alert('✅ Valuation Rule Added Successfully!');
        setIssueName('');
        setDeductionVal('');
      }
    } catch (e) {
      alert('Error connecting to backend server');
    }
  };

  // 2. Enable New Serviceable Pincode
  const handleAddPincode = async () => {
    if (!pincode || !cityName) {
      alert('Please enter pincode and city');
      return;
    }
    try {
      const res = await fetch('http://localhost:5000/api/admin/pincodes', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ pincode, city: cityName, state: 'Karnataka' })
      });
      const data = await res.json();
      if (data.success) {
        alert('✅ Pincode Activated for Pickup Service!');
        setPincode('');
        setCityName('');
      }
    } catch (e) {
      alert('Error activating pincode');
    }
  };

  return (
    <div style={{ maxWidth: '800px', margin: '30px auto', padding: '24px', fontFamily: 'sans-serif' }}>
      <h2 style={{ color: '#00A79D', borderBottom: '2px solid #00A79D', paddingBottom: '10px' }}>
        ⚙️ Cashify Central Admin Hub
      </h2>

      {/* 1. Dynamic Pricing Engine Manager */}
      <div style={{ background: '#f8f9fa', padding: '20px', borderRadius: '10px', marginBottom: '24px', border: '1px solid #e9ecef' }}>
        <h3 style={{ marginTop: 0 }}>1. Manage Dynamic Valuation Rules</h3>
        <p style={{ color: '#6c757d', fontSize: '14px' }}>Set auto-deduction percentage for physical damages during device sell evaluation.</p>
        <div style={{ display: 'flex', gap: '10px', marginTop: '12px' }}>
          <input
            placeholder="Issue Name (e.g. Cracked Screen)"
            value={issueName}
            onChange={(e) => setIssueName(e.target.value)}
            style={{ flex: 2, padding: '10px', borderRadius: '6px', border: '1px solid #ccc' }}
          />
          <input
            placeholder="Deduction % (e.g. 25)"
            type="number"
            value={deductionVal}
            onChange={(e) => setDeductionVal(e.target.value)}
            style={{ flex: 1, padding: '10px', borderRadius: '6px', border: '1px solid #ccc' }}
          />
          <button
            onClick={handleAddPricingRule}
            style={{ padding: '10px 20px', backgroundColor: '#00A79D', color: '#fff', border: 'none', borderRadius: '6px', fontWeight: 'bold', cursor: 'pointer' }}
          >
            Add Rule
          </button>
        </div>
      </div>

      {/* 2. Pincode & Logistics Serviceability Manager */}
      <div style={{ background: '#f8f9fa', padding: '20px', borderRadius: '10px', border: '1px solid #e9ecef' }}>
        <h3 style={{ marginTop: 0 }}>2. Manage Serviceable Pincodes</h3>
        <p style={{ color: '#6c757d', fontSize: '14px' }}>Enable or disable doorstep pickup service for specific pincode zones.</p>
        <div style={{ display: 'flex', gap: '10px', marginTop: '12px' }}>
          <input
            placeholder="6-Digit Pincode (e.g. 560102)"
            value={pincode}
            onChange={(e) => setPincode(e.target.value)}
            style={{ flex: 1, padding: '10px', borderRadius: '6px', border: '1px solid #ccc' }}
          />
          <input
            placeholder="City Name (e.g. Bengaluru)"
            value={cityName}
            onChange={(e) => setCityName(e.target.value)}
            style={{ flex: 1, padding: '10px', borderRadius: '6px', border: '1px solid #ccc' }}
          />
          <button
            onClick={handleAddPincode}
            style={{ padding: '10px 20px', backgroundColor: '#3B82F6', color: '#fff', border: 'none', borderRadius: '6px', fontWeight: 'bold', cursor: 'pointer' }}
          >
            Enable Zone
          </button>
        </div>
      </div>
    </div>
  );
};

export default AdminDashboard;