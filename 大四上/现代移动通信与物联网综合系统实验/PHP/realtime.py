import socket,sys
import json

GWIP = '127.0.0.1'
GWPORT = 51001

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
        print(line)
        ret = json.loads(line)
        print(ret['args']['device_id'])

if __name__ == '__main__':
    run()
