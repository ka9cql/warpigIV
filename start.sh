#!/bin/sh
##################
# start.sh - Script that gets called by /etc/rc.local to startup all the
#            direwolf/APRS/packet BBS/etc. stuff.
#
# HISTORICAL INFORMATION -
#
#  2019-05-17  msipin  Created
#  2019-06-13  msipin  Ensured the channel-changing GPIO pin is set to LOW (e.g.
#                      sets radio to APRS channel) before launching direwolf.
#################

MYCALL="N0CALL-11"

# Ensure the channel-changing GPIO pin is set to LOW
/usr/bin/python /usr/local/bin/channelLo.py


# START DIREWOLF -
cd /home/direwolf
(/usr/bin/nohup /home/direwolf/direwolf -t 0 -qh -qd 2>&1 >> /dev/null)&

# Direwolf opens ports 8000 and 8001

# TO-DO: loop until BOTH tcp port 8000 and tcp port 8001 are in the LISTEN state

/bin/sleep 10

# kissutil REQUIRES Direwolf
# START KISSUTIL -
cd /home/direwolf
(/usr/bin/nohup /home/direwolf/kissutil -f /home/direwolf/outbox/ 2>&1 >> /dev/null)&

/bin/sleep 10

# Then start sendAPRS -
cd /home/pifm
(/usr/bin/nohup /home/pifm/sendAPRS)&

/bin/sleep 5

# /home/kiss/examples/test.py REQUIRES Direwolf *and* Kissutil
# Then start our APRS message-parser/responder
cd /home/pifm
(/usr/bin/nohup /usr/bin/python3 /usr/local/bin/msgparser.py ${MYCALL} 2>&1 >> /usr/local/bin/APRSdata.log)&

/bin/sleep 5

# linbpq REQUIRES Direwolf
# Although Linbpq does not require Kissutil, I would like to start Linbpq after Kissutil, not before
# Then start the LinBPQ Packet BBS system -
cd /home/linbpq
(/usr/bin/nohup /home/linbpq/linbpq 2>&1 >> /dev/null)&

# Linbpq opens ports 8008 and 8010 and 8011

# NOTE: MUST exit with success so /etc/rc.local will not get mad!
exit 0

