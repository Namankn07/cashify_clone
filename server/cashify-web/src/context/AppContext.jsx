import React, { createContext, useContext, useState } from 'react';

const AppContext = createContext();

export const AppProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [cart, setCart] = useState([]);
  const [wishlist, setWishlist] = useState([]);

  const addToCart = (product) => {
    setCart((prev) => [...prev, product]);
  };

  const removeFromCart = (productId) => {
    setCart((prev) => prev.filter((item) => item.id !== productId));
  };

  return (
    <AppContext.Provider value={{ user, setUser, cart, addToCart, removeFromCart, wishlist, setWishlist }}>
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => useContext(AppContext);