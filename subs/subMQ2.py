import random
import mysql.connector as database
from paho.mqtt import client as mqtt_client


broker = 'server_url'
port = 8883
topic = "mq2"
# Generate a Client ID with the subscribe prefix.
client_id = f'subscribe-{random.randint(0, 100)}'
username = 'user'
password = 'pass'

db_user = 'db_user'
db_pass = 'db_pass'
db_schema = 'db_schema'


def connect_mqtt() -> mqtt_client:
    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("Connected to MQTT Broker!")
        else:
            print("Failed to connect, return code %d\n", rc)

    client = mqtt_client.Client(client_id)
    client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.tls_set()
    client.tls_insecure_set(True)
    client.on_connect = on_connect
    client.connect(broker, port)
    return client


def storeData(client, userdata, msg):
    cursor = connection.cursor()
    try:
        data = msg.payload.decode().split(': ')[1]
        statement = "INSERT INTO "+topic+" (value) VALUES ("+data+");"
        cursor.execute(statement, data)
        connection.commit()
        print("Successfully added entry to database")
    except database.Error as e:
        print(f"Error adding entry to database: {e}")


def subscribe(client: mqtt_client):
    client.subscribe(topic)
    client.on_message = storeData


def run():
    client = connect_mqtt()
    subscribe(client)
    client.loop_forever()


if __name__ == '__main__':
    connection = database.connect(
        user=db_user,
        password=db_pass,
        host=broker,
        database=db_schema)
    run()
