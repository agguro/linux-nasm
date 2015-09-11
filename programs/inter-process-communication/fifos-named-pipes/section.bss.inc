%define FIFO_NAME   "fifo-buffer"

section .bss

     fd:            resq      1                                  ; file descriptor of named pipe
     buffer:        resb      300                                ; buffer to write to
     .length:       equ       $-buffer
     num            resq      1
     numbuffer:
     .hundreds:     resb      1
     .tens:         resb      1
     .digits:       resb      1