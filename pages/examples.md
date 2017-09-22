# MOUSE2Go MOUSE Examples

Here are some examples of how to use certain features of MOUSE

In the monitor program, you can always call "h" for help to get a list of all commands.

All commands start with a single character. Some of them have also parameters.

* TOC
{:toc}

## Show memory

There are three commands to get a parts of the memory shown.

### memdump

```
>m e000 10 0a OK
e000 4c b3 fc 4c c7 fc 4c cb fc 4c d3 fc 4c 63 fc 4c |L..L..L..L..Lc.L|
e010 76 fc 4c 83 fc 4c a1 fc a9 c6 85 00 a9 e2 85 01 |v.L..L..........|
e020 20 00 e0 20 22 e2 20 16 e2 20 06 e0 b0 fb c9 0d | .. ". .. ......|
e030 f0 15 c9 0a f0 11 20 03 e0 a6 0f 95 10 e8 86 0f |...... .........|
e040 e0 20 f0 03 4c 29 e0 a2 00 b5 10 dd 98 e0 f0 28 |. ..L).........(|
e050 e8 ec 97 e0 d0 f5 a9 d8 85 00 a9 e2 85 01 20 00 |.............. .|
e060 e0 48 a9 22 20 03 e0 68 20 03 e0 a9 22 20 03 e0 |.H." ..h ..." ..|
e070 a9 20 20 03 e0 4c 94 e0 a9 ec 85 00 a9 e2 85 01 |.  ..L..........|
e080 20 00 e0 8a 0a aa bd a4 e0 85 02 e8 bd a4 e0 85 | ...............|
e090 03 6c 02 00 4c 23 e0 0c 61 63 64 66 67 68 69 6d |.l..L#..acdfghim|
```

The command _m_ takes three parameters. The first is the address were dumping the memory should start. The second parameter is one byte (hex) giving the number of bytes per line to be shown on the output. And the last paramerer takes the number of lines to be shown. 

In the example the output start at $e000 with $10 (16) bytes per line and $0a (10) lines to show. 

The command shows the hex values as well as the ASCII characters (if printable or a '.' otherwise)

### output memory 

```
>o e000:e09f OK
4c b3 fc 4c c7 fc 4c cb fc 4c d3 fc 4c 63 fc 4c 
76 fc 4c 83 fc 4c a1 fc a9 c6 85 00 a9 e2 85 01 
20 00 e0 20 22 e2 20 16 e2 20 06 e0 b0 fb c9 0d 
f0 15 c9 0a f0 11 20 03 e0 a6 0f 95 10 e8 86 0f 
e0 20 f0 03 4c 29 e0 a2 00 b5 10 dd 98 e0 f0 28 
e8 ec 97 e0 d0 f5 a9 d8 85 00 a9 e2 85 01 20 00 
e0 48 a9 22 20 03 e0 68 20 03 e0 a9 22 20 03 e0 
a9 20 20 03 e0 4c 94 e0 a9 ec 85 00 a9 e2 85 01 
20 00 e0 8a 0a aa bd a4 e0 85 02 e8 bd a4 e0 85 
03 6c 02 00 4c 23 e0 0c 61 63 64 66 67 68 69 00.
```
The command _o_ takes a pair auf 16bit addresses as parameter separated by a ':' to write out a block of memory as hex values.
A linebreak is printed after 16 bytes and after the last byte a dot ('.') is shown. 

This command can be used to save a block of memory with your terminal program. Just copy-paste the block to a separate file of let your terminal program write the output to a file right before hitting "Enter" on the command.

There's a corresponding input command to read such a block back zu memory 

### show byte

```
>s e000 OK
4c 01001100
```

The command _s_ take a 16bit address as parameter and shows the corresponding byte on this address as hex value as well as binary value

## Input data

### input memory

