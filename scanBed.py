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
    xExtracted = xExtracted.rstrip()
    if xExtracted.replace('.', '', 1).isdigit():
        x = float(xExtracted)
    else:
        x = -1.0 
    
    # Y position
    yCharacterPos = incomming_str.find('Y')
    yExtracted = incomming_str[yCharacterPos+2:yCharacterPos+7]
    yExtracted = yExtracted.rstrip()
    if yExtracted.replace('.', '', 1).isdigit():
        y = float(yExtracted)
    else:
        y = -1.0
    
    # Z position
    zCharacterPos = incomming_str.find('Z')
    zExtracted = incomming_str[zCharacterPos+2:zCharacterPos+7]
    zExtracted = zExtracted.rstrip()
    if zExtracted.replace('.', '', 1).isdigit():
        z = float(zExtracted)
    else:
        z = -1.0

    position = [x, y, z]
    print(position)
    return position


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
while True:
    pos = getPosition(s)
    time.sleep(0.2)
    if pos == [0.0, 0.0, 0.0]:
        break

# move z axis:
cmd = bytes('G0 Z10 F500' + '\n', 'utf-8')
s.write(cmd)
reading()
time.sleep(0.5)
for i in range(0, 11, 1):
    print(i)
    cmd = bytes('G0 Y' + str(i) + '\n', 'utf-8')
    s.write(cmd)
    reading()

    cmd = bytes('G0 X0' + '\n', 'utf-8') # move x-axis to start position
    s.write(cmd)
    while True:
        pos = getPosition(s)
        if pos[0] == 0.0:
            break

    for i in range(0, 11, 1):
        print(i)
        cmd = bytes('G0 X' + str(i) + '\n', 'utf-8')
        s.write(cmd)
        reading()
    
    
s.close