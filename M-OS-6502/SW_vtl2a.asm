;234567890123456789012345678901234567890123456789012345
;------------------------------------------------------
; VTL-2 for the 6502 (VTL02)
; Original Altair 680b version by
;   Frank McCoy and Gary Shannon 1977
; Adapted to the 6502 by Michael T. Barry 2012
; Thanks to sbprojects.com for a very nice assembler!
; Modified for the Kowalski simulator by Klaus2m5
;
;Copyright (c) 2012, Michael T. Barry
;All rights reserved.
;
;Redistribution and use in source and binary forms,
; with or without modification, are permitted provided
; that the following conditions are met: 
;
;1. Redistributions of source code must retain the
;   above copyright notice, this list of conditions and
;   the following disclaimer. 
;2. Redistributions in binary form must reproduce the
;   above copyright notice, this list of conditions and
;   the following disclaimer in the documentation and/
;   or other materials provided with the distribution. 
;
;THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
; CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
; WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
; SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
; NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
; LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
; TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
; ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;
; Notes concerning this version:
;   {&} and {*} are initialized on entry.
;   Division by zero returns a quotient of 65535 (the
;     original 6800 version froze).
;   The 6502 has NO 16-bit registers (other than PC)
;     and less overall register space than the 6800, so
;     it was necessary to reserve some obscure VTL02
;     variables {@ _ $ ( ) 0 1 2 3 4 5 6 7 8 9 :} for
;     the interpreter's internal use (the 6800 version
;     also uses several of these, but with different
;     designations).  The deep nesting of parentheses
;     also puts {; < =} in danger of corruption.  For
;     example, A=((((((((1)))))))) sets both {A} and
;     {;} to the value 1.
;   Users wishing to call a machine language subroutine
;     via the system variable {>} must first set the
;     system variable {"} to the proper address vector
;     (for example, "=768).
;   The x register is used to point to a simple VTL02
;     variable (it can't point explicitly to an array
;     element like the 6800 version because it's only
;     8-bits).  In the comments, var[x] refers to the
;     16-bit contents of the zero-page variable pointed
;     to by register x (residing at addresses x, x+1).
;   The y register is used as a pointer offset inside a
;     VTL02 statement (it can easily handle the maximum
;     statement length of about 128 bytes).  In the
;     comments, @[y] refers to the 16-bit address
;     formed by adding register y to the value in {@}.
;   The structure and flow of this interpreter is
;     similar to the 6800 version, but it has been re-
;     organized in a more 6502-friendly format (the
;     6502 has no 'bsr' instruction, so the 'stuffing'
;     of subroutines within 128 bytes of the caller is
;     only advantageous for conditional branches).
;   I designed this version to duplicate the OFFICIALLY
;     DOCUMENTED behavior of Frank's 6800 version:
;   http://www.altair680kit.com/manuals/Altair_
;   680-VTL-2%20Manual-05-Beta_1-Searchable.pdf
;     Both versions ignore all syntax errors and plow
;     through VTL-2 programs with the assumption that
;     they are "correct", but in their own unique ways,
;     so any claims of compatibility are null and void
;     for VTL-2 code brave (or stupid) enough to stray
;     from the beaten path.
;   This version is wound rather tightly, in a failed
;     attempt to fit it into 768 bytes like the 6800
;     version; many structured programming principles
;     were sacrificed in that effort.  The 6502 simply
;     requires more instructions than the 6800 does to
;     manipulate 16-bit quantities, but the overall
;     execution speed should be comparable due to the
;     6502's slightly lower average clocks/instruction
;     ratio.  As it is now, it fits into 1k with room
;     to spare.  When coding VTL02, I chose compactness
;     over execution speed at every opportunity; a
;     higher-performance and/or more feature-laden
;     version (with error detection perhaps?) should
;     still fit into 1k.  Are there any volunteers?
;   VTL02 is my free gift (?) to the world.  It may be
;     freely copied, shared, and/or modified by anyone
;     interested in doing so, with only the stipulation
;     that any liabilities arising from its use are
;     limited to the price of VTL02 (nothing).
;------------------------------------------------------
; VTL02 variables occupy RAM addresses $0080 to $00ff.
; They are little-endian, in the 6502 tradition.
; The use of lower-case and some control characters for
;   variable names is allowed, but not recommended; any
;   attempts to do so would likely result in chaos.
; Variables tagged with an asterisk are used internally
;   by the interpreter and may change without warning.
;   {@ _} cannot be entered via the command line, and
;   {$ ( ) 0..9 : > ?} are (usually) intercepted by the
;   interpreter, so their internal use by VTL02 is
;   "safe".  The same cannot be said for {; < =}, so
;   be careful!     
.alias 	at  $80    		;{@}* interpreter text pointer
; VTL02 standard user variable space
;          $82    {A B C .. X Y Z [ \ ] ^}
; VTL02 system variable space
.alias  under     $be    ;{_}* interpreter temp storage
;         $c0    { }  space is a valid variable
.alias  bang      $c2    ;{!}  return line number
.alias  quote     $c4    ;{"}  user ml subroutine vector
.alias  pound     $c6    ;{#}  current line number
.alias  dolr      $c8    ;{$}* temp storage / char i/o
.alias  remn      $ca    ;{%}  remainder of last division
.alias  ampr      $cc    ;{&}  pointer to start of array
.alias  tick      $ce    ;{'}  pseudo-random number
.alias  lparen    $d0    ;{(}* old line # / begin sub-exp
.alias  rparen    $d2    ;{)}* temp storage / end sub-exp
.alias  star      $d4    ;{*}  pointer to end of free mem
;          $d6    {+ , - . /}  valid variables
; Interpreter argument stack space
.alias  arg       $e0    ;{0 1 2 3 4 5 6 7 8 9 :}*
; Rarely used variables and argument stack overflow
;          $f6    {; < =}* valid variables
.alias  gthan     $fc    ;{>}* call user ml subroutine
.alias  ques      $fe    ;{?}* temp / terminal i/o
;           
.alias  nulstk    $01ff  ;system stack resides in page 1
.alias  linbuf    $0200  ;input line buffer
.alias  prgm      $400   ;VTL program grows from here ...
.alias  himem     $8000  ;up to the top of user RAM
;------------------------------------------------------
; Equates specific to the Kowalski simulator
;.alias  vtl02     $e800  ;interpreter cold entry point
;             (warm entry point is startok)
;.alias  io_area   $f000      ;configure simulator terminal I/O
;.alias  acia_tx   io_area+1  ;acia tx data register
;.alias  acia_rx   io_area+4  ;acia rx data register
;======================================================
    ;.org  vtl02  
;------------------------------------------------------
; Initialize program area pointers and start VTL02
;           
v_startx:
    cld
    lda  #<prgm  
    sta  ampr       ;{&} -> empty program
    lda  #>prgm  
    sta  ampr+1 
    lda  #<himem 
    sta  star       ;{*} -> top of user RAM
    lda  #>himem 
    sta  star+1 
startok:
    sec             ;request "OK" message
; - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Start/restart VTL02 command line with program intact
;           
start:
    ldx  #<nulstk    
    txs             ;reset the system stack pointer
    bcc  user       ;skip "OK" if carry clear
    jsr  outcr  
    lda  #'O
    jsr  outch  
    lda  #'K   
    jsr  outch
    jsr  outcr  
user:
    jsr  inln       ;input a line from the user
    ldx  #pound     ;cvbin destination = {#}
    jsr  cvbin      ;does line start with a number?
    bne  stmnt      ;yes: handle program line
;                   no: execute direct statement
; - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The main program execution loop
;           
eloop:
    php             ;(cc: program, cs: direct)
    jsr  exec       ;execute one VTL02 statement
    plp         
    lda  pound      ;(eq) if {#} is 0
    ora  pound+1    
    bcc  eloop2     ;if direct mode and {#} = 0
    beq  startok    ;then restart cmd prompt
    clc             ;if direct mode and {#} <> 0
    bne  xloop      ;then start execution @ {#}
eloop2:
    sec             ;if program mode and {#} = 0
    beq  xloop      ;then execute next line
    lda  pound+1    ;(false branch condition)
    cmp  lparen+1   
    bne  branch     ;else has {#} changed?
    lda  pound  
    cmp  lparen 
    beq  xloop      ;no: execute next line (cs)
branch: 
    ldy  lparen+1   
    ldx  lparen     ;yes: execute a VTL02 branch
    inx             ;(cs: forward, cc: backward)
    bne  branch2    ;{!} = {(} + 1 (return ptr)
    iny         
branch2: 
    stx  bang   
    sty  bang+1 
xloop:
    jsr  findln     ;find first/next line >= {#}
    iny             ;point to left-side of statement
    bne  eloop      ;execute statement at new {#}
;------------------------------------------------------
; Delete/insert program line or list program
;           
stmnt:   
    clc         
    lda  pound      ;{#} = 0?
    ora  pound+1    ;no: delete/insert line
    bne  skp2       ;yes: list program to terminal
; - - - - - - - - - - - - - - - - - - - - - - - - - - -
; List program to terminal and restart "OK" prompt
; entry:  Carry must be clear
; uses:   findln, outch, prnum, prstr, {@ ( )}
;           
list_:    
    jsr  findln     ;find program line >= {#}
    ldx  #lparen    ;line number for prnum
    jsr  prnum      ;print the line number
    lda  #$20       ;print a space instead of the
    jsr  outch      ;line length byte
    lda  #0         ;zero for delimiter
    jsr  prstr      ;print the rest of the line
    sec             ;continue at the next line
    bcs  list_      ;(always taken)
;------------------------------------------------------
; Delete/insert program line and restart command prompt
; entry:  Carry must be clear
; uses:   find, start, {@ _ # & * (}, linbuf
;           
skp2:    
    tya             ;save linbuf offset pointer
    pha         
    jsr  find       ;locate first line >= {#}
    bcs  insrt  
    lda  lparen 
    cmp  pound      ;if line doesn't already exist
    bne  insrt      ;then skip deletion process
    lda  lparen+1   
    eor  pound+1    
    bne  insrt  
    tax             ;x = 0
    lda  (at),y 
    tay             ;y = length of line to delete
    ;eor  #-1    
    eor #$ff
    adc  ampr       ;{&} = {&} - y
    sta  ampr   
    bcs  delt   
    dec  ampr+1 
delt:    
    lda  at     
    sta  under      ;{_} = {@}
    lda  at+1   
    sta  under+1    
delt2:   
    lda  under  
    cmp  ampr       ;delete the line
    lda  under+1    
    sbc  ampr+1 
    bcs  insrt  
    lda  (under),y  
    sta  (under,x)  
    inc  under  
    bne  delt2  
    inc  under+1    
    bcc  delt2      ;(always taken)
insrt:   
    pla         
    tax             ;x = linbuf offset pointer
    lda  pound  
    pha             ;push the new line number on
    lda  pound+1    ;the system stack
    pha         
    ldy  #2     
cntln:   
    inx         
    iny             ;determine new line length in y
    lda  linbuf-1,x ;and push statement string on
    pha             ;the system stack
    bne  cntln  
    cpy  #4         ;if empty line then skip the
    bcc  jstart     ;insertion process
    tax             ;x = 0
    tya         
    clc         
    adc  ampr       ;calculate new program end
    sta  under      ;{_} = {&} + y
    txa         
    adc  ampr+1 
    sta  under+1    
    lda  under  
    cmp  star   
    lda  under+1    ;if {_} >= {*} then the program
    sbc  star+1     ;won't fit in available RAM,
    bcs  jstart     ;so abort to the "OK" prompt
slide:   
    lda  ampr   
    bne  slide2 
    dec  ampr+1 
slide2:  
    dec  ampr   
    lda  ampr   
    cmp  at     
    lda  ampr+1 
    sbc  at+1   
    bcc  move       ;slide open a gap inside the
    lda  (ampr,x)   ;program just big enough to
    sta  (ampr),y   ;hold the new line
    bcs  slide      ;(always taken)
move:    
    tya         
    tax             ;x = new line length
move2:   
    pla             ;pull the statement string and
    dey             ;the new line number and store
    sta  (at),y     ;them in the program gap
    bne  move2  
    ldy  #2     
    txa         
    sta  (at),y     ;store length after line number
    lda  under  
    sta  ampr       ;{&} = {_}
    lda  under+1    
    sta  ampr+1 
jstart:  
    jmp  start      ;dump stack, restart cmd prompt
;------------------------------------------------------
; Point @[y] to the first/next program line >= {#}
; entry:  (cc): start search at beginning of program
;         (cs): start search at next line
;         ({@} -> beginning of current line)
; uses:   find, jstart, prgm, {@ # & (}
; exit:   if line not found then abort to "OK" prompt
;         else {@} -> found line, {#} = {(} = actual
;           line number, y = 2, (cc)
;           
findln:  
    jsr  find       ;find first/next line >= {#}
    bcs  jstart     ;if end then restart "OK" prompt
    lda  lparen 
    sta  pound      ;{#} = {(}
    lda  lparen+1   
    sta  pound+1    
    rts         
;------------------------------------------------------
; {?="...} handler; called from 'exec'
; list line handler; called from 'list'
;           
prstr:   
    iny         ;skip over the " or length byte
    tax         ;x = delimiter, fall through
; - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Print a string at @[y]
; x holds the delimiter char, which is skipped over,
;   not printed (a null byte is always a delimiter)
; pauses before returning if a key was pressed and
;   waits for another   
; restarts the command prompt with user program intact
;   if either key was ctrl-c
; escapes out eventually if delimiter or null not found
; entry:  @[y] -> string, x = delimiter char
; uses:   kbd, inch, keyin, start, outch, outrts
; exit:   (normal) @[y] -> null or byte after delimiter
;         (ctrl-c) dump the stack & restart "OK" prompt
;           
prmsg:   
    txa         
    cmp  (at),y     ;found delimiter or null?
    beq  prmsg2     ;yes: finish up
    lda  (at),y 
    beq  prmsg2 
    jsr  outch      ;no: print char to user
    iny             ;terminal and loop
    bpl  prmsg      ;(with safety escape)
prmsg2:  
    tax             ;save closing delimiter
    ;lda  acia_rx    ;any key = pause
    jsr  j_rchr	    ;any key
    bcc  prout      ;no: continue printing
    ;beq  prout      ;no: continue printing
    cmp  #$03       ; ctrl-c?
    beq  jstart     ; yes: abort to "OK" prompt
prpause:
    ;lda  acia_rx    ;any key = resume
    jsr  j_rchr     ;any key
    bcc  prpause    ;no: pause loop
    ;beq  prpause    ;no: pause loop
    cmp  #$03       ; ctrl-c?
    beq  jstart     ; yes: abort to "OK" prompt
prout:   
    txa             ;retrieve closing delimiter
    beq  outcr      ;always cr after null delimiter
    iny             ;skip over the delimiter
    lda  (at),y     ;if trailing char is ';' then
    cmp  #$3b       ;suppress the carriage return
    beq  outrts 
outcr:   
    lda  #LINE_END  ;cr to terminal
    bne  outch      ;(always taken)
;------------------------------------------------------
; Read char from user terminal into a with echo
;           
inch:
      jsr j_rchr	; read character
      bcs inch		; wait for character
;;    sty  dolr       ; save y reg
;;nobyw:
;;    lda  acia_rx    ; test data available
;;    beq  nobyw      ; branch if no byte waiting
;;    cmp  #10        ; remove lf to allow paste
;;    beq  nobyw      ; in the Kowalski I/O window
; some terminals send del when bs is pressed!
;    cmp  #127       ; convert delete to backspace
;    bne  conv_bs2del
;    lda  #8
;conv_bs2del
; code below would filter terminal escape sequences
; but requires a specific 10ms tick timer to work
;    cmp  #27        ; escape?
;    bne  skip_esc_no
;    ldy  #5         ; timer loop - 5*10ms
;skip_esc_next
;    lda  #1         ; ack last tick
;    sta  acia_st
;skip_esc_wait  
;    lda  acia_st
;    and  #1         ; next tick
;    beq  skip_esc_wait
;    dey
;    bne  skip_esc_next
;skip_esc_discard  
;    iny             ; any data = y > 1
;    lda  acia_rx
;    bne  skip_esc_discard
;    cpy  #1
;    bne  nobyw
;skip_esc_esc        ; escape only - send to vtl  
;    lda  #27
;    rts            ; don't echo escape to terminal
;skip_esc_no
;;    ldy  dolr       ; restore y reg
    and  #$7f       ; ensure char is positive ascii
    cmp  #$03       ; ctrl-c?
    beq  jstart     ; yes: abort to "OK" prompt
; - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Print ascii char in a to stdout
;           
outch:
; convert cr to cr lf
;;    cmp  #13        ; cr
;;    bne  skip_cr
;;    lda  #10
;;    sta  acia_tx
;;    jsr j_wchr
;;    lda  #13
skip_cr:    
; convert bs to erasing bs
;    cmp  #8         ; backspace?
;    bne  skip_bs
;    sta  acia_tx    ; make erasing backspace
;    lda  #' '
;    sta  acia_tx
;    lda  #8
;skip_bs
;;    sta  acia_tx    ; send byte to acia
     jsr j_wchr
outrts:  
    rts         
;------------------------------------------------------
; Execute a hopefully valid VTL02 statement at @[y]
; entry:  @[y] -> left-side of statement
; uses:   nearly everything
; exit:   note to {>} users: no registers or variables
;           are required to be preserved except the
;           system stack pointer, the text base pointer
;           {@}, and the original line number {(}
;         if there is a {"} directly after the assign-
;           ment operator, the statement will execute
;           as {?="...}, regardless of the variable
;           named on the left-side
;           
exec:    
    lda  (at),y     ;fetch left-side variable name
    beq  execrts    ;do nothing if null statement
    iny         
    ldx  #arg       ;initialize argument pointer
    jsr  convp      ;arg[{0}] = address of left-side
    bne  exec1      ;variable 
    lda  arg    
    cmp  #rparen    ;full line comment?
    beq  execrts    ;yes: do nothing with the rest
exec1:   
    iny             ;skip over assignment operator
    lda  (at),y     ;is right-side a literal string?
    cmp  #$22       ;yes: print the string with
    beq  prstr_x    ;trailing ';' check & return
    ldx  #arg+2     ;point eval to arg[{1}]
    jsr  eval       ;evaluate right-side in arg[{1}]
    lda  arg+2  
    ldx  arg+1      ;was left-side an array element?
    bne  exec3      ;yes: skip to default actions
    ldx  arg    
    cpx  #dolr      ;if {$=...} statement then print
    beq  outch      ;arg[{1}] as ascii character
    cpx  #gthan 
    bne  exec2      ;if {>=...} statement then call
    tax             ;user machine language routine
    lda  arg+3      ;with arg[{1}] in a, x regs
    jmp  (quote)    ;(MSB, LSB)
exec2:   
    cpx  #ques      ;if {?=...} statement then print
    beq  prnum0     ;arg[{1}] as unsigned decimal
exec3:   
    ldy  #0     
    sta  (arg),y    
    adc  tick+1     ;store arg[{1}] in the left-
    rol             ;side variable
    tax         
    iny         
    lda  arg+3  
    sta  (arg),y    
    adc  tick       ;pseudo-randomize {'}
    rol         
    sta  tick+1 
    stx  tick   
execrts: 
    rts         
prstr_x:
    jmp  prstr
;------------------------------------------------------
; {?=...} handler; called by 'exec'
;           
prnum0:  
    ldx  #arg+2     ;x -> arg[{1}], fall through
;------------------------------------------------------
; Print an unsigned decimal number (0..65535) in var[x]
; entry:  var[x] = number to print
; uses:   div, outch, var[x+2], preserves original {%}
; exit:   var[x] = 0, var[x+2] = 10
;           
prnum:
    lda  remn   
    pha             ;save {%}
    lda  remn+1 
    pha         
    lda  #10        ;divisor = 10
    sta  2,x    
    lda  #0     
    pha             ;null delimiter for print
    sta  3,x        ;repeat {
prnum2:  
    jsr  div        ;divide var[x] by 10
    lda  remn   
    ora  #'0        ;convert remainder to ascii
    pha             ;stack digits in ascending
    lda  0,x        ;order ('0' for zero)
    ora  1,x    
    bne  prnum2     ;} until var[x] is 0
    pla         
prnum3:
    jsr  outch      ;print digits in descending
    pla             ;order until delimiter is
    bne  prnum3     ;encountered
    pla         
    sta  remn+1     ;restore {%}
    pla         
    sta  remn   
    rts         
;------------------------------------------------------
; Evaluate a hopefully valid VTL02 expression at @[y]
;   and place its completed value in arg[x]
; A VTL02 expression is defined as a string of one or
;   more terms, separated by operators and terminated
;   with a null or an unmatched right parenthesis
; A term is defined as a variable name, a decimal
;   constant, or a parenthesized sub-expression; terms
;   are evaluated strictly from left to right
; A variable name is defined as a simple variable or an
;   array element expression enclosed in {: )}
; entry:  @[y] -> expression text, x -> argument
; uses:   getval, oper, argument stack area
; exit:   arg[x] = result, @[y] -> next text
;           
eval:    
    lda  #0     
    sta  0,x        ;start evaluation by simulating
    sta  1,x        ;{0+expression}
    lda  #$2b   
notdn:   
    pha             ;stack alleged operator
    inx             ;advance the argument stack
    inx             ;pointer
    jsr  getval     ;arg[x+2] = value of next term
    dex         
    dex         
    pla             ;retrieve and apply the operator
    jsr  oper       ;to arg[x], arg[x+2]
    lda  (at),y     ;end of expression?
    beq  evalrts    ;(null or right parenthesis)
    iny         
    cmp  #$29       ;no: skip over the operator
    bne  notdn      ;and continue the evaluation
evalrts: 
    rts             ;yes: return with final result
;------------------------------------------------------
; Put the numeric value of the term at @[y] into var[x]
; Some examples of valid terms:  123, $, H, (15-:J)/?)
;           
getval:  
    jsr  cvbin      ;decimal number at @[y]?
    bne  getrts     ;yes: return with it in var[x]
    lda  (at),y 
    iny         
    cmp  #$3f       ;user line input?
    bne  getval2    
    tya             ;yes:
    pha         
    lda  at         ;save @[y]
    pha             ;(current expression ptr)
    lda  at+1   
    pha         
    jsr  inln       ;input expression from user
    jsr  eval       ;evaluate, var[x] = result
    pla         
    sta  at+1   
    pla         
    sta  at         ;restore @[y]
    pla         
    tay         
    rts             ;skip over "?" and return
getval2: 
    cmp  #'$        ;user char input?
    bne  getval3    
    jsr  inch       ;yes: input one char
    sta  0,x        ;var[x] = char
    rts             ;skip over "$" and return
getval3: 
    cmp  #$28       ;sub-expression?
    beq  eval       ;yes: evaluate it recursively
    jsr  convp      ;no: first set var[x] to the
    lda  (0,x)      ;named variable's address,
    pha             ;then replace that address
    inc  0,x        ;with the variable's actual
    bne  getval4    ;value before returning
    inc  1,x    
getval4: 
    lda  (0,x)  
    sta  1,x    
    pla         
    sta  0,x    
getrts:  
    rts         
;------------------------------------------------------
; Apply the binary operator in a to var[x] and var[x+2]
; Valid VTL02 operators are +, -, *, /, <, and =
; Any other operator in a defaults to >=
;           
oper:    
    cmp  #$2b        ;addition operator?
    bne  oper2      ;no: next case
; - - - - - - - - - - - - - - - - - - - - - - - - - - -
add: 
    clc         
    lda  0,x        ;var[x] += var[x+2]
    adc  2,x    
    sta  0,x    
    lda  1,x    
    adc  3,x    
    sta  1,x    
    rts         
oper2:   
    cmp  #$2d        ;subtraction operator?
    bne  oper3      ;no: next case
; - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub: 
    sec         
    lda  0,x        ;var[x] -= var[x+2]
    sbc  2,x    
    sta  0,x    
    lda  1,x    
    sbc  3,x    
    sta  1,x    
    rts         
oper3:   
    cmp  #$2a        ;multiplication operator?
    bne  oper4      ;no: next case
; - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 16-bit unsigned multiply routine
;   overflow is ignored/discarded
;   var[x] *= var[x+2], var[x+2] = 0, {_} is modified
;           
mul: 
    lda  0,x    
    sta  under  
    lda  1,x        ;{_} = var[x]
    sta  under+1    
    lda  #0     
    sta  0,x        ;var[x] = 0
    sta  1,x    
mul2:    
    lsr  under+1    
    ror  under      ;{_} /= 2
    bcc  mul3   
    jsr  add        ;form the product in var[x]
mul3:    
    asl  2,x    
    rol  3,x        ;left-shift var[x+2]
    lda  2,x    
    ora  3,x        ;loop until var[x+2] = 0
    bne  mul2   
    rts         
oper4:   
    cmp  #$2f        ;division operator?
    bne  oper5      ;no: next case
; - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 16-bit unsigned division routine
;   var[x] /= var[x+2], {%} = remainder, {_} modified
;   var[x] /= 0 produces {%} = var[x], var[x] = 65535
;           
div: 
    lda  #0     
    sta  remn       ;{%} = 0
    sta  remn+1 
    lda  #16    
    sta  under      ;{_} = loop counter
div1:    
    asl  0,x        ;var[x] is gradually replaced
    rol  1,x        ;with the quotient
    rol  remn       ;{%} is gradually replaced
    rol  remn+1     ;with the remainder
    lda  remn   
    cmp  2,x    
    lda  remn+1     ;partial remainder >= var[x+2]?
    sbc  3,x    
    bcc  div2   
    sta  remn+1     ;yes: update the partial
    lda  remn       ;remainder and set the
    sbc  2,x        ;low bit in the partial
    sta  remn       ;quotient
    inc  0,x    
div2:    
    dec  under  
    bne  div1       ;loop 16 times
    rts         
;------------------------------------------------------
; Apply comparison operator in a to var[x] and var[x+2]
;   and place result in var[x] (1: true, 0: false)
; Warning:  Tightly packed spaghetti below!
;           
oper5:   
    sec             ;{_} = -2: less than,
    sbc  #$3e       ;-1: equal,
    sta  under      ;other: greater than or equal
    jsr  sub        ;var[x] -= var[x+2]
    inc  under      ;equality test?
    bne  oper5b 
    ora  0,x        ;yes: 'or' high and low bytes
    beq  oper5c     ;(cs) if 0
oper5a:  
    clc             ;(cc) if not 0
oper5b:  
    lda  #0     
    inc  under      ;less than test?
    bne  oper5c     ;no: default to >=
    bcs  oper5a     ;yes: complement carry
    sec         
oper5c:  
    rol  
oper5d:  
    sta  0,x        ;var[x] -> simple variable
    lda  #0     
    sta  1,x    
    rts             ;var[x] = 1 (true), 0 (false)
;------------------------------------------------------
; Set var[x] to the address of the variable named in a
; entry:  a holds variable name, @[y] -> text holding
;         array element expression (if a = ':')
; uses:   add, eval, oper5d, {&}    
; exit:   (eq): var[x] -> var, @[y] unchanged
;         (ne): var[x] -> array element, @[y] ->
;               following text
;           
convp:   
    cmp  #$3a        ;array element?
    beq  varray 
    asl             ;no: var[x] -> simple variable
    ora  #$80   
    bmi  oper5d 
varray:  
    jsr  eval       ;yes: evaluate array index at
    asl  0,x        ;@[y] and advance y
    rol  1,x    
    lda  ampr       ;var[x] -> array element
    sta  2,x    
    lda  ampr+1 
    sta  3,x    
    jmp  add    
;------------------------------------------------------
; If text at @[y] is a decimal constant, translate into
;   var[x] (discarding any overflow) and update y
; entry:  @[y] -> text containing possible constant
; uses:   mul, add, var[x], var[x+2], {@ _ ?}
; exit:   (ne): var[x] = constant, @[y] -> next text
;         (eq): var[x] = 0, @[y] unchanged
;         (cs): in all but the truly strangest cases
;           
cvbin:   
    sty  ques       ;save entry text position
    lda  #0     
    sta  0,x        ;var[x] = 0
    sta  1,x    
    sta  3,x    
cvbin2:  
    lda  (at),y     ;if char at @[y] is not a
    cmp  #$3a       ;decimal digit then stop
    bcs  cvbin3     ;the conversion
    sbc  #$2f 
    bcc  cvbin3 
    pha             ;save decimal digit
    lda  #10    
    sta  2,x    
    jsr  mul        ;var[x] *= 10
    pla             ;retrieve decimal digit
    sta  2,x    
    jsr  add        ;var[x] += digit
    iny             ;loop for more digits
    bpl  cvbin2     ;(with safety escape)
cvbin3:  
    cpy  ques       ;(ne) if y changed, (eq) if not
    rts         
;------------------------------------------------------
; Accept input line from user and store it in linbuf,
;   zero-terminated (allows very primitive edit/cancel)
; entry:  (jsr to inln or newln, not inln6)
; uses:   linbuf, inch, outcr, {@}
; exit:   @[y] -> linbuf
;           
inln6:   
;    cmp  #'@'       ;original escape?
    cmp  #27        ;escape?
    beq  newln      ;yes: discard entire line
    iny             ;line limit exceeded?
    bpl  inln2      ;no: keep going
newln:
    jsr  outcr      ;yes: discard entire line
inln:   
    ldy  #<linbuf   ;entry point: start a fresh line
    sty  at         ;{@} -> input line buffer
    ldy  #>linbuf    
    sty  at+1   
    ldy  #1     
inln5:   
    dey         
    bmi  newln  
inln2:   
    jsr  inch       ;get (and echo) one key press
;    cmp  #'_'       ;original backspace
    cmp  #8         ;backspace?
    beq  inln5      ;yes: delete previous char
    cmp  #$0d       ;cr?
    bne  inln3  
    jsr outcr	
    lda  #0         ;yes: replace with null
inln3:   
    sta  (at),y     ;put key in linbuf
    bne  inln6      ;continue if not null
    tay             ;y = 0
    rts         
;------------------------------------------------------
; Find the first/next stored program line >= {#}
; entry:  (cc): start search at program beginning
;         (cs): start search at next line after {@}
; uses:   prgm, {@ # & (}
; exit:   (cs): {@} >= {&}, {(} = garbage, y = 2
;         (cc): {@} -> found line, {(} = actual line
;               number, y = 2
;           
find:
    bcs  findnxt    ;cs: search begins at next line
    lda  #>prgm     ;cc: search begins at first line
    sta  at+1   
    lda  #<prgm     ;{@} -> first program line
    bcc  find1st    ;(always taken)
findnxt: 
    jsr  checkat    ;if {@} >= {&} then the search
    bcs  findrts    ;failed; return with (cs)
    lda  at     
    adc  (at),y     ;{@} += length of current line
find1st: 
    sta  at     
    bcc  getlpar    
    inc  at+1   
getlpar: 
    ldy  #0     
    lda  (at),y 
    sta  lparen     ;{(} = current line number
    cmp  pound      ;(invalid if {@} >= {&}, but
    iny             ;we'll catch that later...)
    lda  (at),y 
    sta  lparen+1   ;if {(} < {#} then try the next
    sbc  pound+1    ;program line
    bcc  findnxt    ;else the search is complete
checkat: 
    ldy  #2     
    lda  at         ;{@} >= {&} (end of program)?
    cmp  ampr   
    lda  at+1       ;yes: search failed (cs)
    sbc  ampr+1     ;no: clear carry
findrts:
    rts         
;------------------------------------------------------
;    .end  vtl02 
            
