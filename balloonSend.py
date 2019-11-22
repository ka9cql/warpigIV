#!/usr/bin/env python

from scapy.all import *
import sys
import subprocess

# Eric's Warpig telemetry collector -
dst_ip1="11.11.11.11"

# Mike's Warpig telemetry collector -
dst_ip2="22.22.22.22"

##data1= "Howdy from balloon!"

# Get last-known-good location (GPS) data
proc = subprocess.Popen('getAPData', stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
data1 = proc.stdout.read().rstrip('\r').rstrip('\n').replace('\n',',')
##print("Acquired data: %s\n" % data1)

data=data1

print("%s" % data)

for src_prt in 53,2947:
	for dst_prt in 53,80,2947:
		##print("Sending s:%d d:%d\n" % (src_prt,dst_prt))

		# Send to dst_ip1 -
		packet1 = IP(dst=dst_ip1)/UDP(dport=dst_prt, sport=src_prt)/data
		send(packet1,verbose=False) 

		# Send to dst_ip2 -
		packet2 = IP(dst=dst_ip2)/UDP(dport=dst_prt, sport=src_prt)/data
		send(packet2,verbose=False) 
quit()

