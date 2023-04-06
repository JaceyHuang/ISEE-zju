import paho.mqtt.client as mqtt
import time

HOST = "10.79.224.188"
PORT = 42300

#MQTT程序入口
def client_loop():
    client_id = time.strftime('%Y%m%d%H%M%S',time.localtime(time.time()))# ClientId不能重复，所以使用当前时间
    client = mqtt.Client(client_id)
    #client.username_pw_set("用户名---", "密码---")
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect(HOST, PORT, 60)
    client.publish("$IOT423/Test", "MQTT start", qos=0, retain=False) # 发布消息
    client.loop_forever()

#连接
def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    client.subscribe("$IOT423/Test/#",0)#订阅，参数为（订阅号，Qos值）

#消息接收，此处会一直阻塞主线程
def on_message(client, userdata, msg):#打印订阅消息
    print(msg.topic+" "+msg.payload.decode("utf-8"))

#程序主入口
if __name__ == '__main__':
    client_loop()