// ESP32
#include <WiFi.h>
#include <PubSubClient.h>

#define MQ7a 36
#define MQ2a 39

const char* ssid = "SSID";
const char* password =  "pass";

int mq7aValue;
int mq2aValue;


WiFiClient espClient;
PubSubClient client(espClient);

const char* mqttServer = "host";
const int mqttPort = 0000;
const char* mqttUser = "user";
const char* mqttPassword = "pass";


unsigned long lastMsg = 0;
#define MSG_BUFFER_SIZE	(50)
char msgMQ2[MSG_BUFFER_SIZE];
char msgmq7[MSG_BUFFER_SIZE];
int value = 0;




void callback(char* topic, byte* payload, unsigned int length){
  Serial.println("MQTT ACTION");
}


void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP32Client-";
    clientId += String(random(0xffff), HEX);
    if (client.connect(clientId.c_str(), mqttUser, mqttPassword)) {
      Serial.println("connected");
      client.subscribe("italodea/feeds/buzzer");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void setup() {

  Serial.begin(115200);

  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi..");
  }
  Serial.println("Connected to the WiFi network");

  Serial.println("Aquecendo sensores!");
  client.setServer(mqttServer, 1883);
  client.setCallback(callback);
  
  delay(10000);
}

void loop() {
  
  if (!client.connected()) {
    Serial.println("0,0");
    delay(2000);
    reconnect();
  }
  client.loop();

  
  mq2aValue = analogRead(MQ2a);
  mq7aValue = analogRead(MQ7a);
  Serial.println(mq2aValue);
  Serial.print(",");
  Serial.print(mq7aValue);


  unsigned long now = millis();
  if (now - lastMsg > 4000) {
    lastMsg = now;
    snprintf (msgMQ2, MSG_BUFFER_SIZE, "%ld", mq2aValue);
    snprintf (msgmq7, MSG_BUFFER_SIZE, "%ld", mq7aValue);
    Serial.print("Publish message: ");
    Serial.println(msgMQ2);
    Serial.println(msgmq7);
    client.publish("italodea/feeds/sensores-de-ar.mq2", msgMQ2);
    client.publish("italodea/feeds/sensores-de-ar.mq7", msgmq7);
  }

  
  delay(2000);
}

