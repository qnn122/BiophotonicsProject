//Avr-libc library includes
#include <avr/io.h>
#include <avr/interrupt.h>

bool FLAG = false;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

  // initiate Timer1
  cli();      //disable global interrupts
  TCCR1A = 0; //set entire TCCR1A register to 0
  TCCR1B = 0;

  // Set compare match register to desired timer count:
  OCR1A = 1999;   // fs = 100Hz, 10ms
  //OCR1A = 3999;   // fs = 50Hz, 20ms

  // Turn on CTC mode:
  TCCR1B |= (1 << WGM12);
  
  // Set CS10 and CS12 bits for 8 prescaler;
  TCCR1B |= (1 << CS11); // clock/8

  // enable Timer1 overflow or compare interrupt
  //TIMSK1 = (1 << TOIE1);     // TIMSK = Timer/Counter Interrupt Mask Register
                            // Set TOIE1 -> 1: tells the timer to trigger an interrupt when the timer overflows
  TIMSK1 = (1 << OCIE1A);   // Compare interrupt

  // Enable global interrupts
  sei();
                        
}

void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available() > 0) {
    char re = Serial.read();

    switch(re) {
      case 'E':
        // interrupt function here
        FLAG = true; 
        break;
    }
  }
  
}   // loop()

ISR(TIMER1_COMPA_vect) {
  if (FLAG) {
    //Serial.print(mapping(analogRead(A0), 0, 1023, 0, 5),2);
    int value = analogRead(A0);
    Serial.println(value);

    if (Serial.available() > 0) {
      char re = Serial.read();
      if (re == 'Q') return;
    }
    
  } // if FLAG
} // interrupt

