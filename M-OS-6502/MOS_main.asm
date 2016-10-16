;
; M-OS 
;
; Mouse-OS main file 
;
; the ROM image is always built from this main file
; 

;
; first define the macros used in the code
;
.require "MIOS_macros.asm"

;
; load the defines for memory locations
;
.require "MIOS_defines.asm"


;
; define the start-address of the tool that should be startet by the
; kernel after reset und k_START
;
.alias MOUSESTART m_start	; define the monitor programm as start entry 

;
; set the assembler to the start-address of the ROM image
;
.org ROM_START

;
; the jumptable should always be the first part after ROM start
;
.require "MIOS_kernel_jmptable.asm"

;
; include all other parts of the system
;

.require "MOS_monitor.asm"
.require "SW_vtl2a.asm"
.require "SW_chess.asm"
.require "SW_disassembler.asm"


;
; the kernel is the last part, because it defines the RESET and IRQ
; vectors at the end of the file.
; 
.require "MIOS_kernel.asm"