```
>m 0400 10 0a OK
0400 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |................|
0410 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |................|
0420 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |................|
0430 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |................|
0440 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |................|
0450 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |................|
0460 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |................|
0470 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |................|
0480 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |................|
0490 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |................|

>i 0400 OK
4c b3 fc 4c c7 fc 4c cb fc 4c d3 fc 4c 63 fc 4c 
76 fc 4c 83 fc 4c a1 fc a9 c6 85 00 a9 e2 85 01 
20 00 e0 20 22 e2 20 16 e2 20 06 e0 b0 fb c9 0d 
f0 15 c9 0a f0 11 20 03 e0 a6 0f 95 10 e8 86 0f 
e0 20 f0 03 4c 29 e0 a2 00 b5 10 dd 98 e0 f0 28 
e8 ec 97 e0 d0 f5 a9 d8 85 00 a9 e2 85 01 20 00 
e0 48 a9 22 20 03 e0 68 20 03 e0 a9 22 20 03 e0 
a9 20 20 03 e0 4c 94 e0 a9 ec 85 00 a9 e2 85 01 
20 00 e0 8a 0a aa bd a4 e0 85 02 e8 bd a4 e0 85 
03 6c 02 00 4c 23 e0 0c 61 63 64 66 67 68 69 00.
>m 0400 10 0a OK
0400 4c b3 fc 4c c7 fc 4c cb fc 4c d3 fc 4c 63 fc 4c |L..L..L..L..Lc.L|
0410 76 fc 4c 83 fc 4c a1 fc a9 c6 85 00 a9 e2 85 01 |v.L..L..........|
0420 20 00 e0 20 22 e2 20 16 e2 20 06 e0 b0 fb c9 0d | .. ". .. ......|
0430 f0 15 c9 0a f0 11 20 03 e0 a6 0f 95 10 e8 86 0f |...... .........|
0440 e0 20 f0 03 4c 29 e0 a2 00 b5 10 dd 98 e0 f0 28 |. ..L).........(|
0450 e8 ec 97 e0 d0 f5 a9 d8 85 00 a9 e2 85 01 20 00 |.............. .|
0460 e0 48 a9 22 20 03 e0 68 20 03 e0 a9 22 20 03 e0 |.H." ..h ..." ..|
0470 a9 20 20 03 e0 4c 94 e0 a9 ec 85 00 a9 e2 85 01 |.  ..L..........|
0480 20 00 e0 8a 0a aa bd a4 e0 85 02 e8 bd a4 e0 85 | ...............|
0490 03 6c 02 00 4c 23 e0 0c 61 63 64 66 67 68 69 00 |.l..L#..acdfghi.|
```

The _i_ command is the opposite to the _o_ command. It takes an 16bit address as parameter and after starting (hit enter) it waits for input. It accepts all whitespaces and CR/LF characters (just ignoring them) and all hex value input. The input is written byte by byte from the starting address until a single dot ('.') is received.

The example shows an empty block of memory (using the _m 0400 10 0a_ command). After that the input command is called with _i 0400_ followed by a memory dump (created with the _o_ command) that was pasted to the terminal window. Make sure you set your terminal program to a small delay (5ms) after every character and 15ms after every CR/LF to give the system the chance not to miss a character. 
After the input was successful (ended by the '.' at the end of the block), the next _m 0400 10 0a_ shows that the pasted data was written to memory.

You can use this to input data from the 'outside world' to the system.

### Filling memory

```
>f 0400:049f ff OK

>m 0400 10 0a OK
0400 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff |................|
0410 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff |................|
0420 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff |................|
0430 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff |................|
0440 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff |................|
0450 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff |................|
0460 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff |................|
0470 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff |................|
0480 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff |................|
0490 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff |................|
```

The command _f_ can be used to fill a memory block with a given byte. It takes a range of two 16bit addresses and a 8bit hex value to set all bytes within the address range with the given value.


## Assembler / Disassembler

### Using the disassembler

```
>d e000 OK
$e000   $4c $b3 $fc    JMP   $fcb3
$e003   $4c $c7 $fc    JMP   $fcc7
$e006   $4c $cb $fc    JMP   $fccb
$e009   $4c $d3 $fc    JMP   $fcd3
$e00c   $4c $63 $fc    JMP   $fc63
$e00f   $4c $76 $fc    JMP   $fc76
$e012   $4c $83 $fc    JMP   $fc83
$e015   $4c $a1 $fc    JMP   $fca1
$e018   $a9 $c6        LDA   #$c6
$e01a   $85 $00        STA   $00
$e01c   $a9 $e2        LDA   #$e2
$e01e   $85 $01        STA   $01
$e020   $20 $00 $e0    JSR   $e000
$e023   $20 $22 $e2    JSR   $e222
$e026   $20 $16 $e2    JSR   $e216
$e029   $20 $06 $e0    JSR   $e006
$e02c   $b0 $fb        BCS   $e029
$e02e   $c9 $0d        CMP   #$0d
$e030   $f0 $15        BEQ   $e047
$e032   $c9 $0a        CMP   #$0a
$e034   $f0 $11        BEQ   $e047
$e036   $20 $03 $e0    JSR   $e003
$e039   $a6 $0f        LDX   $0f
  <SPACE> TO CONTINUE, <ESC> TO STOP
```

