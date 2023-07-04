import time
import serial
from datetime import datetime
import random

from paho.mqtt import client as mqtt_client
import paho.mqtt.client as mqtta

broker = 'brokerurl'
port = 8883

client_id = f'subscribe-{random.randint(0, 100)}'
username = 'user'
password = 'pass'


def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to MQTT Broker!")
    else:
        print("Failed to connect, return code %d\n", rc)


def connect_mqtt():

    client = mqtt_client.Client(client_id, True, None, mqtta.MQTTv311)
    client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.tls_set()
    client.tls_insecure_set(True)
    client.connect(broker, port)
    return client


def publishMQ2(client, value):
    topic = "mq2"
    msg = f"messages: {int(value)}"
    result = client.publish(topic, msg)
    status = result[0]
    if status == 0:
        print(f"Send `{msg}` to topic `{topic}`")
    else:
        print()
        print(f"Failed to send message to topic {topic}")

    print(value + ";"+str(datetime.now()))

def publishMQ7(client, value):
    topic = "mq7"
    msg = f"messages: {int(value)}"
    result = client.publish(topic, msg)
    status = result[0]
    if status == 0:
        print(f"Send `{msg}` to topic `{topic}`")
    else:
        print()
        print(f"Failed to send message to topic {topic}")

    print(value + ";"+str(datetime.now()))


def run():
    client = connect_mqtt()
    ser = serial.Serial(port="/dev/ttyACM0", baudrate=115200, timeout=5)
    time.sleep(1)
    aux = 0

    leitura = str(ser.readline()).replace("b'", '').replace("\\r\\n'", '')
    client.loop_start()
    while True:
        leitura = str(ser.readline()).replace(
            "b'", '').replace("\\r\\n'", '')
        print(leitura)
        time.sleep(1)
        if (aux == 1):
            leitura = leitura.split(',')
            publishMQ7(client, leitura[0])
            publishMQ2(client, leitura[1])
        elif ("Aquecendo" in leitura):
            aux = 1
    client.loop_stop()


if __name__ == '__main__':
    run()
