;
; MACROs for common tasks and repeating parts of code
;
;
;
;

; -----------------------------------------------------------------------------
; MACRO for writing a line. Use with ".invoke print <address>" where
; <address> is the first byte of the string in 16 bit. As a "write"
; command, the string has to be terminated by a zero-byte ('\0')
.macro print
  lda #<_1
  sta K_STRING_L
  lda #>_1
  sta K_STRING_H
  jsr j_wstr
.macend

; -----------------------------------------------------------------------------
; MACRO for writing a linefeed. Use with ".invoke linefeed"
.macro linefeed
	lda #LINE_END
	jsr j_wchr
.macend


; -----------------------------------------------------------------------------
; MACRO for writing a space. Use with ".invoke space"
.macro space
	lda #32
	jsr j_wchr
.macend
