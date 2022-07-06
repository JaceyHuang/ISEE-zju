import Home from './routes/Home';
import Compare from './routes/Compare';
import Save from './routes/Save';
import Find from './routes/Find';
import Manage from './routes/Manage';
import { Routes, Route, BrowserRouter } from 'react-router-dom';
import React from 'react';
import { Toaster } from 'react-hot-toast';

export default function App() {

  return (
    <div className="w-full h-full font-sans bg-primary-brown">
      <Toaster />
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/save" element={<Save />} />
          <Route path="/compare" element={<Compare />} />
          <Route path="/find" element={<Find />} />
          <Route path="/manage" element={<Manage />} />
        </Routes>
      </BrowserRouter>
    </div>
  );
}
