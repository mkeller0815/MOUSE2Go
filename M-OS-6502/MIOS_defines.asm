;
; M-OS
;
; global defines
;
;
;The MIT License (MIT)
;
;Copyright (c) 2015 Mario Keller
;
;Permission is hereby granted, free of charge, to any person obtaining a copy
;of this software and associated documentation files (the "Software"), to deal
;in the Software without restriction, including without limitation the rights
;to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;copies of the Software, and to permit persons to whom the Software is
;furnished to do so, subject to the following conditions:
;
;The above copyright notice and this permission notice shall be included in all
;copies or substantial portions of the Software.
;
;THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;SOFTWARE.
;
;

.alias ACIA_START	$8000	; start of ACIA registers
;.alias ACIA_MODE	$16	; 8N1, 28800 baud
.alias ACIA_MODE	$15	; 8N1, 115200 baud

.alias STACK_END	$ff	; top stackpointer value

.alias ROM_START	$e000	; start of kernel rom image

;
; Zero Page defines
;
; ZP addresses used by several functions of the I/O system and the kernel
;
				; this is needed by k_wstr function
.alias K_STRING_L	$00	; ZP highbyte of string output address
.alias K_STRING_H	$01	; ZP lowbyte of string output address
.alias K_VAR1_L		$02	; ZP common variable (16 bit)
.alias K_VAR1_H		$03
.alias K_VAR2_L		$04	; ZP common variable (16 bit)
.alias K_VAR2_H		$05
.alias K_VAR3_L		$06	; ZP common variable (16 bit)
.alias K_VAR3_H		$07
.alias K_VAR4_L		$08	; ZP common variable (16 bit)
.alias K_VAR4_H		$09
.alias K_TMP1		$0A	; ZP temp variable (8bit)
.alias K_TMP2		$0B	; ZP temp variable (8bit)
.alias K_TMP3		$0C	; ZP temp variable (8bit)
.alias K_TMP4		$0D	; ZP temp variable (8bit)
.alias K_TMP5		$0E	; ZP temp variable (8bit)


; kernel input buffer / reserved from $0F to $2F
;
.alias K_BUF_P		$0F	; ZP variable holding pointer to end of buffer
.alias K_BUFFER		$10	; ZP start of 32 bytes kernel input buffer
.alias K_BUF_LEN	$20	; max length of input buffer (this is not an address)

; generic defines

.alias LINE_END		$0A	; define end of line character
