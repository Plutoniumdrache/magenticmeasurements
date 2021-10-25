import serial
import time

def reading():
    incomming = ''
    while True:
            incomming = s.readline() # reading bytes until \n
            if incomming == bytes('', 'utf-8'): # stop reading if no more messages are comming in
                break
            print(str(incomming))    
################################################################################

from serial.serialutil import Timeout

s = serial.Serial('COM7', 115200, timeout=1) # opening the serial connection to the printer
print(s.name)

time.sleep(4) # give him some time

# reading initial stuff from printer
reading()

# inital stuff:
cmd = bytes('G90' + '\n', 'utf-8')
s.write(cmd)
reading()
time.sleep(0.5)

# auto-home
cmd = bytes('G28' + '\n', 'utf-8')
s.write(cmd)
reading()
time.sleep(0.5)

# move z axis:
cmd = bytes('G0 Z20 F500' + '\n', 'utf-8')
s.write(cmd)
reading()
time.sleep(0.5)
for i in range(220):
    print(i)
    cmd = bytes('G0 Y' + str(i) + '\n', 'utf-8')
    s.write(cmd)
    reading()
    for i in range(220, [4]):
        print(i)
        cmd = bytes('G0 X' + str(i) + '\n', 'utf-8')
        s.write(cmd)
        reading()


s.close