;
; M-OS kernel for a minimal system
;
;


;
; JUMP Table for several kernel routines
;
; called with JSR <name>
;
; this table should be located at the beginning of the ROM image
; to provide reliable addresses for internal functions even if the
; real start addresses of the routines move to different locations
; during development
;
; In software not directly bundled with the ROM image only these
; addresses should be used to access these functions.
;
;

j_wstr:		jmp k_wstr
j_wchr:		jmp k_wchr
j_rchr:  	jmp k_rchr
j_a2b:		jmp k_ascii2byte
j_bin8out: 	jmp u_bin8out
j_hex8out: 	jmp u_hex8out
j_hex4out: 	jmp u_hex4out	
j_chr2nibble: 	jmp u_chr2nibble

;k_RESET
;k_NMI
;k_IRQ
