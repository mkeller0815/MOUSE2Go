MOUSE2Go - A 6502 computer emulated by an Arduino
=================================================

## Important note! 

This repository contains software that was not written by me. 


## 1.0 About

MOUSE is an 65C02 based singleboard homebrew computer that
is freely available from another repo: [github - MOUSE](https://github.com/mkeller0815/MOUSE)

To make it easier to ge started with software, MOUSE can now run on a plain Arduino. 

This project uses software kindly provided by others.

 - 6502 emulator for Arduino by Mike Chambers (http://forum.arduino.cc/index.php?topic=193216.0)
 - microchess by Peter Jennings (http://www.benlo.com/microchess/)
 - VTL2 ported to the 6502 by Mike Barry (http://6502.org/source/interpreters/vtl02.htm)
 - 65C02 disassembler by Jeff Tranter (https://github.com/jefftranter/6502/tree/master/asm/disasm)

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

There's a small shellscript that runns the assembler with all needed options.

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

 - a <addr> %cols %rows - ascii dump from address with %columns and %rows
 - c - start microchess - runs microchess 
 - d <addr> - disassemble from address
 - f <addr>:<addr> %val - fill memory with %val
 - g <addr> - jump to <addr>
 - h - this help
 - i <addr> - input <addr> input data to memory '.' ends the input
 - m <addr> %cols %rows - dump memory from address
 - o <addr>:<addr> - output memory range
 - r - jump to reset vector
 - v - start VTL2 language
 <addr> - 16bit address, %xx - 8 bit value

