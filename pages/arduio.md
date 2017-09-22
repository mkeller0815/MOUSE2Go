This part is mainly the 6502 emulator running on the Arduino. The sources are located in the
"Arduino" folder. The folder "arduino_6502_mouse" contains the whole sketch that can be opened directly
by the Arduino IDE.

There is also a shellscript that creates a C header file out of the MOUSE rom image and a symlink to
this image itself.

Note: Currently there's only a 6502 emulated, not an 65C02
