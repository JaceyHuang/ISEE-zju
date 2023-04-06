import requests
import json
import os

URL = 'http://192.168.56.101/net_test/test.php'	##测试用php网页地址
##对该网页进行POST操作，输入{"a":a,"b":b,"c":c}这样的json数据就会在服务器的数据库dbdevices的me表格下创建一条新纪录

##下面的函数完成实际的post操作，调用了python第三方库requests下面的post方法。
def query(a,b,c):
	data = {"a":a,"b":b,"c":c}
	print(data)  #打印输入的json数据
	r = requests.post(URL,json=data)	#POST方法传入一个json数据，返回一个字典，包含Http返回包的所有信息
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

def run(ta):
	print('py test')
	sa = ta
	sb = 'abc'
	sc = '123'
	ret = query(sa,sb,sc)
	print("a=",ret["a"],"b=",ret["b"],"c=",ret["c"])

if __name__ == '__main__':
	count = 0
	while(count<1000):
		run(count)
		count = count+1