The _d_ command takes an 16bit address as parameter and starts disassembling from this address. The disassembler shows the address, byte values as well as the opcodes with parameters.
It can handle 6502 and 65C02 opcodes. 

Be aware that it has no knowledge about data in the memory that is no code (strings or a lookup table for instance). If such a memory region is part of the disassembly the output will be messed up, because data will be interpreted as opcodes.


### Using the assembler

```
>a 0400 OK
0400: LDA #$0a
0402: JSR $e003
0405: LDA #$41
0407: LDX #$1a
0409: JSR $e003
040c: ADC #$01
040e: DEX
040f: BNE $0409
0411: JMP $e023
0414: 
>g 0400 OK
ABCDEFGHIJKLMNOPQRSTUVWXYZ
>
```

The assembler is invoked by the command _a_ followed by an 16bit address. The current address is shown at the start of the line and you can start enter your opcodes. They are parsed during the input. Opcodes without parameters are completed automatically by going to the next line, opcodes with parameters have to be completed with ENTER

Hitting Escape jumps out of the assembler. 

Relative branches are calculated by the assembler, so you have to input the absolute address of the relative branch. (See line $040f in the example)

All inputs are evaluated as hex values, even if you obmit the $ sign. There is no decimal input.

The example uses functions of the MIOS (Minimal Input Output System) to write an character to the serial line (JSR $e003). 

The _JMP $e023_ at the end goes right back to the monitor program. 

Also the command _g_ is used to start the program that was entered. 


## Running code

### Execute a program

```
>g 0400 OK
ABCDEFGHIJKLMNOPQRSTUVWXYZ
>
```

The command _g_ takes a 16bit address an makes a _JMP $address_ to start a programm. 

Using the example from the assembler it starts a programm at $0400 (showing all ASCII characters from A to Z in this case)

### Running VTL2

```
>v OK
OK

10 A=1
20 ?=A
30 A=A+1
40 #=(A<10)*20

OK
#=10

123456789
OK
```

VTL2 is a simple language (Very Tiny Language) that was ported to the 6502. It has a small memory footprint but is still at a "higher level" compared to plain assembler.
You can use Variables, can input and output values, make branches and calculate values. 

The example shows a small programm creating a loop from A=1 to A=9 printing the numbers of 1 to 9 on the screen.

More details can be found [here](http://6502.org/source/interpreters/vtl02.htm) and [here](http://www.altair680kit.com/manuals/Altair_680-VTL-2%20Manual-05-Beta_1-Searchable.pdf)

### Running Microchess

```
>c OK
MicroChess (c) 1996-2002 Peter Jennings, peterj@benlo.com

 00 01 02 03 04 05 06 07
-------------------------
|BP|  |**|  |**|  |**|  |00
-------------------------
|  |**|  |**|  |**|  |**|10
-------------------------
|**|  |**|  |**|  |**|  |20
-------------------------
|  |**|  |**|  |**|  |**|30
-------------------------
|**|  |**|  |**|  |**|  |40
-------------------------
|  |**|  |**|  |**|  |**|50
-------------------------
|**|  |**|  |**|  |**|  |60
-------------------------
|  |**|  |**|  |**|  |**|70
-------------------------
 00 01 02 03 04 05 06 07
00 00 00
?
```

Microchess was written in 1976 for the original KIM-1 by Peter Jennigs who greatful granted me the right to distribute microchess with my 6502 systems.

There's a website describing the history of the program [here](http://www.benlo.com/microchess/index.html)

There is also a complete manual [here](http://www.benlo.com/microchess/Kim-1Microchess.html)

The following keys are used on MOSUE to interact with microchess:
```
-----------------------------------------------------------------------
|               Key               |                Key                |
|---------------------------------------------------------------------|
|   C    Clear Board              |   1-7           Keys to enter move|
|   E    Exchange sides           |   (Return)      Register move     |
|   P    Play                     |                                   |
|---------------------------------------------------------------------|
|   W    Toggle Blitz (fast & dumb) / Normal play (100sec/move)       |
-----------------------------------------------------------------------
```
