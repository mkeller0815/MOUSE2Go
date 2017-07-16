;
; M-OS monitor programm
;

; Character set
.alias AsciiCC  $03  ; break (Control-C) ASCCI character
.alias AsciiBS  $08  ; backspace ASCII character
.alias AsciiLF  $0A  ; line feed ASCII character
.alias AsciiCR  $0D  ; carriage return ASCII character
.alias AsciiSP  $20  ; space ASCII character
.alias AsciiDS  $2D  ; dash/minus ASCII character
.alias AsciiDEL $7F  ; DEL ASCII character


;
; M-OS monitor main loop
;
.scope

m_start:
.invoke print MS_WELCOME    ; print welcome
    jsr m_clear_buffer  ; clear input buffer
    jsr m_show_prompt   ; show initial prompt

m_main:             ; monitor main loop

_wait:
    jsr j_rchr          ; read character
    bcs _wait           ; wait for character
    cmp #AsciiCR        ; check if carriage return
    beq m_parse         ; parse buffer
    cmp #AsciiLF        ; check if line feed
    beq m_parse         ; parse buffer
    jsr j_wchr          ; local echo character
    ldx K_BUF_P         ; load current bufferpointer
    sta K_BUFFER,x      ; put character to buffer
    inx                 ; increment bufferpointer
    stx K_BUF_P         ; save buffer pointer
    cpx #K_BUF_LEN      ; check for end of buffer
    beq m_parse         ; if end of buffer -> parse
    jmp m_main          ; next character

m_parse:
                        ; code for parsing commands here
    ldx #$00            ; set index to 0
    lda K_BUFFER,x      ; load first character
*   cmp m_cmd_list,x    ; compare to current command
    beq m_cmdjmp        ; command found
    inx                 ; increment index
    cpx m_cmd_num       ; end of command list?
    bne -           ; next command
.invoke print MS_CMD_ERROR  ; unknown command
    pha         ; save A
    lda #$22
    jsr j_wchr
    pla
    jsr j_wchr
    lda #$22
    jsr j_wchr
    lda #$20
    jsr j_wchr
    jmp m_parse_end
m_cmdjmp:
.invoke print MS_OK
    txa         ; index to accumulator
    asl         ; x2
    tax
    lda m_cmd_jumptable,x
    sta K_VAR1_L
    inx
    lda m_cmd_jumptable,x
    sta K_VAR1_H
    jmp (K_VAR1_L) ; jump to command
m_parse_end:
    jsr m_clear_buffer      ; clear input buffer
    jsr m_show_prompt   ; show new prompt
    jmp m_main      ; back to mainloop

.scend

m_cmd_num:
    .byte   12
m_cmd_list:
    .byte "acdfghimorvt"

m_cmd_jumptable:
    .word m_cmd_asciidump
    .word m_cmd_chess
    .word m_cmd_disass
    .word m_cmd_fill
    .word m_cmd_go
    .word m_cmd_help
    .word m_cmd_input
    .word m_cmd_memdump
    .word m_cmd_output
    .word m_cmd_reset
    .word m_cmd_vtl2
    .word m_cmd_test


m_cmd_chess:
    jmp CHESS       ; jump to chess program

m_cmd_vtl2:
    jmp v_startx        ; jump to vtl2 interpreter

m_cmd_reset:
    jmp ($fffc)     ; jump to reset vector

;
; dump a part of the memory as ascii dump out ignoring
; nonprintable characters
;
; @param  K_VAR1_L + K_VAR1_H   16bit value of address to dump from
; @param  K_VAR2_L      number of bytes per line
; @param  K_VAR2_H      number of lines to print
;
; @return -
;
; A,X,Y are preserved K_VAR* are destroyed
.scope
m_cmd_asciidump:
    ldx #$02            ; bad hack to skip first blank
    jsr j_a2b           ; parse high byte
    sta K_VAR1_H        ; store high byte
    jsr j_a2b           ; parse low byte
    sta K_VAR1_L        ; store low byte
    jsr j_a2b           ; parse number of columns
    sta K_VAR2_L        ; store value
    jsr j_a2b           ; parse number of rows
    sta K_VAR2_H        ; store value
    tax                 ; load number of lines
_outer: .invoke linefeed
    ldy K_VAR2_L        ;load number of bytes per line
    lda K_VAR1_H        ;load high byte of address
    jsr j_hex8out       ;print high byte
    lda K_VAR1_L        ;load low byte of address
    jsr j_hex8out       ;print low byte
    .invoke space       ;print " "
    lda #$7c            ;print '|' as ruler
    jsr j_wchr
_inner:
    stx K_TMP3          ; save X
    ldx #$00
    lda (K_VAR1_L,x)    ;load next byte
    bpl _next1          ; >127
    lda #$2e            ; show unprintable charachter as '.'
