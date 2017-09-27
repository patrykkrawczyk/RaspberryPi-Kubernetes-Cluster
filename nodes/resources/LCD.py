#!/usr/bin/python
from Adafruit_CharLCD import Adafruit_CharLCD
from time import sleep, strftime
from datetime import datetime
import socket

#  Initialize LCD (must specify pinout and dimensions)
lcd = Adafruit_CharLCD(rs=26, en=19, d4=13, d5=6, d6=5, d7=11, cols=16, lines=2)

def get_ip_address():
    return [
             (s.connect(('8.8.8.8', 53)),
              s.getsockname()[0],
              s.close()) for s in
                  [socket.socket(socket.AF_INET, socket.SOCK_DGRAM)]
           ][0][1]

try:
    while 1:
        lcd.clear()
        ip = get_ip_address()
        lcd.message(datetime.now().strftime('%b %d  %H:%M:%S\n'))
        lcd.message('IP {}'.format(ip))
        sleep(1)
        
except KeyboardInterrupt:
    print('CTRL-C pressed.  Program exiting...')

finally:
    lcd.clear()
