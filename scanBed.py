import serial
import time

def reading():
    incomming = ''
    while True:
            incomming = s.readline() # reading bytes until \n
            if incomming == bytes('', 'utf-8'): # stop reading if no more messages are comming in
                break
            print(str(incomming, 'utf-8'))




def getPosition(serialConnection):
    # position message example: b'X:19.00 Y:0.00 Z:20.00 E:0.00 Count X:1520 Y:0 Z:8000\n'
    cmd = bytes('M114' + '\n', 'utf-8') # command for getting the current absolute position
    serialConnection.write(cmd)
    incomming = ''
    incomming = serialConnection.readline() # reading bytes until \n
    incomming_str = str(incomming, 'utf-8')
    print("getPos function received: " + incomming_str)
    
    # X Position
    xCharacterPos = incomming_str.find('X')
    xExtracted = incomming_str[xCharacterPos+2:xCharacterPos+7]
    xExtracted.rstrip()
    x = float(xExtracted)
    
    # Y position
    yCharacterPos = incomming_str.find('Y')
    yExtracted = incomming_str[yCharacterPos+2:yCharacterPos+7]
    yExtracted.rstrip()
    y = float(yExtracted)
    
    # Z position
    zCharacterPos = incomming_str.find('Z')
    zExtracted = incomming_str[zCharacterPos+2:zCharacterPos+7]
    zExtracted.rstrip()
    z = float(zExtracted)

    position = [x, y, z]
    print(position)


################################################################################

# Windows version
#s = serial.Serial('COM7', 115200, timeout=1) # opening the serial connection to the printer

# Ubuntu version
s = serial.Serial('/dev/ttyUSB0', 115200, timeout=1) # opening the serial connection to the printer
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
cmd = bytes('G0 Z10 F500' + '\n', 'utf-8')
s.write(cmd)
reading()
time.sleep(0.5)
for i in range(0, 20, 1):
    print(i)
    cmd = bytes('G0 Y' + str(i) + '\n', 'utf-8')
    s.write(cmd)
    reading()
    for i in range(0, 20, 1):
        print(i)
        cmd = bytes('G0 X' + str(i) + '\n', 'utf-8')
        s.write(cmd)
        reading()
    getPosition(s)
    
    
s.close