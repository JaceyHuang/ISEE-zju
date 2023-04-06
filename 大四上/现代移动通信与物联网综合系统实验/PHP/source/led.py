import requests
import json
import os
import socket,sys

GWIP = '127.0.0.1'
GWPORT = 51001

URL = 'http://192.168.56.101/net_test/led.php'	##测试用php网页地址

##下面的函数完成实际的post操作，调用了python第三方库requests下面的post方法。
def query(id):
	data = {"id":id}
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

def run():
    s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    s.connect((GWIP,GWPORT))
    fd = s.makefile('rw')
    
    while(True):
        device_id = 105  # 只查询 id=105
        res = query(device_id)
        print("id=",res["id"],"name=",res["name"],"type=",res["type"],"value=",res["value"],"\n")

        if res['value'] == "false":  # 控制 led 灯
            action = {'cmd':'setSwitch', 'args': {'device_id': 5, 'device_value': False}}
        elif res['value'] == 'true':
            action = {'cmd':'setSwitch', 'args': {'device_id': 5, 'device_value': True}}
        fd.write(json.dumps(action)+'\n')
        fd.flush()
        ret = fd.readline()
        ret = json.loads(ret)
        if ret['errcode'] != 0:
            print(ret['data'])
            return
	

if __name__ == '__main__':
	run()
