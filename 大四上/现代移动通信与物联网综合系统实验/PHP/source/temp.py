import requests
import json
import os
import socket,sys

GWIP = '127.0.0.1'
GWPORT = 51001

URL = 'http://192.168.56.101/net_test/temp.php'	##测试用php网页地址

##下面的函数完成实际的post操作，调用了python第三方库requests下面的post方法。
def query(id, name, type, value):
	data = {"id":id, "name":name, "type":type, "value":value}
	print(data)  #打印输入的json数据
	r = requests.post(URL, json=data)	#POST方法传入一个json数据，返回一个字典，包含Http返回包的所有信息
	try:
		r1 = r.json()
		print('JSON转换结果如下:')
		print(r1)
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
    print(json.dumps(setName))
    fd.write(json.dumps(setName)+'\n')
    fd.flush()
    ret = fd.readline()
    print(ret)
    ret = json.loads(ret)
    if ret['errcode']!=0:
        print(ret['data'])
        return

    print(json.dumps(subscription))
    fd.write(json.dumps(subscription)+'\n')
    fd.flush()
    ret = fd.readline()
    print(ret)
    ret = json.loads(ret)
    if ret['errcode']!=0:
        print(ret['data'])
        return

def run():
    s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    s.connect((GWIP,GWPORT))
    fd = s.makefile('rw')
    initClient(fd)
    while(True):
        line = fd.readline()
        ret = json.loads(line)['args']
        device_id = ret['device_id']
        device_value = ret['device_value']
        if device_id == 40:
            temperature = device_value['temperature']  # 获取温度传感器值
            res = query(device_id, 'Temperate', 's-sensor', str(temperature))  # 更新
            print("id=",res["id"],"name=",res["name"],"type=",res["type"],"value=",res["value"],"\n")
	

if __name__ == '__main__':
	run()
