String datastring;
void setup() {
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()){
    datastring = Serial.readString();
    Serial.print(datastring);
  }
  Serial.print("This is String");
  delay(1000);

}
