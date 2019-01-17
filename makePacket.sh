#!/bin/sh
######################
# makePacket.sh - Create the audio output file for an APRS position report
#
# HISTORICAL INFORMATION -
#
#  2018-02-12  msipin  (Circa) - Created.
#  2018-02-20  msipin  Ensured leading zeros in lat and lon. Added ability to convert some
#                      GPS's "non-NMEA" (aka decimal) LAT/LON values into NMEA-compatible
#                      format.
#  2018-02-22  msipin  Trimmed output, tried specifying Keller (Keller Peak) repeater in path
#  2018-06-04  msipin/epowell  Adapted for St. Louis testing, and for using AGW/AGPE (spelling?)
#  2018-11-01  msipin/epowell  Adjusted for using Baofeng 888 as transmitter, rather than BCM built-in oscillator
#  2018-11-04  msipin/epowell  Bumped up to "Warpig-IV" - otherwise same as prior (NOTE: THIS MEANS that this
#                              version will work with *both* Baofeng 888 + VOX and the BCM internal oscillator
#                              to generate APRS position reports.)
#  2019-01-16  msipin          Replaced my call with "N0CALL". Allowed multiple temperatures to be transmitted.
######################

# All last-known-good data will be written to files in the following directory -
LAST_KNOWN_GOOD_DIR=/usr/local/bin

# If need to convert GPS output to "NMEA-compatible" format, set the following
# variable to "1". IF NOT, set it to "0" -
GPS_TO_NMEA=1	# NOTE: "ORIG GPS's" = 0, "Microcenter GPS" =1

AUDIO_FILE="packet.Loc.wav"

VERBOSE="1"

