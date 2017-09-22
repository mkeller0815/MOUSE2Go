
# MOUSE2Go Memorymap

## Basic memory regions 

 - $0000 - $00FF   - Zeropage
 - $0100 - $01FF   - Stack
 - $0200 - $DFFF   - RAM (depends on how much memory is configured)
 - $E000 - $FFFF   - ROM
 
 except $7FFC to $7FFF, see "Soft IRQ and NMI vectors"

## Special addresses

 Some address spaces (zeropage) are used by the assembler, disassembler, chess etc. 
 but only if the programm is executed

## Soft IRQ and NMI vectors

 - $7FFC - $7FFD - soft NMI vector in RAM. Can be used to set own NMI function
 - $7FFE - $7FFF - soft IRQ vector in RAM. Can be used to set own IRQ function

 The MIOS kernel has own NMI and IRQ functions that basically do a JMP($7FFC) and JPM($7FFE).
 Placing the addresses of you own fuction at the soft vectors, they are executed on any interrupt.

 The reset function sets the vectors to an RTI in ROM on any reset or power on.

### Addresses used by MIOS routines

 if your own programm uses routines of the MIOS (Minimal Input Output System) you
 shoul take care for the following addresses

 - 0000 - 001F    - 8 bit, 16 bit variables used by MIOS
 
 - K_STRING_L   $00 ; ZP highbyte of string output address
 - K_STRING_H   $01 ; ZP lowbyte of string output address
 - K_VAR1_L     $02 ; ZP common variable (16 bit)
 - K_VAR1_H     $03
 - K_VAR2_L     $04 ; ZP common variable (16 bit)
 - K_VAR2_H     $05
 - K_VAR3_L     $06 ; ZP common variable (16 bit)
 - K_VAR3_H     $07
 - K_VAR4_L     $08 ; ZP common variable (16 bit)
 - K_VAR4_H     $09
 - K_TMP1       $0A ; ZP temp variable (8bit)
 - K_TMP2       $0B ; ZP temp variable (8bit)
 - K_TMP3       $0C ; ZP temp variable (8bit)
 - K_TMP4       $0D ; ZP temp variable (8bit)
 - K_TMP5       $0E ; ZP temp variable (8bit)

 - 0020 - 002F    - input buffer monitor program
 
### MIOS jump table

 To prevent problems with programs using MIOS routines you should only call the
 routines with a JSR to the jump table entry instead of calling the funtion directly 
 from its memory location. During further development these locations may change and 
 the jump table will be fix.

 - $E000 - j_wstr             write string (address in K_STRING_L,_H) 0-terminated
 - $E003 - j_wchr             write character in A
 - $E006 - j_rchr             read character to A
 - $E009 - j_a2b              parse two ascii characters in buffer to binary number to A
 - $E00C - j_bin8out          write A as 8 bit binary number
 - $E00F - j_hex8out          write A as 8 bit hex number
 - $E012 - j_hex4out          write A as 4 bit hex number
 - $E015 - j_chr2nibble       parse 0-9,A-F,a-f to binary number in A
 
