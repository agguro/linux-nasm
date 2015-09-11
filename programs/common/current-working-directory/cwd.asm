; Name:         cwd.asm
; Build:        see makefile
; Description:  Linux alternative for pwd.
;               returns the current working directory.

bits 64

[list -]
     %include "unistd.inc"
[list +]

section .bss
      
section .data
     errorNoMemory:            db "Error: out of memory"
     lf:                       db 10                                           ; linefeed
     errorNoMemory.length:     equ $-errorNoMemory
      
section .text
     global _start       
_start:
     xor       rdi, rdi                        ; get start of heap
     mov       rax, SYS_BRK
     syscall
     and       rax, rax
     js        error                           ; no more memory available
     mov       r8, rax                         ; save the current memory break
repeat: 
     add       rax, 16                         ; add 16 bytes to the current memory break
     mov       rdi, rax
     mov       rax, SYS_BRK
     syscall
     xor       rax, rdi                        ; rax = new memory pointer
     jz        getcwd                          ; if zero then memory is allocated
     ; no memory could be allocated, free the memory already allocated
     mov       rdi, r8
     mov       rax, SYS_BRK
     jmp       error
getcwd:
     mov       rsi, rdi
     sub       rsi, r8
     mov       rdi, r8                         ; start of buffer
     mov       rax, SYS_GETCWD                 ; get current working directory
     syscall
     and       rax, rax
     jns       printit                         ; if RAX < 0 then buffer not large enough
     mov       rax, rdi                        ; buffer not large enough rax = r8
     add       rax, rsi                        ; add size of already allocated memory -> new memory break
     jmp       repeat                          ; retry allocating more memory
printit:        
     mov       rsi, r8                         ; start of heap in rsi
     mov       rdx, rax                        ; length of directory string in rdx
     xor       rax, rax
     inc       rax                             ; rax = 1 : syscall write
     mov       rdi, rax                        ; rdi = 1 : STDOUT
     syscall                                   ; write directory to STDOUT
     mov       rsi, lf                         ; linefeed
     mov       rdx, rdi                        ; rdx = rdi = 1 : length of linefeed (1 byte)
     mov       rax, rdi                        ; rax = rdi = 1 : syscall write
     syscall                                   ; write linefeed to STDOUT
     jmp       exit
error:
     mov       rsi, errorNoMemory              ; rsi : error string
     mov       rdx, errorNoMemory.length       ; rdx : error string length
     xor       rax, rax
     inc       rax                             ; rax = 1 : syscall write
     mov       rdi, rax                        ; rdi = 1 : STDOUT
     syscall                                   ; write error string
exit:
     xor       rdi, rdi                        ; no error
     mov       rax, SYS_EXIT                   ; exit
     syscall