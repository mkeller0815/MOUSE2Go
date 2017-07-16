import serial
from time import sleep
import sys

#print 'Number of arguments:', len(sys.argv), 'arguments.'
#print 'Argument List:', str(sys.argv)

device = sys.argv[1]
startaddress = sys.argv[2]
filename = sys.argv[3]

print "uploading file \"%s\" at %s" % (filename, startaddress)

def readlineCR(port):
    rv = ""
    while True:
        ch = port.read()
        if ch=='\r' or ch=='\n':
            return rv
        if ch !='':
            rv += ch

#open serial port
port = serial.Serial(device, baudrate=9600, timeout=0)

#initiate file transfer
port.write("\0")

ret = readlineCR(port)
print ret 
#if ret == "Filetransfer detected:":
if ret == "hello":
    start = int(startaddress,16)
    h = start >> 8
    print h
    l = start & 0xff
    print l

