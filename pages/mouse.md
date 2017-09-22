# MOUSE2Go MOUSE System

The folder "M-OS-6502" contains the 6502 part of this project. The software ist written in assembler and
can be assembled with the ophis assembler (https://michaelcmartin.github.io/Ophis/)

## Features

 - monitor program 
 - dump and input memory blocks
 - build in assembler / disassembler
 - VTL2 programming language
 - microchess for gaming

## Get started

See [Arduino Software](/MOUSE2Go/pages/arduino) how to flash the emulator on you Arduino board. 

After the firmware is written to the Arduino, just connect with a serial terminal program to the Arduino board using the serrings 9600 baud, 8N1

The connection should cause a reset on the Arduino and you should get the following output:

```
MOUSE 65C02 micro computer (c) 2017
M-OS V0.3
READY.
MOUSE MON V 0.8


>
```

Be sure to set you terminal programm to send only a CR (carriage return) for a line end and not CR+LF (carriage return plus line feed)

You can now type "h" and hit enter to get a little help for the commands that are supported by the monitor program.

```
h OK
commands:
a <addr> - start assembler at address
c - start microchess
d <addr> - disassemble from address
f <addr>:<addr> %val - fill memory with %val
g <addr> - jump to <addr>
h - this help
i <addr> - input <addr> input data to memory '.' ends the input
m <addr> %cols %rows - dump memory from address
o <addr>:<addr> - output memory range
r - jump to reset vector
s <addr> - show one byte in hex and binary
v - start VTL2 language
 <addr> - 16bit address, %xx - 8 bit value
>
```

See [Examples](/MOUSE2Go/pages/examples) for some detailes of how to use the system.

## Building the ROM image

There's a small shellscript that runs the assembler with all needed options.

## Testing the ROM image

Using the lastet version of py65mon (https://github.com/mnaberez/py65) you can run the generated rom image
also on your local machine with

py65mon -i fff9 -o fff8 -m 6502 -r MOUSE_ROM.bin

