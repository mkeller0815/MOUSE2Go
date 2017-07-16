import serial
from time import sleep
import sys

device = sys.argv[1]

def readlineCR(port):
    rv = ""
    while True:
        ch = port.read()
        if ch !='':
            rv += ch
        if ch=='\r' or ch=='\n':
            return rv

#open serial port
port = serial.Serial(device, baudrate=9600, timeout=None)

while True:
    print ':'.join(x.encode('hex') for x in readlineCR(port))

