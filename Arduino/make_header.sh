#!/bin/bash

# create C-Header out of the binary image
xxd -i ROMIMAGE.bin > arduino_6502_mouse/rom_image.h


# now adjust the declartion part
sed -i '' 's/unsigned char ROMIMAGE_bin\[\] =/const uchar BIOS\[8192\] PROGMEM =/g' arduino_6502_mouse/rom_image.h

