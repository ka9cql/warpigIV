import RPi.GPIO as GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(23,GPIO.OUT)
print "Setting channel-control to HI"
GPIO.output(23,GPIO.HIGH)
