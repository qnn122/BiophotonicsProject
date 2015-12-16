void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available() > 0) {
    char re = Serial.read();

    switch(re) {
      case 'E':
      start();
      break;
    }
  }

}

/*Send signal through serial port continuously*/
void start() {
  while(1) {
    Serial.print('s');
    //Serial.print(mapping(analogRead(A0), 0, 1023, 0, 5),2);
    int value = analogRead(A0);
    float sendvalue = value*5/1023;
    Serial.println(sendvalue);
    delay(20);

    if (Serial.available() > 0) {
      if (Serial.read() == 'Q') return; // leave start() when receive 'Q' command
    }
  }
}

/*Map analog signal
float mapping(float x, float inMin, float inMax, float outMin, float outMax) {
  return (x-inMin)*(outMax - outMin)/(inMax - inMin) + outMin;
}
*/

