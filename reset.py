#!/usr/bin/python
import serial

ser = serial.Serial("/dev/ttyACM0", 1200)

ser.setRTS(True)  # RTS line needs to be held high and DTR low
ser.setDTR(False) # (see Arduino IDE source code)
ser.close()
