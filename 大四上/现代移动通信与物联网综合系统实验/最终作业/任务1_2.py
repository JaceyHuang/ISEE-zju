import requests
import json
import os, time
import socket, sys
import paho.mqtt.client as mqtt
import threading

GWIP = '127.0.0.1'
GWPORT = 51001

HOST = '192.168.56.101'
PORT = 1883

URL = 'http://192.168.56.101/net_test/index_gp.php'	##测试用php网页地址

##下面的函数完成实际的post操作，调用了python第三方库requests下面的post方法。
def query(op, id, name, type, value, value_2=None):
    if op == 'modify':
        data = {"op":op, "id":id, "name":name, "type":type, "value":{"valname":"value", "valdata":value}}
    elif op == 'query':
        data = {"op":op, "id":id, "name":name, "type":type, "value":{"value":value}}
    # print(data)  #打印输入的json数据
    r = requests.post(URL, json=data)	#POST方法传入一个json数据，返回一个字典，包含Http返回包的所有信息
    if value_2:
        data = {"op":op, "id":id, "name":name, "type":type, "value":{"valname":"value_h", "valdata":value_2}}
        r = requests.post(URL, json=data)
    try:
        r1 = r.json()
        r = r1
    except :
        print('except!')
        print('字典所有结果如下:')
        print(r.__dict__)	##打印返回的原始数据
        print('实际返回内容如下:')
        print(r.__dict__.get('_content'))	##打印返回的原始数据（内容），这步和上一步print及下一步print均为调试用，可注释掉。
	
    return r


def on_connect(client, userdata, flags, rc):
    print('Connected with result code '+str(rc))
    client.subscribe('qt', 0)


def on_message(client, userdata, msg):
    sub_payload = msg.payload.decode('utf-8')  # 接收消息格式：{'device_id': xx, 'device_value': y}，其中 y=0 表示 false，y=1 表示 true
    print(msg.topic+' '+sub_payload)
    data = json.loads(sub_payload)
    
    global qt_device_id, qt_device_value, receive_msg
    qt_device_id = data['device_id']
    qt_device_value = True if data['device_value'] else False 
    receive_msg = True


class ReadDevice(threading.Thread):
    def __init__(self):
        super().__init__()
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((GWIP, GWPORT))
        self.fd = s.makefile('rw')
        self.initClient(self.fd)  # 订阅

    def getGwId(self):
        return "gw1"

    def initClient(self, fd):
        setName = {'cmd':'setName','args':{'name':self.getGwId()}}
        subscription = {"cmd":"subscription"}

        fd.write(json.dumps(setName)+'\n')
        fd.flush()
        ret = fd.readline()
        ret = json.loads(ret)
        if ret['errcode']!=0:
            print(ret['data'])
            return

        fd.write(json.dumps(subscription)+'\n')
        fd.flush()
        ret = fd.readline()
        ret = json.loads(ret)
        if ret['errcode']!=0:
            print(ret['data'])
            return
    
    def run(self):
        while(True):
            line = self.fd.readline()
            ret = json.loads(line)
            if 'errcode' in ret.keys():
                continue
            ret = ret['args']
            device_id = ret['device_id']
            device_value = ret['device_value']

            if device_id == 40 or device_id == 41 or device_id == 42 or device_id == 43 or device_id == 44 or device_id == 45 or device_id == 30 or device_id == 31:  # 传感器
                if device_id == 40 or device_id == 41 or device_id == 42:
                    name = 'humiditure'
                    type = 'svSensor'
                    device_value_1 = device_value['temperature']
                    device_value_2 = device_value['humidity']
                    res = query('modify', device_id, name, type, device_value_1, device_value_2)  # 更新数据库中的逻辑设备
                else:
                    if device_id == 43 or device_id == 44 or device_id == 45:
                        name = 'light'
                        type = 'svSensor'
                    elif device_id == 30:
                        name = 'infrared'
                        type = 'svSensor'
                    elif device_id == 31:
                        name = 'door'
                        type = 'svSensor'
                    res = query('modify', device_id, name, type, device_value)  # 更新数据库中的逻辑设备
                # print("id=",res["id"],"name=",res["name"],"type=",res["type"],"value=",res["value"],"\n")

            elif device_id == 5 or device_id == 6 or device_id == 15 or device_id == 16 or device_id == 9 or device_id == 20 or device_id == 21:
                if device_id == 5 or device_id == 6:
                    name = 'led'
                    type = 'svController'
                elif device_id == 15 or device_id == 16:
                    name = 'fan'
                    type = 'svController'
                elif device_id == 9:
                    name = 'heater'
                    type = 'svController'
                elif device_id == 20:
                    name = 'curtain'
                    type = 'svController'
                elif device_id == 21:
                    name = 'rack'
                    type = 'svController'
                device_id += 100  # controller 对应的 id 大于 100
                res = query('modify', device_id, name, type, device_value)  # 更新数据库中的逻辑设备
                # print("id=",res["id"],"name=",res["name"],"type=",res["type"],"value=",res["value"],"\n")

            global receive_msg, qt_device_id, qt_device_value
            if receive_msg:
                if qt_device_id > 100:
                    qt_device_id -= 100
                action = {'cmd':'setSwitch', 'args': {'device_id': qt_device_id, 'device_value': qt_device_value}}  # 控制物理设备
                receive_msg = False
                
                self.fd.write(json.dumps(action)+'\n')
                self.fd.flush()
                ret = self.fd.readline()
                ret = json.loads(ret)
                if 'errcode' in ret.keys():
                    if ret['errcode'] != 0:
                        print(ret['data'])
                        return


class QtResponse(threading.Thread):
    def __init__(self):
        super().__init__()
        client_id = time.strftime('%Y%m%d%H%M%S', time.localtime(time.time()))
        client = mqtt.Client(client_id)
        client.on_connect = on_connect
        client.on_message = on_message
        client.connect(HOST, PORT, 60)
        client.loop_start()
	

if __name__ == '__main__':

    qt_device_id = None
    qt_device_value = None
    receive_msg = False

    data = ReadDevice()
    data.start()

    qt = QtResponse()
    qt.start()

    data.join()
    qt.join()