if [ $# -ge 1 -a ""$1"" = "-q" ]
then
	#echo
	#echo "DEBUG: QUIET MODE"
	VERBOSE="0"
fi



# Your callsign (MANDATORY!) - Use "dash-eleven" ("-11") to automatically mark as a balloon
MYCALL="N0CALL-11"

# Desired -
# ZULU_DDHHMM="110736"
ZULU_DDHHMM=`date "+%d%H%M"`

# Latitude, format: hhmm.ssN (or  hhmm.ssS)
# Desired -
#LAT="3429.57N"
# What is in the last-known-good file -
# 34.492745,N
##echo "DEBUG: READ-LAT: `cat ${LAST_KNOWN_GOOD_DIR}/lat`"
# If need to convert GPS format to "NMEA format"...
if [ ""$GPS_TO_NMEA"" = "1" ]
then
    DEG=`cat ${LAST_KNOWN_GOOD_DIR}/lat | awk -F"," '{ printf "%d",int($1); }'`
    PRT=`cat ${LAST_KNOWN_GOOD_DIR}/lat | awk -F"," '{ printf "%.4f",($1-int($1)); }'`
    MIN=`echo ${PRT} | awk '{ printf "%2.4f",($1*60.0); }'`
    N_S=`cat ${LAST_KNOWN_GOOD_DIR}/lat | awk -F"," '{ print $2 }'`
    ##echo "DEBUG: DEG: ${DEG}"
    ##echo "DEBUG: PRT: ${PRT}"
    ##echo "DEBUG: MIN: ${MIN}"
    ##echo "DEBUG: N_S: ${N_S}"
    LAT=`echo ${DEG} ${MIN} ${N_S} | awk '{ printf "%04d.%02d%s",int($1*100+$2),int((($1*100+$2)-int($1*100+$2))*100),toupper($3); }'`
else
    LAT=`cat ${LAST_KNOWN_GOOD_DIR}/lat | awk -F"," '{ printf "%04d.%02d%s",int($1*100),int((($1*100)-int($1*100))*100),toupper($2); }'`
fi
##echo "DEBUG:      LAT: ${LAT}"

# Longitude, format: hhh.mmssssss.00W (or hhh.mmssssss.00E)
# Desired -
# LON="11740.87W"
# What is in the last-known-good file -
# 117.407627,W
##echo "DEBUG: READ-LON: `cat ${LAST_KNOWN_GOOD_DIR}/lon`"
# If need to convert GPS format to "NMEA format"...
if [ ""$GPS_TO_NMEA"" = "1" ]
then
    DEG=`cat ${LAST_KNOWN_GOOD_DIR}/lon | awk -F"," '{ printf "%d",int($1); }'`
    PRT=`cat ${LAST_KNOWN_GOOD_DIR}/lon | awk -F"," '{ printf "%.4f",($1-int($1)); }'`
    MIN=`echo ${PRT} | awk '{ printf "%2.4f",($1*60.0); }'`
    E_W=`cat ${LAST_KNOWN_GOOD_DIR}/lon | awk -F"," '{ print $2 }'`
    ##echo "DEBUG: DEG: ${DEG}"
    ##echo "DEBUG: PRT: ${PRT}"
    ##echo "DEBUG: MIN: ${MIN}"
    ##echo "DEBUG: E_W: ${E_W}"
    LON=`echo ${DEG} ${MIN} ${E_W} | awk '{ printf "%05d.%02d%s",int($1*100+$2),int((($1*100+$2)-int($1*100+$2))*100),toupper($3); }'`
else
    LON=`cat ${LAST_KNOWN_GOOD_DIR}/lon | awk -F"," '{ printf "%05d.%02d%s",int($1*100),int((($1*100)-int($1*100))*100),toupper($2); }'`
fi
##echo "DEBUG:      LON: ${LON}"


# Altitude in feet ASL, format: nnnnnn
# Desired -
# ALT="003285"
# What is in the last-known-good file -
# 985.10,M
ALT=`cat ${LAST_KNOWN_GOOD_DIR}/alt | awk -F"," '{ printf "%06d",int($1*3.3); }'`

# Temperature (degrees F) - ONE SENSOR -
#DEGF=`cat ${LAST_KNOWN_GOOD_DIR}/temp | awk -F"," '{ printf "Temp. %d %s",$3,toupper($4); }'`
# Temperature (degrees F) - TWO SENSORS -
DEGF=`cat ${LAST_KNOWN_GOOD_DIR}/temp | awk -F"," '{ printf "Temps %d/%d %s",$3,$7,toupper($4); }'`

# Course (heading), in degrees format: ddd
HDG="090"

# Speed in MPH, format: sss
SPD="001"

# Message, freeform: "This is a message"
MSG="Warpig-VI telemetry "


rm -f $AUDIO_FILE
rm -f z.txt

# aprs.dat file contents - 
## N0CALL-2>APNXXX:#First test packet
## N0CALL-2>APNXXX,WIDE1-1:/090738z3449.27N/11740.79WOWarpig-III balloon/A=003285
## N0CALL-2>APNXXX,WIDE2-2:/090738z3449.27N/11740.79WOWarpig-III balloon/A=003285
## N0CALL-2>APNXXX,WIDE3-3:/090738z3449.27N/11740.79WOWarpig-III balloon/A=003285
## N0CALL-2>APNXXX:#Next-to-last test packet
## N0CALL-2>APNXXX:#Last test packet


## USING APRS (can't yet get or build it for Pi Zero...) -
## aprs -c ${MYCALL} -o AUDIO_FILE "/${ZULU_DDHHMM}z${LAT}/${LON}>${HDG}/${SPD}${MSG}/A=${ALT} ${DEGF}"


## Using direwolf -
########
##gen_packets -o packet.Loc.wav -r 44100 aprs.dat

#echo "${MYCALL}>APNXXX:#First test packet" >> z.txt

## THE FOLLOWING WORKED, GREAT! -
###echo "${MYCALL}>APNXXX:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
##echo "${MYCALL}>APNXXX,WIDE1-1:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
##echo "${MYCALL}>APNXXX,WIDE2-2:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
##echo "${MYCALL}>BEACON:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
###echo "${MYCALL}>BEACON,WIDE2-2:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
###echo "${MYCALL}>BEACON,WIDE1-1:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt

# THE CURRENT MOBILE STANDARD - echo "${MYCALL}>WIDE1-1,WIDE2-1:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
##echo "${MYCALL}>BEACON,WIDE1*:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
##echo "${MYCALL}>BEACON,WIDE2-1:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt

## 2018-11-02 WORKS AGAINST KELLER, from home with chimney 2m/440 antenna (NOTE: MUST BE REPEATED 2x FOR VOX!)
##echo "${MYCALL}>BEACON,WIDE1-1:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
##echo "${MYCALL}>BEACON,WIDE1-1:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt

## 2018-11-03 Tried this because we're launching at night, and theorize we'll need more help getting
##            into an iGate (NOTE: DON'T FORGET TO DO IT 2x FOR Baofeng 888 + VOX!)
## 2018-11-04  IT JUST SO HAPPENS that this same z.txt file format will work with *BOTH* the
##             Baofeng 888 + VOX and the BCM built-in oscillator!!!
echo "${MYCALL}>BEACON,WIDE2-1:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
echo "${MYCALL}>BEACON,WIDE2-1:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt



## Match Eric's radio output - WORKS on my house chimney 2m/440 antenna
##echo "${MYCALL}>APDR10,WIDE1-1:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
##echo "${MYCALL}>APDR10,WIDE1-1:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt




##echo "${MYCALL}>BEACON,WIDE3-3:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
##echo "${MYCALL}>BEACON,WIDE1-1:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
##echo "${MYCALL}>WIDE1-1,WIDE2-1:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt
###echo "${MYCALL}>KELLER,WIDE1*,WIDE2:/${ZULU_DDHHMM}z${LAT}/${LON}O${MSG}/A=${ALT} ${DEGF}" >> z.txt

## FOR SOME REASON, the last packet does not seem to send properly when sent using BCM built-in oscillator, so put one or two
## more with "gibberish" to flush the others
###echo "${MYCALL}>APNXXX:#Next-to-last test packet" >> z.txt
##echo "${MYCALL}>APNXXX:#Last test packet" >> z.txt

gen_packets -o ${AUDIO_FILE} -r 44100 z.txt


if [ ""$VERBOSE"" = "1" ]
then
	# Test the result to see if it worked -
	echo
	echo "Testing encoding..."
	atest ${AUDIO_FILE}
	echo

	echo
	echo "To transmit the file you just built over the air as 2m APRS"
	echo "position reports, do this - "
	echo
	echo "    pifm ${AUDIO_FILE} 144.394157 44100 mono 4"
	echo
fi


# Reset the screen (direwolf insists on changing its fg/bg colors!)
#tput reset

exit 0


Usage: gen_packets [options] [file]
Options:
  -a <number>   Signal amplitude in range of 0 - 200%.  Default 50.
  -b <number>   Bits / second for data.  Default is 1200.
  -B <number>   Bits / second for data.  Proper modem selected for 300, 1200, 2400, 4800, 9600.
  -g            Scrambled baseband rather than AFSK.
  -m <number>   Mark frequency.  Default is 1200.
  -s <number>   Space frequency.  Default is 2200.
  -r <number>   Audio sample Rate.  Default is 44100.
  -n <number>   Generate specified number of frames with increasing noise.
  -o <file>     Send output to .wav file.
  -8            8 bit audio rather than 16.
  -2            2 channels (stereo) audio rather than one channel.

An optional file may be specified to provide messages other than
the default built-in message. The format should correspond to
the standard packet monitoring representation such as,

    WB2OSZ-1>APDW12,WIDE2-2:!4237.14NS07120.83W#

Example:  gen_packets -o x.wav 

    With all defaults, a built-in test message is generated
    with standard Bell 202 tones used for packet radio on ordinary
    VHF FM transceivers.

Example:  gen_packets -o x.wav -g -b 9600
Shortcut: gen_packets -o x.wav -B 9600

    9600 baud mode.

Example:  gen_packets -o x.wav -m 1600 -s 1800 -b 300
Shortcut: gen_packets -o x.wav -B 300

    200 Hz shift, 300 baud, suitable for HF SSB transceiver.

Example:  echo -n "WB2OSZ>WORLD:Hello, world!" | gen_packets -a 25 -o x.wav -

    Read message from stdin and put quarter volume sound into the file x.wav.

