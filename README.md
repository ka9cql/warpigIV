# warpigIV
Balloon experiments to obtain gps and temperature telemetry to track oceanic debris..  whatever, I make stuff up
---------
This is our 4th generation of test flight configurations.

This version does APRS reporting over 2 meter FM Amateur Radio (US) frequency 144.390 MHz by sending the Raspberry Pi Zero W's audio output out over the PWM0/PWM1 outputs (Warpig-IV only uses PWM0) and then sending it into the microphone input to a Baofeng 888 modified to transmit based upon VOX input.  ("VOX" means "Voice activated transmit" - any sound coming out of the Pi triggers the '888 to transmit.)

---------
YOU CAN NOT USE THE APRS-REPORTING CODE FROM THIS PROJECT AS-IS!!
---------

The Amateur Radio "callsign" setting that is include in this project's scripts is set to a non-legal value.

This value must be set to a legally-authorized value before use.

It is *not* the responsibility of this repository's author(s) to prevent you from illegally transmitting on an unauthorized frequency.

You have been warned...


DEPENDENCY ALERT!
-----------------
Don't forget to check out the "pifm" git repository and place it in Warpig's /home/pifm directory, and then run "make" on it!

The "pifm" project is used to generate APRS packets using Warpig's real-time sensor data

Don't forget to check out the "direwolf" git repository, place it in Warpig's /home/direwolf directory, and BUILD IT!

IF YOU ARE USING DON (KJ6FO's) FSQ CODE - don't forget to grab his KJ6FO_FSQ.cpp (et al) from his "Flying Squirrels" github account, change the callsign to YOURS and then BUILD IT. You must also symbolically link the KJ6FO_FSQ executable to the /usr/local/bin directory.  (That executable is the one used in the 'testFSQ' shell script.)


BUILD ALERT!
------------
You have to issue a "make readtemp" command while in the directory that contains the "readtemp.c" source code. Then make sure that executable is linked in the /usr/local/bin directory.

That executable is the one that issues I2C commands to read the temperature sensor(s).
