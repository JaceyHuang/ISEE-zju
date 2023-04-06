import requests
import json
import os, time
import socket,sys
import threading

GWIP = '127.0.0.1'
GWPORT = 51001

URL = 'http://192.168.56.101/net_test/index_gp.php'	##测试用php网页地址

##下面的函数完成实际的post操作，调用了python第三方库requests下面的post方法。
def query(op, id, name, type, value):
    if op == 'modify':
        data = {"op":op, "id":id, "name":name, "type":type, "value":{"valname":"value", "valdata":value}}
    elif op == 'query':
        data = {"op":op, "id":id, "name":name, "type":type, "value":{"value":value}}
    # print(data)  #打印输入的json数据
    r = requests.post(URL, json=data)	#POST方法传入一个json数据，返回一个字典，包含Http返回包的所有信息
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

def getGwId():
    return "gw1"

def initClient(fd):
        setName = {'cmd':'setName','args':{'name':getGwId()}}
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

def run():
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((GWIP, GWPORT))
        fd = s.makefile('rw')

        initClient(fd)  # 订阅

        while(True):
            line = fd.readline()
            ret = json.loads(line)
            if 'errcode' in ret.keys():
                continue
            ret = ret['args']
            device_id = ret['device_id']
            device_value = ret['device_value']
            
            if device_id == 43 or device_id == 44 or device_id == 45:
                name = 'light'
                type = 'svSensor'
            elif device_id == 30:
                name = 'infrared'
                type = 'svSensor'
            elif device_id == 31:
                name = 'door'
                type = 'svSensor'
            
            if device_id == 43 or device_id == 44 or device_id == 45 or device_id == 30 or device_id == 31:  # 传感器
                res = query('modify', device_id, name, type, device_value)  # 更新数据库中的逻辑设备
                print("id=",res["id"],"name=",res["name"],"type=",res["type"],"value=",res["value"],"\n")

            for device_id in [5,6,15,16,9,20,21]:  # 所有控制器的物理 id
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
                res = query('query', device_id, name, type, device_value)  # 查询逻辑控制器的控制值，若设备不存在则自动创建
                if res['id'] == None:  # 设备不存在
                    res = query('modify', device_id, name, type, False)  # 默认值为 false
                device_id -= 100  # 回到物理设备空间
                action = {'cmd':'setSwitch', 'args': {'device_id': device_id, 'device_value': res['value']['value']}}  # 控制物理设备

                fd.write(json.dumps(action)+'\n')
                fd.flush()
                ret = fd.readline()
                ret = json.loads(ret)
                if 'errcode' in ret.keys():
                    if ret['errcode'] != 0:
                        print(ret['data'])
                        return

            time.sleep(2)  # 定时2秒
	

if __name__ == '__main__':
	run()
