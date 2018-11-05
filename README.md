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

