#include <Arduino.h>
#include "serial.h"
// #include "stubforth.h"
// #include "libforth.h"

extern "C" int fmain();
extern "C" int fsetup();
extern "C" int fstep();

int readline(int, char*, int);

extern "C" void setup(void){
    Serial.begin(9600);
    delay(100);
    Serial.write('#');
    fsetup();
    Serial.write('!');
}

// static char readline_buffer[80];
// static int readline_buffer_ind;
extern "C" void loop(void){
    // static int res;
    if (readline(Serial.read(), readline_buffer, 80) > 0) {
        Serial.print("You entered: >");
        Serial.print(readline_buffer);
        Serial.println("<");
        fstep();
    }
}

extern "C" void serial_begin(unsigned long baud){Serial.begin(baud);}
extern "C" char serial_read(){return Serial.read();}
extern "C" int serial_write(char c){return Serial.write(c);}
extern "C" int serial_println(char *c){return Serial.println(c);}
extern "C" int serial_write_long(long c){return Serial.write(c);}

int readline(int readch, char *buffer, int len)
{
  static int pos = 0;
  int rpos;

  if (readch > 0) {
    switch (readch) {
      case '\n': // Ignore new-lines
        break;
      case '\r': // Return on CR
        rpos = pos;
        pos = 0;  // Reset position index ready for next time
        return rpos;
      default:
        if (pos < len-1) {
          buffer[pos++] = readch;
          buffer[pos] = 0;
        }
    }
  }
  // No end of line has been found, so return -1.
  return -1;
}
