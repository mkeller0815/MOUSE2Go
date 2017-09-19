MOUSE2Go - A 6502 computer emulated by an Arduino
=================================================

## Important note! 

This repository contains software that was not written by me. 


## 1.0 About

MOUSE is an 65C02 based singleboard homebrew computer that
is freely available from another repo: [github - MOUSE] (https://github.com/mkeller0815/MOUSE)

To make it easier to ge started with software, MOUSE can now run on a plain Arduino or compatible board. 

This project uses software kindly provided by others.

 - 6502 emulator for Arduino by Mike Chambers (http://forum.arduino.cc/index.php?topic=193216.0)
 - microchess by Peter Jennings (http://www.benlo.com/microchess/)
 - VTL2 ported to the 6502 by Mike Barry (http://6502.org/source/interpreters/vtl02.htm)
 - 65C02 assembler/disassembler by Jeff Tranter (https://github.com/jefftranter/6502/tree/master/asm)

## 1.1 Arduino Firmware

This part is mainly the 6502 emulator running on the Arduino. The sources are located in the 
"Arduino" folder. The folder "arduino_6502_mouse" contains the whole sketch that can be opened directly
by the Arduino IDE. 

There is also a shellscript that creates a C header file out of the MOUSE rom image and a symlink to 
this image itself. 

Note: Currently there's only a 6502 emulated, not an 65C02

## 1.2 MOUSE Software

The folder "M-OS-6502" contains the 6502 part of this project. The software ist written in assembler and 
can be assembled with the ophis assembler (https://michaelcmartin.github.io/Ophis/)

There's a small shellscript that runs the assembler with all needed options.

Using the lastet version of py65mon (https://github.com/mnaberez/py65) you can run the generated rom image 
also on your local machine with 

py65mon -i fff9 -o fff8 -m 6502 -r MOUSE_ROM.bin

## 2.0 Wiring 

Currently there's no wiring needed. Everything runs in software

## 3.0 Get started

To get started you only need to load the "Arduino/arduino_6502_mouse/arduino_6502_mouse.ino" sketch into
the Arduino IDE and programm your Arduino. 

There's a "#define" for the emulated RAM size, that you can adjust to get more memory for the emulator if
you have an Arduino with more memory (like a Mega2560 or a Due).

After uploading your sketch, you can connect to the Arduino via a serial terminal (or the serial monitor from
the IDE) with 9600,8N1 and play with MOUSE. 

## 4.0 Commands 

If your're connected to the emulated system the following commands can be used:

 - a <addr> - start assembler at address
 - c - start microchess - runs microchess 
 - d <addr> - disassemble from address
 - f <addr>:<addr> %val - fill memory with %val
 - g <addr> - jump to <addr>
 - h - this help
 - i <addr> - input <addr> input data to memory '.' ends the input
 - m <addr> %cols %rows - dump memory from address
 - o <addr>:<addr> - output memory range
 - r - jump to reset vector
 - s <addr> - show one byte as hex and binary 
 - v - start VTL2 language
 <addr> - 16bit address, %xx - 8 bit value

## 5.0 Memory Map

 0x0000 - 0x00ff    Zeropage
 0x0100 - 0x01ff    Stack
 0x0200 - 0x03ff    input buffer used only by VTL2
 0x0400             start of program memroy for VTL2
 0x0200 - 0x7ffb    free memory (upper limit depends on Arduino RAM settings)
 0x7ffc - 0x7ffd    16 bit address used as NMI vector from MIOS kernel (writeable)
 0x7ffe - 0x7fff    16 bit address used as IRQ vector from MIOS kernel (writeable)
 0xe000 - 0xffff    ROM
 
## 6.0 Special Addresses 

 0x7ffc - 0x7ffd    16 bit address used as NMI vector from MIOS kernel (writeable)
 0x7ffe - 0x7fff    16 bit address used as IRQ vector from MIOS kernel (writeable)

 0xfff8             fake ACIA input register
 0xfff9             fake ACIA output register

 0xfffa - 0xfffb    6502 NMI vector
 0xfffc - 0xfffd    6502 RESET vector
 0xfffe - 0xffff    6502 IRQ vector

## 7.0 Using interrupts

The 6502 emulator also supports interrupts. The current setup uses 3 Arduino pins to create 
low active inputs for 

 - NMI   -> digital pin 3
 - IRQ   -> digital pin 4
 - RESET -> digital pin 5

These pins are set as input and pulled high by an internal pullup resistor. Connecting them to GND 
causes the emulator to recognize the input an call the corresponding function. 

The interrupt does nior accure immediately, because the input pins are only checked every X instructions / cycles.
The number set for INSTRUCTIONS_PER_LOOP effects this setting as well as the USE_TIMING setting.

The interrupt vectors are placed in the ROM part of the sytem and therefor they cannot be changed. But the
M-OS has some internal interrupt functions that make an indirect jump using the memory locations

0x7ffc -> soft NMI vector 
0x7ffe -> soft IRQ vector

These vectors are set by the internal reset function to point to an RTI opcode in ROM.

If an NMI occures the OS calls a JMP(0x7ffc), what causes an RTI if the vector was not changed before. 
If an IRQ occures the OS calls a JMP(0x7ffe), what causes an RTI if the vector was not changed before. 

The 4 bytes from 0x7ffc to 0x7fff are not part of the "normal" emulated RAM and so they can be read and written even
if the emulated system has less memory then 32k. This is necessary because the Arduino Uno (ATmega 328) has only 2k of SRAM 
and even the Arduino Mega has only 8k of SRAM. 

To use you own interrupt functions just set the soft vectors to the starting address of your functions. Be aware that a reset just sets
the addresses back to the RTI in ROM. 

The emulator respects the setting of the interrupt flag in the status register of the emulated 6502. If the bit is set the IRQ ist not
executed. An NMI is always executed just as for the real 6502. 

