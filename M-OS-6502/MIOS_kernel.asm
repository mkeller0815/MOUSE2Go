;
; M-OS kernel for a minimal system
;
; providing high level function for input and output of data
;
; providing reset and interrupt routines and an base entry point
; to start after reset / power on
;
; this file should always be the last file in an ROM image, because it
; defines the NMI, IRQ and NMI vectors at the end moving the address
; counter to $FFFF


;load the 6850 ACIA driver
;
; ACIA driver is directly imported here, because this version of the kernel
; makes direct use of the low level function form the driver.
;
; low level function should not be used outside the kernel to provide
; compatibility for software to other hardware configurations
;
;.require "MIOS_driver_ACIA6850.asm"
.require "MIOS_driver_ACIApy65mon.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; k_START
;
; simple start point of the kerne after reset.
;
.scope
k_START:
.invoke	print k_welcome 	; print welcome message
	jmp MOUSESTART		; start what ever is defined as start tool
	brk
.scend



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;
; general utility functions for converting data or generate output
;


;
; print out the 8bit value in A as binary code
; X,Y and A are destroyed
;
.scope
u_bin8out:
	    ldx #$08    ; counter for 8 bit
_loop:	clc			; clear carry flag
        ldy #'0
	    asl 		; shift byte by one position
	    bcc _p0
        iny
_p0:    pha         ; save A    
        tya			; 
        jsr k_wchr
	    pla			; get A back
	    dex			; decrement counter
	    bne _loop
	    rts			; return
.scend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;
; write content of A as hex
;
; @param A - number to write (A is destroyed)
;
.scope
u_hex8out:
	pha			; save A
	lsr 			; get hi nibble
	lsr
	lsr
	lsr
	jsr u_hex4out		; print high nibble
	pla			; restore A
	jsr u_hex4out		; print low nibble
	rts			; return
.scend


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; print low-nibble of A as hex digit
;
; @param A containing number (A is destroyed)
;
; @ return -
.scope
; HEX digits for printing hexnumbers
u_hex4out:
  stx K_TMP2      	; save X
	and #$0f		    	; mask high nibble out
	tax			        	; set digit index
	lda u_hexdigit,x	; load digit
	jsr k_wchr		    ; print character
  ldx K_TMP2      	; restore X
	rts			        	; return
.scend
u_hexdigit:	.byte "0123456789abcdef"



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; convert a character in A to one nibble
; works only for '0-'9','A'-'F' and 'a'-'f' all other chracters may
; cause unexpected results
;
; @param A containing the character (will be destroyed)
;
; @return A containung the nibble value
.scope
u_chr2nibble:
	sec			; set carry bit
	sbc #$30		; substract 48 ('0')
	cmp #$0a		; check if lower then 10
	bcc +			; carry is clear if value is lower 10
	sec
	sbc #$07		; substract 7 ('a'-'f')
	cmp #$10		; carry is clear if value is lower 16
	bcc +
	sec
	sbc #$20		; substract 32 ('A' - 'F')
*	rts			; return,  Accumulator contains the digit
.scend


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; k_wstr
; write string to output
; K_STRING_L and K_STRING_H have to hold the startaddress of the string
; max length of string: 255 characters. string must be terminated by \0
;
; Y,A - are perserved
;
; @param - K_STRING_L (memorylocation with the startaddress of the string)
;
; @return -
.scope
k_wstr:
	pha			; save A to stack
    tya
	pha			; save Y to stack
	ldy #$00		; set index
*	lda (K_STRING_L),y	; load character
	beq +
	jsr k_wchr		; print character
	iny			; increment index
	jmp -			; next character
*	pla			; restore Y
    tay
	pla			; restore A
	rts
.scend


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; k_wchr
; write one character to output
;
; @param A - character to write
;
; @return -
.scope
k_wchr:
; 	deactivated for testing with py65
	jsr acia_send_b	; send charachter to ACIA and wait until it was sent
	rts		; return
	; current workaround for py65
;	sta $f001
;	rts
.scend


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; k_rchr
; read one character from input
; this is nonblocking, C flag is set if no charachter was read
;
; @param -
;
; @return - A the received byte or "0" with C flag set if no byte was recieved.
.scope
k_rchr:
; 	deactivated for testing with py65
;	sec			; set carry flag
;	jsr acia_received	; check if data is available
;	beq +			; return, leave Z flag set
;	jsr acia_receive	; read the byte
;	clc			; clear carry flag to indicate data
;*	rts			; return
	; current workaround for py65
	sec			; set carry
	jsr acia_receive	; read character
	beq +			; no character read
	clc			; clear carry if character read
*	rts 			; return
.scend


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


k_ascii2byte:
; convert two ascii characters in the kernel buffer to
; one byte. blank characters are skipped
; X is modified and A is destroyed
; K_TMP1 is modified
;
; @param - X containing the offset in K_BUFFER
;
; @return - A containing the parsed byte
; @return - X pointing to the byte after the last parsed character
.scope
*	lda K_BUFFER,x		; read fists character
	inx			; increase index
	cmp #$20		; check for blank
	beq -			; read next character
	jsr u_chr2nibble	; convert to first nibble
	asl
	asl
	asl
	asl			; shift to high nibble
	sta K_TMP1		; save high nibble
	lda K_BUFFER,x
	jsr u_chr2nibble	; convert next nibble
	ora K_TMP1		; add high nibble
	inx			; set indext to byte after last character
	rts
.scend


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;
; RESET
;
;
.scope
k_RESET:
        sei             ; prevent interupts
        cld             ; set binary mode
        ldx #$ff        ; last RAM address for stack
        txs             ; set stackpointer

	lda #$00	; clear memory
*	sta $0,x	;
	dex		;
	bne -		;

        cli             ; reenable interupts
	lda #ACIA_MODE	; set serial mode and init ACIA
        jsr acia_init   ; init ACIA

    lda #<k_NMI_END     ; get low addressbyte from NMI rti
    sta SOFT_NMI        ; store at SOFT_NMI address
    lda #>k_NMI_END     ; get high addressbyte from NMI rti
    sta SOFT_NMI+1      ; store at SOFT_NMI address
    lda #<k_IRQ_END     ; get low addressbyte from IRQ rti
    sta SOFT_IRQ        ; store at SOFT_IRQ address
    lda #>k_IRQ_END     ; get high addressbyte from IRQ rti
    sta SOFT_IRQ+1      ; store at SOFT_IRQ address
	jmp k_START	; start kernel
.scend


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; just print out that an NMI was called
;
.scope
k_NMI:
    JMP(SOFT_NMI)      ; jump to the address of the "virtual" NMI vector
k_NMI_END:
    rti
.scend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
;
;
.scope
k_IRQ:
    JMP(SOFT_IRQ)      ; jump to the address of the "virtual" IRQ vector
k_IRQ_END:
	rti
.scend


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;
; DATA section
;
;
;

k_welcome: .byte LINE_END,"MOUSE 65C02 micro computer (c) 2017",LINE_END,"M-OS V0.3",LINE_END,"READY.",LINE_END,0
k_nmimsg: .byte LINE_END,"NMI called",LINE_END,0
k_irqmsg: .byte LINE_END,"NMI called",LINE_END,0
;
; fill ROM to vector table
;

.advance $fffa

.word k_NMI		; NMI vector
.word k_RESET		; RESET vector
.word k_IRQ		; IRQ vector
