The folder "M-OS-6502" contains the 6502 part of this project. The software ist written in assembler and
can be assembled with the ophis assembler (https://michaelcmartin.github.io/Ophis/)

There's a small shellscript that runs the assembler with all needed options.

Using the lastet version of py65mon (https://github.com/mnaberez/py65) you can run the generated rom image
also on your local machine with

py65mon -i fff9 -o fff8 -m 6502 -r MOUSE_ROM.bin

