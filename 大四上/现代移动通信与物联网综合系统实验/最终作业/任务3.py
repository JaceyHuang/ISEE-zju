import socket
import paho.mqtt.client as mqtt
import json
import time

HOST = '192.168.56.101'
PORT = 1883

def receive_data(client):
    # 1. 创建udp套接字
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    # 2. 准备接收方的地址
    dest_addr = ('127.0.0.1', 23333)
    # 3. 绑定地址
    udp_socket.bind(dest_addr)
    while True:
        # 4. 等待接收对方发送的数据
        receive_data, client_address = udp_socket.recvfrom(1024)
        receive_data = receive_data.decode('utf-8')
        # print("接收到了客户端 %s 传来的数据: %s\n" % (client_address, receive_data))
        pub_message = {"data": receive_data}
        client.publish('Trigger', json.dumps(pub_message), qos=0, retain=False)
    # 5. 关闭套接字
    udp_socket.close()

def on_connect(client, userdata, flags, rc):
    print('Connected with result code '+str(rc))

if __name__ == '__main__':
    client_id = time.strftime('%Y%m%d%H%M%S', time.localtime(time.time()))
    client = mqtt.Client(client_id)
    client.on_connect = on_connect
    client.connect(HOST, PORT, 60)
    client.loop_start()
    receive_data(client)