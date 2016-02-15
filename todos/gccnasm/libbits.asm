; name:         libbits.asm
; build:
;               nasm -f elf64 -o libbits.o libbits.asm -l libbits.lst
;               ar rcs libbits.a libbits.o
;
; Description:  Bit functions
; Source:	Hackers Delight

bits 64
align 16


section .data
        string: db "this a teststring", 0
      
      
section .text

global  NumberOfLeadingZeros
global  Array
global  Execute

NumberOfLeadingZeros:

      ;int 3
      push	rbp
      mov	rbp, rsp
      add	rsp, 16				; return address and RBP = 2 x 8 bytes
      
      mov	rax, rdi			; get the integer and return
    ;  mov	rax, rsi
    ;  mov	rax, rdx
    ;  mov	rax, rcx
    ;  mov	rax, r8
    ;  mov	rax, r9
    ;  mov	rax, QWORD[rsp]			; first parameter
    ;  mov	rax, QWORD[rsp + 8]		; second parameter
    ;  mov	rax, QWORD[rsp + 16]		; third parameter
    ;  mov	rax, QWORD[rsp + 24]		; fourth parameter
    ;  xmm0                                     ; floating point
      
      
      sub	rsp, 16				; restore stackframe
      mov	rsp, rbp
      pop	rbp
      
      nop
      nop
     
      ret
      
Array:
      shl	rsi, 2				; 4 bytes in each dword      
      add	rsi, rdi			; add array pointer
      cld
      lodsd					; eax = item in array
      ret
      
Execute:
      mov	rax, rdi
      call	rax
      ret