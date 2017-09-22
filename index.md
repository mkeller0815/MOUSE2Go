---
layout: default
title: Home
---

MOUSE2Go - A 6502 computer emulated by an Arduino
=================================================

## Important note! 

This repository contains software that was not written by me. 


There's now a Youtube video about how to get started: [to the video](https://www.youtube.com/watch?v=ITLRDeyFzFY)


## 1.0 About

MOUSE is an 65C02 based singleboard homebrew computer that
is freely available from another repo: [github - MOUSE](https://github.com/mkeller0815/MOUSE)

To make it easier to ge started with software, MOUSE can now run on a plain Arduino or compatible board. 

This project uses software kindly provided by others.

 - 6502 emulator for Arduino by Mike Chambers : [link to Arduino forum](http://forum.arduino.cc/index.php?topic=193216.0)
 - microchess by Peter Jennings : [microchess](http://www.benlo.com/microchess/)
 - VTL2 ported to the 6502 by Mike Barry : [VTL2](http://6502.org/source/interpreters/vtl02.htm)
 - 65C02 assembler/disassembler by Jeff Tranter : [ASM/DASM](https://github.com/jefftranter/6502/tree/master/asm)

### 1.1 Arduino Firmware

The software for the Arduino is mainly the emulator and a C-Header file containing the current ROM image for the 6502 system. 

For details see : [Arduino software](/MOUSE2Go/pages/arduino)

### 1.2 MOUSE Software

MOUSE is the emulated system that is accessible via a serial connection. It runs a small monitor programm for interaction with the system.

For details see : [MOUSE](pages/mouse) or [examples](/MOUSE2Go/pages/examples)

## 2.0 Get started

To get started you only need to load the "Arduino/arduino_6502_mouse/arduino_6502_mouse.ino" sketch into
the Arduino IDE and programm your Arduino. 

There's a "#define" for the emulated RAM size, that you can adjust to get more memory for the emulator if
you have an Arduino with more memory (like a Mega2560 or a Due).

After uploading your sketch, you can connect to the Arduino via a serial terminal (or the serial monitor from
the IDE) with 9600,8N1 and play with MOUSE. 

There is also a [Youtube video](https://www.youtube.com/watch?v=ITLRDeyFzFY) about getting started.

### 2.1 Commands 

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
 - s <addr> - show one byte of memory as hex and binary  
 - v - start VTL2 language
 <addr> - 16bit address, %xx - 8 bit value

