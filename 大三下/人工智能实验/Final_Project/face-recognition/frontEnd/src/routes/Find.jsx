import Header from '../components/Header';
import dataToFile from '../utils/convert';
import React, { useRef, useState } from 'react';
import WebCam from 'react-webcam';
import toast from 'react-hot-toast';
import axios from 'axios';

export default function Find() {
  const webCamRef = useRef(null);

  const [res, setRes] = useState('');

  const capture = () => {
    if (!webCamRef || !webCamRef.current) {
      toast.error('Check your camera.');
      return;
    }

    const imageData = webCamRef.current.getScreenshot();

    const file = dataToFile(imageData, 'Face');

    const data = new FormData();
    data.append('file', file, file.name);
    data.append('mode', 'find');

    // Set config
    const config = {
      headers: {
        'Content-Type': 'multipart/form-data',
        'Access-Control-Allow-Origin': '*',
      },
    };

    // Send request
    axios
      .post('http://127.0.0.1:81/getRecognition', data, config)
      .then((response) => {
        const res = response.data;
        setRes(res.data);
      });
  };

  return (
    <div className="w-full h-full flex flex-col">
      <Header />
      <div className="flex-1 w-full px-20">
        <div className="text-3xl font-bold mb-12">
          Find Mode.
        </div>

        <div className="flex flex-col w-full items-center">
          <WebCam
            audio={false}
            ref={webCamRef}
            screenshotFormat="image/jpeg"
            className="w-96 h-96"
          />

          <div
            className="cursor-pointer font-bold text-xl"
            onClick={capture}
          >
            Find
          </div>

          <div className="mt-12">
            {res ? res : 'Result will be shown here.'}
          </div>
        </div>
      </div>
    </div>
  );
}
