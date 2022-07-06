import re
from urllib import response
from flask import Flask
from flask import request
from flask import jsonify, make_response
from flask_cors import CORS
import numpy as np
import cv2
import recognition as rec


# Handle CORS
app = Flask(__name__)
CORS(app, resources={r"/*"})


@app.route("/getRecognition", methods=['POST', 'GET', 'DELETE'])
async def get_recognition():
    response = await handle_pic_get_recognition(request)
    return response


async def handle_pic_get_recognition(request):
    try:
        if request.method == 'POST':
            # decide mode
            mode = request.form['mode']
            res = ''
            print(request.form)
            if mode == 'delete':
                identity = request.form['identity']
                res = rec.del_dict(identity)
            else:
                # get the image from the request
                f = request.files['file']
                img = cv2.imdecode(np.frombuffer(
                    f.stream.read(), np.uint8), cv2.IMREAD_COLOR)

                if mode == 'find':
                    res = rec.recognize(False, True, False, img, '', '')
                elif mode == 'save':
                    identity = request.form['identity']
                    res = rec.recognize(True, False, False, img, identity, '')
                elif mode == 'compare':
                    search_identity = request.form['searchIdentity']
                    res = rec.recognize(False, False, True,
                                        img, '', search_identity)
        elif request.method == 'GET':
            res = rec.person_list()

    # if there is an error, return a 400 bad request
    except Exception as e:
        print(e)
        return make_response(jsonify({'data': None, 'status': 0, 'error': 'Something is wrong'}), 0)

    # return the result as json
    response = jsonify({'data': res, 'status': 200, 'error': None})
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST'
    response.headers['Access-Control-Allow-Headers'] = 'x-requested-with,content-type'
    return make_response(response, 200)

app.run(host='0.0.0.0', port=81)
