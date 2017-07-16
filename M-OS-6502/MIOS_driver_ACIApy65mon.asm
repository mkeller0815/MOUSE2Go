;
; DRIVER CODE FOR - Py65mon fake ACIA
;
; non blocking
; $F001 - putc - write character to console
; $F004 - getc - read character from console (0 if no character)

;.alias ACIAIN   $F004
.alias ACIAIN   $FFF9
;.alias ACIAOUT  $F001
.alias ACIAOUT  $FFF8

;
; initialize the ACIA
;
; not needed for py65mon, but still here to match the driver interface pattern
;
; @return: --
.scope
acia_init:
  rts             ; finished
.scend

;
; send byte (blocking)
;
; py65mon is always nonblocking, so we don't have to care for that
;
; @param A - the byte to sent
;
; @return -
.scope
acia_send_b:
  sta ACIAOUT
	rts		          ; return
.scend


;
; send byte (nonblocking)
;
; send one byte without checking
;
; @param A - the byte to sent
;
; @return -
.scope
acia_send:
  sta ACIAOUT     ; send byte
  rts             ; return
.scend


;
; test if ACIA is ready to send
;
; ATTENTION: content of A is detroyed by this function
;
; @param   -
;
; @return  - set Z flag if ACIA is not ready to send
.scope
acia_ready2send:
	lda #$02	; set bit 1
	rts		    ; return
.scend


;
; test if a byte was received
;
; ATTENTION: content of A is detroyed by this function
;
; @param   -
;
; @return  - set Z flag if no data was received
.scope
acia_received:
        lda #$ff        ; test bit 0
        rts             ; return
.scend


;
; read byte (blocking)
;
; ATTENTION: content of A is detroyed by this function
;
; @param  -
;
; @return A - return the bytes that was received
.scope
acia_receive_b:
	lda ACIAIN	        ; read byte
  beq acia_receive_b  ; check if >0
	rts		              ; return
.scend

;
; read byte (nonblocking)
;
; ATTENTION: content of A is detroyed by this function
;
; @param  -
;
; @return A - return the bytes that was received
.scope
acia_receive:
        lda ACIAIN	    ; read byte
        rts             ; return
.scend
