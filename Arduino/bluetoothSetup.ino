void setup() {
  Serial.begin(9600);     // opens serial port, sets data rate to 9600 bps
  delay(50);
}

void loop() {

        // send data only when you receive data:
        //if (Serial.available() > 0) {
                // read the incoming byte:
                //incomingByte = Serial.read()
                int sensorValue = analogRead(A0);               // read the input on analog pin 0:

                // say what you got:
                //Serial.print("I received: ");
  
  float voltage = sensorValue * (5.0 / 1023.0);   // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
  Serial.println(voltage);                        // print out the value you read:
                
        //}
        delay(1);
}
