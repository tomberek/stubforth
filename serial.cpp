#include <Arduino.h>
#include <stdio.h>
#include <stdlib.h>
// #include "stubforth.h"

extern "C" int fmain();
extern "C" int fsetup();
extern "C" int fstep();

extern "C" void setup(void){
    Serial.begin(9600);
    delay(100);
    Serial.write('#');
    fsetup();
    Serial.write('!');
}

extern "C" void loop(void){
    delay(100);
    Serial.write('0');
    // fmain();
}

extern "C" void serial_begin(unsigned long baud){Serial.begin(baud);}
extern "C" char serial_read(){return Serial.read();}
extern "C" int serial_write(char c){return Serial.write(c);}
extern "C" int serial_write_long(long c){return Serial.write(c);}
