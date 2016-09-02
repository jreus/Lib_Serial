/*
 Based on Dimmer example
 
 Demonstrates the sending data from the computer to the Arduino board,
 in this case to control the brightness of an LED.  The data is sent
 in individual bytes, each of which ranges from 0 to 255.  Arduino
 reads these bytes and uses them to set the brightness of the LED.
 (can be used for any PWM really)
 */

const int outpin = 5;      // by default pin 5/6 have higher freq PWM ~900

void setup()
{
  // initialize the serial communication:
  Serial.begin(9600);
  // initialize the ledPin as an output:
  pinMode(outpin, OUTPUT);
}

void loop() {
  byte brightness;

  // check if data has been sent from the computer:
  if (Serial.available()) {
    // read the most recent byte (which will be from 0 to 255):
    brightness = Serial.read();
    // set the brightness of the LED:
    analogWrite(outpin, brightness);
  }
}
