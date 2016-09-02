

byte val = 0;
unsigned int analogval = 1023; // 10 bit max value from analogRead

void setup()
{
Serial.begin(9600);



}

void loop() {

// Serial.write writes one byte
// Let's see if we can write analog (10-bit) values instead.
//Serial.write(val++);
Serial.write(200);  // Header bytes. Since we're chopping everything to <7 bits..
Serial.write(201);  // Anything above 127 must be metadata.
serialWrite10Bit(analogval);
Serial.write(202);  // End byte packet
delay(100);

}

void serialWrite10Bit(unsigned int val) {
  Serial.write(val>>3); // Send the most significant 7 bits
  Serial.write(val&7); // Send the least significant 3 bits
}
