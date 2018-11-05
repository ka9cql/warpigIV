#!/usr/bin/python3


#################################################
# Couple ways to use the camera:
#  A) Programs included in Pi - https://www.raspberrypi.org/documentation/raspbian/applications/camera.md
#     raspistill - show camera preview for a second, then take a snapshot and save it to test.jpg -
#         raspistill -v -o test.jpg
#     See also: raspivid and raspistillyuv
#
#  B) Python, using PiCamera.  This is what I elected to do, below. I did it because you can rotate the
#     camera in 90 degree increments (in case it's mounted sideways or up-side-down, etc.), and because
#     controlling it over Python gives us a bit more flexibility.
#################################################

from picamera import PiCamera
from time import sleep

camera = PiCamera()

# If the camera view needs to be rotated, uncomment the following line -
# camera.rotation = 180

# Start the camera, and wait for the user to kill the program by
# pressing Ctrl-C

camera.start_preview()

print("Camera will stay on until you press Ctrl-C...")

while 1:
	try:
		sleep(1000)
	except:
		break

camera.stop_preview()

