;project:       Informat
;
;name:          section_bss.asm
;
;date:          17 aug 2020
;
;description:   uninitialized data section for informat.asm

bits 64

section .bss

; memory management
    heap_start:         resq    1
    heap_size:          resq    1
    new_heap_start:     resq    1
	
    ;socket
    fdsocket:           resq    1
