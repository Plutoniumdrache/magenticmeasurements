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

msg = ''
while msg != 'exit':
    msg = input("Enter your command: ")
    print("Your command was: " + str(msg))
    if msg != 'exit':
        cmd = bytes(msg + '\n', 'utf-8')
        s.write(cmd)
        print("Printer response:\n")
        reading()
        print("\n\n")
    if msg != 'exit':
        time.sleep(1)
s.close