# MOUSE2Go Arduino Software

* TOC
{:toc}

## Features

 - NMOS 6502 emulated including undocumented opcodes
 - NMI interrupt on Arduino pin 3
 - IRQ interrupt on Arduino pin 4
 - RESET on Arduino pin 5
 - serial input / output 
 - emulates exact cycle counting on demand
 - shows instructions or cycles per second on demand

## Main program

The Arduino firmware is located in the Arduino/arduino_6502_mouse/arduino_6502_mouse.ino
There are two additional files

 - cpu.c is the 6502 emulator providing functions for executing 6502 opcodes, handling memory requests etc.
 - rom_image.h is a 8k byte array with the ROM image of the 6502 system

The Arduino _loop()_ function calls _exec6502(INSTRUCTIONS_PER_LOOP)_ to execute a given number of 6502 instructions (or cycles if USE_TIMING is set; see "defines")

Additionally in every _loop()_ cycle the serial input is checked for a new received character. 

Also the three input pins for NMI, IRQ and RESET are checked in every loop cycle. 

To run the system just open the arduino_6502_mouse.ino file in the Arduino IDE make the settings for the board you are using and programm the board.

### Updating the ROM Image

In the Arduino folder there is a small shell script called _make_header.sh_ that can be used to update the C-Header file for the ROM image. 
If you have changed something in the 6502 code (M-OS-6502 folder) and you created a new ROM image, you need to convert this image (ROMIMAGE.bin) to the rom_image.h file.

The shell script uses the _xxd_ and _sed_ tools to make an ascii hex dump from the image and write it to a correct C syntax header file. 
Therefore this script only works on Mac OS X and Linux at the moment. 

As long as you do not change anything on the ROM image, the code works also in Windows machines

## Using different Arduino boards

The emulator is tested and working on the following boards so far:

 - Arduino Uno (only 1.5k RAM available for the 6502)
 - Arduino Mega (about 6.5k RAM available for the 6502)
 - Arduino Due (32k RAM available und much faster emulation)

Be sure to set the right RAM_SIZE define in the arduino_6502_mouse.ino according to your Arduino board

## How it works

The 6502 emulator provides all needed functions to reset, read memory, write memory and execute 6502 opcodes. 

It also handles two byte arrays as memory within the 64k of address space for the emulated 6502. 

The first one is SRAM and starts from 0x0000. The size ist defined by RAM_SIZE and depends of the ammount of memory of your Arduino board. 
The second byte array is an 8k ROM image the starts from 0xE000 and contains the monitor programm for the 6502 system and some additional software. (See [MOUSE](/MOUSE2Go/pages/mouse))
The read and write functions for memory using either the first or the second array depending on the address of the byte read or written. That causes reads or writes to ROM to be made to the ROM image array located in the flash memory of the Arduino and reads and writes to the RAM are made to the array in the SRAM of the Arduino.

The reset procedure of the 6502 reads a two byte jump address out of its ROM and starts executing the code from this adress. This address points to the start of the monitoring programm for the 6502. 

The emulator also watches two addresses in the ROM area for serial I/O:

 - GETC    0xfff9
 - PUTC    0xfff8

If a byte is written to 0xfff8 it is sent to the Arduino Serial.print() function to write the byte to the serial connection
If a byte is read from 0xfff9 the last byte that was received from the serial connection is given back, or a Zero if no bytes was received.

During the execution of the Arduino _loop()_ function the three pins for NMI, IRQ und RESET are checked (see "Interrupts for the 6502").

## defines

The software can be adjusted by setting several defines in the main Arduino program

 - UNDOCUMENTED - if set the emulator also supports the undocumented opcodes
 - INSTRUCTIONS_PER_LOOP 100 - defines how many instructions / cycles (see USE_TIMING) per loop are executed
 - RAM_SIZE - defines how many SRAM from the Aruino is used the emulate RAM for the 6502 
 - USE_TIMING - if set all other settings referr to cycles instead of instructions
 - SHOW_SPEED - if set every 100.000 instructions / cycles the current speed is calculated

 INSTRUCTIONS_PER_LOOP has some influence to the speed of the emulator. A higher value makes the emulation a little faster, but serial input and interrupt pins are checked not so often.

 RAM_SIZE is an important setting if you are using different Arduino boards. Small boards like the Uno, Mini, Nano etc. have only 2.5k of internal SRAM and so the value for RAM_SIZE should be set to 1536 causing 1.5k of usable memory for the 6502. If you have a bigger board like a Arduino Mega or a Due you can set higher values to have more memory for the emulated system

## Interrupts for the 6502

The Arduino software defines three digital pins (3,4 and 5) as inputs with the internal pullup resistor set. These three pins act as NMI (pin 3), IRQ (pin 4) and RESET (pin 5). 
Because of the internal pullup resistor the pins are low active like the pins on the original 6502 processor. If you connect a pin to GND an NMI, IRQ or RESET is executed if you disconnect the pin from GND (edge triggered). 

The pins are checked once per execurion of the Arduino _loop()_ functions. That causes a little delay, depending on the INSTRUCTIONS_PER_LOOP setting in the Arduino software. 

The emulator also respects the interrupt disable flag for the IRQ of the 6502 set by the SEI / CLI opcodes.


## Speed

If you set the SHOW_SPEED define the emulator will write the calculated instructions (or cycles) per second to the serial output every 100.000 _loop()_ cycles. 

Some testing showed that an 16 MHz Arduino (Uno, Mega, Nano etc.) is able to execute about 66.0000 to 88.000 instructions per second. The speed varies if the opcodes are read from the ROM array or the RAM array. 

An Arduino Due executes about 288.000 instructions per second. 


