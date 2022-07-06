import Header from '../components/Header';
import React from 'react';
export default function Home() {
  return (
    <div className="w-full h-full flex flex-col">
      <Header />
      <div
        className="flex-1 w-full flex flex-col items-center">
        <div className="text-4xl font-bold mb-20">
          Welcome to Face Recognition
        </div>
        <div className="text-2xl font-bold mb-12">
          Created by:
        </div>
        <div className="text-xl font-bold mb-36">
          白晓凯 | 黄嘉欣 | 夏宇航
        </div>
        <div className="mb-2">
          How to use:
        </div>
        <div>
          There are 3 modes for this project:
        </div>
        <div>
          1. Save: Add a new face to the database.
        </div>
        <div>
          2. Compare: Compare the face with a given identity.
        </div>
        <div>
          3. Find: Find the face in the database.
        </div>
        <div>
          4. Manage: Manage the database.
        </div>
      </div>
    </div>
  );
}
