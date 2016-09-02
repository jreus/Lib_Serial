/*****************************************

SimpleSerial

Jonathan Reus-Brodsky

Simple Arduino serial communication classes
This framework assumes data transmission as strings, and so is not the most efficient data
transmission system. But for situations where maximum data transmission efficiency is not necessary,
this should be fine.

Updated Feb 15, 2016 - created


****************************************/


SimpleSerial {
	var routine, serialport, event_responders;

	*new {
		^super.new.initme();
	}

	initme {
		CmdPeriod.add({
			this.stopSerial;
		});
		event_responders = ();
	}


	/*******
	addResponder
	Add a new responder function for a given data code.

	data_code - The single character data code that will come from the Arduino to identify the data.
	responder_func - The function to call when data arrives under a given code.
	*******/

	addResponder {|data_code, responder_func|
		event_responders.put(data_code, responder_func);
	}

	/*******
	startSerial
	Start the serial communication / create the connection.
	*******/
	startSerial {|baud=115200, devicePattern="/dev/tty.usbserial*"|
		var setup_serial_func, tmp = SerialPort.devicePattern;

		setup_serial_func = {
			SerialPort.devicePattern = devicePattern;
			Post << "Opening Serial Port " << SerialPort.devices[0] << $\n;
			serialport = SerialPort.new(SerialPort.devices[0], 115200, crtscts: true);
			SerialPort.devicePattern = tmp;

			routine = {
				var datacode, dataval, responder_func;
				2.wait;
				Post << "Starting Serial Routine..." << $\n;
				inf.do {|i|
					datacode = serialport.read();
					responder_func = event_responders[datacode.asAscii];
					if(responder_func.notNil) {
						dataval = this.serialReadIntAsString();
						responder_func.value(dataval);
					} {
						if(datacode != 10) {
							Post << "Unrecognized Data Code " << datacode.asAscii << "(" << datacode << ")" << $\n;
						};
					};
				};
			}.fork(SystemClock);
		};

		if(serialport.notNil) {
			this.stopSerial(setup_serial_func);
		} {
			setup_serial_func.value();
		};

	}


	/*******
	serialReadIntAsString
	Read a string from the incoming serial data and return it as an integer.
	*******/
	serialReadIntAsString {|line_end_byte=13|
		var byte, str="";
		while({byte = serialport.read(); byte != line_end_byte}) {
			str = str ++ byte.asAscii;
		};
		^(str.asInteger);
	}

	/*******
	stopSerial
	Close the serial port and stop the serial reading routine

	finished_func - A function to evaluate once the serial connection has been successfully closed.
	**/
	stopSerial {|finished_func=nil|
		{
			if(routine.notNil) {
				routine.stop;
			};

			if(serialport.notNil) {
				serialport.close;
				Post << "Closing serial port ... ";
				while({serialport.notNil && serialport.isOpen}) {
					// Do nothing...
					0.2.wait;
					Post << ".";
				};
				Post << ".. Done" << $\n;
			};

			if(finished_func.notNil) {
				finished_func.value();
			};
		}.fork(SystemClock);
	}


}

