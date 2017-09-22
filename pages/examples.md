# MOUSE2Go MOUSE Examples

Here are some examples of how to use certain features of MOUSE

In the monitor program, you can always call "h" for help to get a list of all commands.

All commands start with a single character. Some of them have also parameters.

{:toc}

## Show memory

There are three commands to get a parts of the memory shown.

### memdump

´´´
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
´´´

The command _m_ takes three parameters. The first is the address were dumping the memory should start. The second parameter is one byte (hex) giving the number of bytes per line to be shown on the output. And the last paramerer takes the number of lines to be shown. 

In the example the output start at $e000 with $10 (16) bytes per line and $0a (10) lines to show. 

The command shows the hex values as well as the ASCII characters (if printable or a '.' otherwise)

### output memory 

´´´
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
´´´
The command _o_ takes a pair auf 16bit addresses as parameter separated by a ':' to write out a block of memory as hex values.
A linebreak is printed after 16 bytes and after the last byte a dot ('.') is shown. 

This command can be used to save a block of memory with your terminal program. Just copy-paste the block to a separate file of let your terminal program write the output to a file right before hitting "Enter" on the command.

There's a corresponding input command to read such a block back zu memory 

### show byte

´´´
>s e000 OK
4c 01001100
´´´

The command _s_ take a 16bit address as parameter and shows the corresponding byte on this address as hex value as well as binary value

## Input data

### input memory

´´´
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
´´´

The _i_ command is the opposite to the _o_ command. It takes an 16bit address as parameter and after starting (hit enter) it waits for input. It accepts all whitespaces and CR/LF characters (just ignoring them) and all hex value input. The input is written byte by byte from the starting address until a single dot ('.') is received.

The example shows an empty block of memory (using the _m 0400 10 0a_ command). After that the input command is called with _i 0400_ followed by a memory dump (created with the _o_ command) that was pasted to the terminal window. Make sure you set your terminal program to a small delay (5ms) after every character and 15ms after every CR/LF to give the system the chance not to miss a character. 
After the input was successful (ended by the '.' at the end of the block), the next _m 0400 10 0a_ shows that the pasted data was written to memory.

You can use this to input data from the 'outside world' to the system.

### Filling memory

´´´
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
´´´

The command _f_ can be used to fill a memory block with a given byte. It takes a range of two 16bit addresses and a 8bit hex value to set all bytes within the address range with the given value.



