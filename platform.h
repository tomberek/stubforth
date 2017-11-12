#ifndef PLATFORM_H
#define PLATFORM_H

#include "symbols.h"
#include "stubforth.h"

/* The platform needs to provide my_getchar() and putchar() */
// #include <stdio.h>
#include "serial.h"

static int my_getchar(){return serial_read();}
static int putchar(int c){return serial_write((char)c);}
/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

static void initio()
{
}

#endif
