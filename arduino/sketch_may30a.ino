//Arduino
#define MQ2a 0
#define MQ7a 1

int mq2aValue;
int mq7aValue;


void setup() {
  Serial.begin(115200);

  // 15 segundos de delay - ideal 30 minutos
  delay(15000);
  Serial.println("Aquecendo sensores!");
}

void loop() {
  
  mq2aValue = analogRead(MQ2a);
  mq2aValue = map(mq2aValue, 0, 1023, 0, 255);
  mq7aValue = analogRead(MQ7a);
  mq7aValue = map(mq7aValue, 0, 1023, 0, 255);
  Serial.print(mq2aValue);
  Serial.print(",");
  Serial.println(mq7aValue);
  
  delay(2000);
}