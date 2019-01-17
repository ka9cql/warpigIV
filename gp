#!/bin/sh
##################
# getpos - Show the current GPS position 
#
# HISTORICAL INFORMATION -
#
#  2018-01-17  msipin/epowell  Created
#  2018-01-18  msipin          Added support for GPGLL sentence. Fixed bug whereby did not
#                              use the ${DEV} variable anywhere (doh!).
#  2018-01-21  msipin/epowell  Added altitude field. Added timestamp.
#################

# Eric's Bluetooth GPS Keychain - Works with only 10 lines
#DEV=/dev/rfcomm4
# Stratux USB GPS dongle - NEEDS 60 LINES TO DECODE !!!
DEV=/dev/ttyACM0
# Eric's "SKYRC" USB GPS + data-logger device
#DEV=/dev/ttyUSB0
# DIYmall VK18U7 serial device - NEEDS ABOUT 20 LINES! (FAILED! Likely due to static shock)
# Stratux wired directly to UART/serial - NEEDS 60 LINES TO DECODE !!!
#DEV=/dev/serial0


##      $1      $2      $3   $4       $5  $6   (IF NF > 6 and $6-NOT-"A", $6 is TIME) (THERE IS NO ALTITUDE DATA IN $GPGLL)
##    $GPGLL,3429.57264,N,11724.45153,W,A*xx
##    $GPGLL,3429.57264,N,11724.45153,W,000426.00,A*xx
##    $GPGLL,3429.57264,N,11724.45153,W,000426.00,A,A*72

##            $2     $3    $4   $5       $6 $7 $8  $9   $10  $11 (ALTITUDE IS $10, $11 F/M)
##    $GPGGA TIME 3429.5651 N 11724.4548 W  2  11 0.89 334.2 M
##

##            $2  $3   $4     $5  $6       $7   (THERE IS NO ALTITUDE DATA IN $GPRMC)
##    $GPRMC TIME A 3429.5651 N 11724.4548 W spd/knots  true-course datestamp variation e/w

##  if ($1 == "$GPGGA")		print $3","$4","$5","$6","$10","$11 - $10=ALT, $11=F/M
##  if ($1 == "$GPRMC")		print $4","$5","$6","$7","ALT","F/M
##  if ($1 == "$GPGLL")		print $2","$3","$4","$5","ALT","F/M


# grep -v "NMEA unknown msg" ${DEV} | head -40 | egrep "GPGGA|GPRMC|GPGLL" | head | awk -F"," '{
# Stratus needs "head -60"
# VK18U7 needs about -30 (lots of "GPSTXT" messages)
head -10 ${DEV} | egrep "GPGGA|GPRMC|GPGLL" | head | awk -F"," 'BEGIN {

	LAT="0.0"
	LAT_NS="U"
	LON="0.0"
	LON_EW="U"
	ALT="0.0"
	F_M="U"
}
{

LAT=0
LAT_EXT=0.0
LON=0
LON_EXT=0.0

if ($1 == "$GPGLL") {
	##print $1" - "$2","$3","$4","$5","ALT","F/M

	LAT=($2/100)
	LON=($4/100)

	LAT_NS=$3
	LON_EW=$5
}


if ($1 == "$GPGGA") {
	##print $1" - "$3","$4","$5","$6,"$10","$11 - $10=ALT, $11=F/M

	LAT=($3/100)
	LON=($5/100)

	# $GPGGA is the only GPS sentence that has altitude and ft/m fields -
	ALT=$10
	F_M=$11

	LAT_NS=$4
	LON_EW=$6
}


if ($1 == "$GPRMC") {
	##print $1" - "$4","$5","$6","$7","ALT","F/M

	LAT=($4/100)
	LON=($6/100)

	LAT_NS=$5
	LON_EW=$7
}


if ((LAT > 0.00) && (LON > 0.00)) {
	LAT_DEG=int(LAT)
	LAT_EXT=((LAT - LAT_DEG)*100)
	##LAT_MIN=int(LAT_EXT)
	##LAT_SEC=((LAT_EXT - LAT_MIN)*100)
	##printf "LAT_DEG=%d\n",LAT_DEG
	##printf "LAT_EXT=%d\n",LAT_EXT
	##printf "LAT_MIN=%d\n",LAT_MIN
	##printf "LAT_SEC=%2.2f\n",LAT_SEC


	LON_DEG=int(LON)
	LON_EXT=((LON - LON_DEG)*100)
	##LON_MIN=int(LON_EXT)
	##LON_SEC=((LON_EXT - LON_MIN)*100)
	##printf "LON_DEG=%d\n",LON_DEG
	##printf "LON_EXT=%d\n",LON_EXT
	##printf "LON_MIN=%d\n",LON_MIN
	##printf "LON_SEC=%2.2f\n",LON_SEC

	LAT=LAT_DEG + (LAT_EXT/60)
	LON=LON_DEG + (LON_EXT/60)

}

printf "%02.6f,%s,%03.6f,%s,%05.2f,%s\n",LAT,LAT_NS,LON,LON_EW,ALT,F_M

}
END {

printf "%02.6f,%s,%03.6f,%s,%05.2f,%s\n",LAT,LAT_NS,LON,LON_EW,ALT,F_M

}'
####}' | tee out.txt
####}' | sort -u | grep "," | tail -1

# OUTPUT OF THE ABOVE (without sort or sort-unique, and tail) -
#  Sun 21 Jan 20:50:49 UTC 2018
#      34.492780,N,117.407648,W,00.00,U
#      34.492780,N,117.407648,W,992.00,M
#      34.492780,N,117.407648,W,992.00,M
#  Sun 21 Jan 20:50:50 UTC 2018
#      0.000000,U,0.000000,U,00.00,U
#  Sun 21 Jan 20:50:51 UTC 2018
#      0.000000,U,0.000000,U,00.00,U
#  Sun 21 Jan 20:50:52 UTC 2018
#      34.492780,N,117.407647,W,00.00,U
#      34.492780,N,117.407647,W,992.40,M
#      34.492780,N,117.407647,W,992.40,M
#  Sun 21 Jan 20:50:52 UTC 2018
#      0.000000,U,0.000000,U,00.00,U
#  Sun 21 Jan 20:50:53 UTC 2018
#      0.000000,U,0.000000,U,00.00,U


exit 0
