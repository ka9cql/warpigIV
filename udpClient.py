#!/usr/bin/env python

'''
    udp socket server used for collecting telemetry from Warpig

USAGE: python udpClient.py <port_number>

Typically, I ran three copies of this program on three different ports,
which were 53 (DNS), 80 (HTTP) and 2947 (GPSD)

2018-01-30  msipin  Added check for valid payload, as people are abusing this
                    on port 53/1053. Also immediately flush output so no more
                    waiting to see if anything new has arrived.
'''
 
import socket
import sys
 
HOST = ''   # Symbolic name meaning all available interfaces
##PORT = 2947 # Listening port


PORT = int(sys.argv[1])
print("Starting (filtered) responder on port %d\n" % PORT)
 
# Datagram (udp) socket
try :
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    print 'Socket created'
except socket.error, msg :
    print 'Failed to create socket. Error Code : ' + str(msg[0]) + ' Message ' + msg[1]
    sys.exit()
 
 
# Bind socket to local host and port
try:
    s.bind((HOST, PORT))
except socket.error , msg:
    print 'Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1]
    sys.exit()
     
print 'Socket bind complete'
 
#now keep talking with the client
while 1:
    # receive data from client (data, addr)
    d = s.recvfrom(1024)
    data = d[0]
    addr = d[1]
     
    if not data: 
        continue

    if "Frequency" in data.strip():
     
        reply = '    **** ACK ****    Acknowledge Receipt Of: ' + data
     
        s.sendto(reply , addr)
        print 'Message[' + addr[0] + ':' + str(addr[1]) + '] - ' + data.strip()

    else:
        print 'ABUSE DETECTED: [' + addr[0] + ':' + str(addr[1]) + '] - ' + data.strip()

    sys.stdout.flush()
     
s.close()
