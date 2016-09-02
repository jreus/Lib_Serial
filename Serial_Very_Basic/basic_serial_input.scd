Server.default = s = Server.internal; s.boot;

s.waitForBoot({

( // Setup port
~baud_rate = 9600;
SerialPort.devicePattern = "/dev/tty.usbmodem*";
~serial_device = SerialPort.devices;
~serial_device = ~serial_device[0];
~serialport = SerialPort(~serial_device, baudrate: ~baud_rate, crtscts: true);
~serialport.doneAction = { postln("OH SHIT, SOMETHING CLOSED THE SERIAL PORT! PLAN B!!"); };
);

( // read 10-bit serial data sent from Arduino's Serial.println
CmdPeriod.add({
	~r_serial.stop;
	~serialport.close;
});

~payloadBytes = 2;

~r_serial = fork {
	var byte, str, res, index = 0, payload = Array.newClear(~payloadBytes), data=0;
	inf.do{|i| 
		while({byte = ~serialport.read; byte.notNil},
			{
				//byte.postln; // debug
				if(index==0 and:{byte==200},{
					index=1;
					},{
					if(index==1 and:{byte==201},{
						index=2;
						},{
						if(index>=2 and:{index<(~payloadBytes + 2)},{
							payload[index-2]=byte;
							index=index+1;
							},{
							if((index==(~payloadBytes + 2)) and:{byte==202},{
								//payload.postln; // debug
								// All seems good. Decode the payload. ms7 bits + ls3 bits
								data = (payload[0]<<3) + (payload[1]);
								("DATA IS: " + data).postln;
								index = 0;
								},{
								
								// Something broke or beginning/restart.
								"Restart".postln;
								index = 0;
								});
							});
						
						});
					});	
			});

/*		
		
		if(~serialport.read == 10, {
			str = "";
			while({ byte = ~serialport.read; byte != 13},
				{ str = str ++ byte.asAscii;});
			res = str.asInteger;
			("READ IN:"+res).postln;
		});
*/
		//wait(1);
	};
};

);
});

