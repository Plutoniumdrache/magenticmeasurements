import serial
import time

ser = serial.Serial('COM7', 115200)
print(ser.name)

# cmd1 = 'G0 X60 Y80\n'
# cmd2 = 'G28\n'

ser.flushInput()
time.sleep(5)
#ser.write(b'G0 X60 Y80\n')
ser.write(b'G28\n')
time.sleep(5)
ser.close