_next1: cmp #$20        ; check if > 32
    bcs _print          ;
    lda #$2e            ; show lower then 32 as '.'
_print: jsr j_wchr      ;print byte
    ldx K_TMP3          ;restore X
    inc K_VAR1_L        ;increment address low byte
    bne +               ;check for turnover
    inc K_VAR1_H        ;increment address high byte
*   dey                 ;next byte
    bne _inner          ;end of line?
    lda #$7c            ;print '|' as ruler
    jsr j_wchr
    dex                 ;next line
    bne _outer          ;end of lines?
    .invoke linefeed
    jmp m_parse_end     ; back to parse
.scend


m_cmd_test:
    lda #$ff
    jsr j_hex4out
    jmp m_parse_end


m_cmd_memdump:
    ldx #$02            ; bad hack to skip first blank
    jsr j_a2b           ; parse high byte
    sta K_VAR1_H        ; store high byte
    jsr j_a2b           ; parse low byte
    sta K_VAR1_L        ; store low byte
    jsr j_a2b           ; parse number of columns
    sta K_VAR2_L        ; store value
    jsr j_a2b           ; parse number of rows
    sta K_VAR2_H        ; store value
    jsr m_dump_mem
    .invoke linefeed
    jmp m_parse_end     ; back to parse

m_cmd_disass:
    ldx #$02        ; fist character of address
    jsr j_a2b        ; parse high byte
    sta K_VAR1_H            ; store high byte
    jsr j_a2b        ; parse low byte
    sta K_VAR1_L            ; store low byte
    jmp DSTART      ; jump to parsed address

m_cmd_go:
    ldx #$02        ; fist character of address
    jsr j_a2b        ; parse high byte
    sta K_VAR1_H            ; store high byte
    jsr j_a2b        ; parse low byte
    sta K_VAR1_L            ; store low byte
    jmp (K_VAR1_L)      ; jump to parsed address

m_cmd_help:
.invoke print MS_HELP1      ; print first help string
.invoke print MS_HELP2      ; print second help string
    jmp m_parse_end     ; back to parse

.scope
m_cmd_input:
.invoke linefeed        ;
    ldx #$02                ; fist character of address
    jsr j_a2b        ; parse high byte
    sta K_VAR1_H            ; store high byte
    jsr j_a2b        ; parse low byte
    sta K_VAR1_L            ; store low byte
    jsr m_clear_buffer  ; first clear the buffer
_start:
    ldx #$00        ; index
_wait:
    jsr j_rchr              ; read character
    bcs _wait               ; wait for character
    jsr j_wchr      ; output character
    cmp #'.             ; check if carriage return
    beq _end            ; branch to end
    cmp #AsciiSP        ; ignore blank
    beq _wait       ;
    cmp #AsciiLF        ; ignore LF
    beq _wait       ;
    cmp #AsciiCR        ; ignore CR
    beq _wait       ;
    sta K_BUFFER,x      ; store character
    inx         ; increase index
    cpx #$02        ; already second character
    bne _wait       ; loop for next character
    ldx #$00        ; reset index
    jsr j_a2b   ; parse current byte
    ldx #$00
    sta (K_VAR1_L,x)      ; save byte to destination
    inc K_VAR1_L        ; increase destination address
    bne _start      ; next byte
    inc K_VAR1_H        ; on overflow increase high byte
    jmp _start      ; next byte
_end:
    jmp m_parse_end     ; back to parse
.scend

.scope
m_cmd_output:
    .invoke linefeed        ;
    ldx #$02                ; fist character of address
    jsr j_a2b        ; parse high byte
    sta K_VAR1_H            ; store high byte
    jsr j_a2b        ; parse low byte
    sta K_VAR1_L            ; store low byte
    inx         ; skip ':'
    jsr j_a2b        ; parse high byte
    sta K_VAR2_H            ; store high byte
    jsr j_a2b        ; parse low byte
    sta K_VAR2_L            ; store low byte
    ldx #$10        ; 16 values per line
_loop:
    txa
    pha
    ldx #$00
    lda (K_VAR1_L,x)      ; load value
    jsr j_hex8out       ; print value
    pla
    tax
.invoke space           ; print separator
    dex         ; decrement index
    bne +           ; end of line?
.invoke linefeed        ; linefeed
    ldx #$10        ; reload index
*   jsr m_loop_addr     ; next step in loop
    bcc _loop       ; loop
    txa
    pha
    lda (K_VAR1_L,x)      ; laod last value
    jsr j_hex8out       ; write value
    pla
    txa
    lda #$2e        ; '.'
    jsr j_wchr      ; print final '.'
    jmp m_parse_end     ; back to parse
.scend

