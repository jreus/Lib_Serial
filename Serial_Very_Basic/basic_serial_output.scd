Server.default = s = Server.internal;
s.boot;

a = ();
a.baud = 9600; // should match the arduino sketch firmware

( // Setup port..

SerialPort.devicePattern = "/dev/tty.usb*";
a.device = SerialPort.devices;
a.device = (a.device)[0];
a.serialport = SerialPort(a.device, baudrate: a.baud, crtscts: true);
(a.serialport).doneAction = { postln("OH SHIT, SOMETHING CLOSED THE SERIAL PORT! PLAN B!!"); };

CmdPeriod.add({
	a.serialroutine.stop;
	a.serialport.close;
});


)


(

// Send the data..
a.voltage = 2.6;
a.vmax = 3.2;
a.vmin = 1.6;
a.vchange = 0.0196; // 5 / 255 = 0.0196 is the smallest meaningful voltage change on the arduino
// More ideal would be to use the full range..
// and in circuitry scale it and bias it to the proper point for
// triggering the BS170
// here we use a fraction of the full range of the arduino output resolution (which isn't that high to begin with)
a.byteout = 0; // As good a term as any for the arduino's byte-sized PWM output value 255


a.serialRoutine = Routine({
  
  inf.do{|i|
  	// set the value
  	a.byteout = ((a.voltage / 5.0) * 255.0).asInteger;
  
  	// Send it here...
  	a.serialport.put(a.byteout);

/* For more complex stuff.. send as a bundle..   	
p.putAll(Int8Array[13, 10]);

*/
  	// update the voltage
  	a.voltage = a.voltage + a.vchange; 

  	// reverse the direction of the fading at the ends of the fade: 
  	if(((a.voltage < a.vmin) || (a.voltage > a.vmax)),
  		{
    			a.vchange = (a.vchange * -1); 
  		});   
  
  	// wait..  
  	(0.01).wait;  
	  };
}).play;
                
)

