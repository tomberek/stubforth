-include config.mak

GAS ?= avr-ld
GCC ?= avr-g++
CFLAGS ?= -g -Os -Wall -Wcast-align -mmcu=atmega32u4 -std=gnu11 -ffunction-sections -fdata-sections -MMD -flto -fno-fat-lto-objects 
SYNC ?= -s
AVRDUDE=avrdude -Cavrdude.conf -v -V -patmega32u4 -cavr109 -P/dev/ttyACM0 -b57600 -D -U flash:w:

INCLUDES ?= -I/home/dev/Downloads/arduino-1.8.4/hardware/arduino/avr/cores/arduino -I/home/dev/.arduino15/packages/SparkFun/hardware/avr/1.1.7/variants/promicro

DEFINES ?= -DF_CPU=16000000L -DARDUINO=10804 -DARDUINO_AVR_PROMICRO -DARDUINO_ARCH_AVR  -DUSB_VID=0x1b4f -DUSB_PID=0x9206 -DUSB_MANUFACTURER="tomberek" -DUSB_PRODUCT="SparkForth"
# '-DUSB_MANUFACTURER="Unknown"' '-DUSB_PRODUCT="SparkFun Pro Micro"'
#DEFINES ?= -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD -flto -mmcu=atmega32u4 -DF_CPU=16000000L -DARDUINO=10804 -DARDUINO_AVR_PROMICRO -DARDUINO_ARCH_AVR  -DUSB_VID=0x1b4f -DUSB_PID=0x9206 -DUSB_MANUFACTURER="tomberek" -DUSB_PRODUCT="SparkForth" 
all: stubforth.hex

config.h: .rev.h

.rev.h: .git/* .
	echo -n \#define REVISION \"  > $@
	echo -n $$(git describe --always --dirty) >> $@
	echo  '"' >> $@
	echo -n \#define COMPILER \"  >> $@
	echo -n "$$($(GCC) --version|sed q)" >> $@
	echo  '"' >> $@

serial.o:  serial.cpp serial.h
	$(GCC) $(CFLAGS) $(INCLUDES) $(DEFINES) -o $@ -c -x c++ $<

stubforth.o:  stubforth.c *.h Makefile *.m4 config.h symbols.h platform.h
	$(GCC) $(CFLAGS) $(INCLUDES) $(DEFINES) -o $@ -c -x c $<

stubforth.s:  stubforth.c *.h Makefile *.m4 config.h symbols.h platform.h
	$(GCC) $(CFLAGS) $(INCLUDES) $(DEFINES) -o $@ -S $<

stubforth.elf: serial.o stubforth.o core1.a
	$(GCC) $(CFLAGS) $(INCLUDES) $(DEFINES) -o $@ $^

stubforth.hex: stubforth.elf
	avr-objcopy -O ihex -R .eeprom $< $@

stubforth: stubforth.elf
	cp $< $@

upload: stubforth.hex
	./reset.py ; sleep 1 ; $(AVRDUDE)$<


%.size: % size.sh
	. ./size.sh $<
	strip $<
	ls -l $<
	size $<

%.c: %.c.m4 Makefile *.m4
	m4 $(SYNC) $< > $@

term:
	stty -F /dev/ttyACM0 speed 9600 ; minicom -b9600 -D/dev/ttyACM0

dump: stubforth.elf
	avr-objdump -m avr5 $< -rzDsS | less

check: stubforth
	expect test.tcl

clean:
	rm -f symbols.h symbols.4th symbols.gdb
	rm -f TAGS
	rm -f *grind.out.* stubforth
	rm -f .rev.h *.o *.s stubforth.c
	rm -f *.vcg
	rm -f *.hex

symbols.%: symto%.m4 symbols.m4
	m4 $< > $@

dev:	symbols.gdb TAGS

TAGS: .
	ctags-exuberant -e  --langdef=forth --langmap=forth:.4th.m4 \
	--regex-forth='/: *([^ ]+)/\1/' \
	--regex-forth='/(primary|secondary|constant|master)\([^,]+, ([^,\)]+)/\2/' \
	--regex-forth='/(primary|secondary|constant|master)\(([a-z0-9_]+)/\2/' \
	 *.4th *.c.m4 *.m4
	shopt -s nullglob; ctags-exuberant -e -a --language-force=c *.c *.h *.m4

%.o : %.4th
	$(OBJCOPY) -I binary -B arm -O elf32-littlearm \
	 --rename-section .data=.rodata,alloc,load,readonly,data,contents \
	 $< $@

.PRECIOUS: %.s %.o %.S
