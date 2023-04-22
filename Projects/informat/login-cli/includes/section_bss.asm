;project:       Informat
;
;name:          section_bss.asm
;
;description:   uninitialized data section for informat.asm
;
;note:          this file may not be assembled, only included in login-cli.asm

bits 64

section .bss

; memory management
    heap_start:         resq    1
    heap_size:          resq    1
    new_heap_start:     resq    1
	
    ;socket
    fdsocket:           resq    1