.scope
m_cmd_fill:
.invoke linefeed        ;
    ldx #$02                ; fist character of address
    jsr j_a2b        ; parse high byte
    sta K_VAR1_H            ; store high byte
    jsr j_a2b        ; parse low byte
    sta K_VAR1_L            ; store low byte
    inx         ; skip ':'
    jsr j_a2b        ; parse high byte
    sta K_VAR2_H            ; store high byte
    jsr j_a2b        ; parse low byte
    sta K_VAR2_L            ; store low byte
    jsr j_a2b        ; parse fill byte
_loop:
    ldx #$00
    sta (K_VAR1_L,x)      ; write value
    jsr m_loop_addr     ; next step in loop
    bcc _loop       ; loop
    sta (K_VAR1_L,x)      ; write last value
    jmp m_parse_end     ; back to parse
.scend


;
; set cursor to new line and print a prompt
;
m_show_prompt:
    .invoke print MS_PROMPT;
    rts



;
; clear input buffer
;
.scope
m_clear_buffer:
    pha
    txa
    pha         ; save X
    ldx #K_BUF_LEN      ;
    lda #$00
*   sta K_BUFFER,x      ; write 00 to buffer position
    dex         ; decrement index
    bne -           ; end of buffer ?
    sta K_BUF_P     ; clear buffer pointer
    pla
    tax
    pla         ; restore X
    rts         ; return
.scend
;
; dump a part of the memory as hex dump out
;
; @param  K_VAR1_L + K_VAR1_H   16bit value of address to dump from
; @param  K_VAR2_L      number of bytes per line
; @param  K_VAR2_H      number of lines to print
;
; @return -
;
; A,X,Y are preserved K_VAR* are destroyed
.scope
m_dump_mem:
    pha                 ;save A
    txa
    pha                 ;save X
    tya
    pha                 ;save Y
    ldx K_VAR2_H        ;load number of lines
_outer:
    .invoke linefeed
    ldy K_VAR2_L        ;load number of bytes per line
    lda K_VAR1_H        ;load high byte of address
    jsr j_hex8out       ;print high byte
    lda K_VAR1_L        ;load low byte of address
    jsr j_hex8out       ;print low byte
_inner:
    .invoke space       ;print " "
    txa
    pha
    ldx #$00
    lda (K_VAR1_L,x)      ;load next byte
    jsr j_hex8out       ;print byte
    pla
    tax
    inc K_VAR1_L        ;increment address low byte
    bne +           ;check for turnover
    inc K_VAR1_H        ;increment address high byte
*   dey         ;next byte
    bne _inner      ;end of line?
    dex         ;next line
    bne _outer      ;end of lines?
    pla         ;restore Y
    tay
    pla         ;restore X
    tax
    pla         ;restore A
    rts         ;return
.scend

;
; loop from one address to a second address by
; increasing the start address until the end address is reached
;
; @param  K_VAR1_L + K_VAR1_H   16bit value of address to start from
; @param  K_VAR2_L + K_VAR2_H   16bit value of end address
;
.scope
m_loop_addr:
    pha         ; save A
    inc K_VAR1_L        ; increase low byte
    bne +           ; no overflow
    inc K_VAR1_H        ; increase high byte on overflow
*   lda K_VAR2_L        ; load end value
    cmp K_VAR1_L        ; compare wiht current address low
    bne _end        ; not equal
    lda K_VAR2_H        ; load high value
    cmp K_VAR1_H        ; compare with current address high
    bne _end
    sec         ; set carry to indicate end of loop
    jmp _end2
_end:
    clc         ; clear carry
_end2:
    pla
    rts
.scend


MS_PROMPT:  .byte LINE_END,">",0
MS_WELCOME: .byte "MOUSE MON V 0.7",LINE_END,LINE_END,0
MS_CMD_ERROR:   .byte LINE_END,"?unknown command: ",0
MS_OK:      .byte " OK",0
MS_HELP1:   .byte   LINE_END,"commands:", LINE_END,"a <addr> %cols %rows - ascii dump from address",LINE_END,"c - start microchess", LINE_END,"d <addr> - disassemble from address", LINE_END,"f <addr>:<addr> %val - fill memory with %val", LINE_END,"g <addr> - jump to <addr>", LINE_END,"h - this help",0
MS_HELP2:   .byte   LINE_END,"i <addr> - input <addr> input data to memory '.' ends the input",LINE_END,"m <addr> %cols %rows - dump memory from address", LINE_END,"o <addr>:<addr> - output memory range", LINE_END,"r - jump to reset vector", LINE_END,"v - start VTL2 language", LINE_END," <addr> - 16bit address, %xx - 8 bit value",0

; VCFBHELLO:  .byte LINE_END,"Hello FCVB 2015",0
