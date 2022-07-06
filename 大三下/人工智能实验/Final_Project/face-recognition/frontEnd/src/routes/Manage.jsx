import Header from '../components/Header';
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import toast from 'react-hot-toast';

export default function Manage() {
  const [personList, setPersonList] = useState([]);

  const config = {
    headers: {
      'Content-Type': 'multipart/form-data',
      'Access-Control-Allow-Origin': '*',
    },
  };

  useEffect(() => {
    axios
      .get('http://127.0.0.1:81/getRecognition', config)
      .then((response) => {
        const res = response.data;
        setPersonList(res.data);
      });
  }, []);

  const deletePerson = (identity) => {
    const data = new FormData();

    data.append('identity', identity);
    data.append('mode', 'delete');

    axios
      .post('http://127.0.0.1:81/getRecognition', data, config)
      .then((response) => {
        const res = response.data;
        console.log(res);
      });

    const index = personList.findIndex(person => person.identity === identity);
    personList.splice(index, 1);
    setPersonList([...personList]);

    toast.success('Delete Succeefully!');
  };

  return (
    <div className="w-full h-full flex flex-col items-center">
      <Header />
      <div className="flex-1 w-1/2">
        {personList.map((person, index) => {
          return (
            <div
              key={index}
              className="my-4 border-2 h-12 rounded-full px-8 font-bold
              flex items-center justify-between"
            >
              <div className="">
                {person}
              </div>
              <div
                className="cursor-pointer"
                onClick={() => { deletePerson(person); }}
              >
                Delete
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
