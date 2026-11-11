import { useEffect, useState } from 'react';
import axios from 'axios';

function App() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.get('http://localhost:5000/api/products')
      .then(response => {
        setProducts(response.data);
        setLoading(false);
      })
      .catch(error => {
        console.error('Error fetching data:', error);
        setLoading(false);
      });
  }, []);

  return (
    <div style={{ fontFamily: 'Inter, system-ui, sans-serif', backgroundColor: '#f4f6f8', minHeight: '100vh' }}>
      {/* Top Header Navigation */}
      <header style={{ backgroundColor: '#ffffff', padding: '15px 40px', boxShadow: '0 2px 8px rgba(0,0,0,0.06)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h1 style={{ margin: 0, color: '#2b3990', fontSize: '24px', fontWeight: 'bold' }}>
          Cashify<span style={{ color: '#00b259' }}>Clone</span>
        </h1>
        <div style={{ backgroundColor: '#e6f7ef', color: '#00b259', padding: '6px 14px', borderRadius: '20px', fontSize: '13px', fontWeight: '600' }}>
          ✓ Neon PostgreSQL Connected
        </div>
      </header>

      {/* Main Content Area */}
      <main style={{ maxWidth: '1100px', margin: '30px auto', padding: '0 20px' }}>
        <div style={{ marginBottom: '25px' }}>
          <h2 style={{ margin: 0, color: '#1a1a1a', fontSize: '22px' }}>Refurbished Devices & Inventory</h2>
          <p style={{ margin: '5px 0 0 0', color: '#666', fontSize: '14px' }}>Fetched dynamically from PostgreSQL REST API</p>
        </div>

        {loading ? (
          <div style={{ textAlign: 'center', padding: '50px', color: '#666' }}>
            <h3>Loading products from database...</h3>
          </div>
        ) : products.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '50px', color: '#666' }}>
            <h3>No products found in database.</h3>
          </div>
        ) : (
          /* Products Grid Layout */
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '20px' }}>
            {products.map((product) => (
              <div key={product.id} style={{ backgroundColor: '#ffffff', borderRadius: '12px', border: '1px solid #e0e0e0', overflow: 'hidden', padding: '20px', transition: 'transform 0.2s', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                    <span style={{ backgroundColor: '#f0f4ff', color: '#2b3990', fontSize: '11px', fontWeight: 'bold', padding: '3px 8px', borderRadius: '4px', textTransform: 'uppercase' }}>
                      {product.brand || 'Device'}
                    </span>
                    <span style={{ fontSize: '11px', color: '#00b259', fontWeight: 'bold' }}>
                      32-Point Inspected
                    </span>
                  </div>

                  <h3 style={{ margin: '0 0 10px 0', color: '#222', fontSize: '16px', lineHeight: '1.4' }}>
                    {product.title}
                  </h3>
                </div>

                <div style={{ marginTop: '15px', borderTop: '1px solid #f0f0f0', pt: '15px' }}>
                  <div style={{ display: 'flex', alignItems: 'baseline', gap: '8px', marginBottom: '15px' }}>
                    <span style={{ fontSize: '20px', fontWeight: 'bold', color: '#1a1a1a' }}>
                      ₹{Number(product.price).toLocaleString('en-IN')}
                    </span>
                  </div>

                  <button style={{ width: '100%', backgroundColor: '#00b259', color: '#ffffff', border: 'none', padding: '10px', borderRadius: '6px', fontWeight: 'bold', cursor: 'pointer', fontSize: '14px' }}>
                    Buy Now
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}

export default App;