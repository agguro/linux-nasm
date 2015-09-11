; Name:     uuid.asm
;
; Purpose:  Generates a UUID
;
; Remark:   Because UUID need to be unique (that's why U stands for) the user need to
;           check each generated UUID against a table which contains already generated UUID's.
;           This algorithm applied 10000 gives 51 same UUIDs, 100000 times gives 135 same UUIDs, 1000000 gives us 18884 same UUIDs.
;           which is in some applications a nice result.

[list -]
        %include "unistd.inc"
[list +]

BITS 64

section .data
      uuid:           
      .g1:            db      0,0,0,0,0,0,0,0
      .g2:            db      0,0,0,0
      .g3:            db      0,0,0,0
      .g4:            db      0,0,0,0
      .g5:            db      0,0,0,0,0,0,0,0,0,0,0,0
      .length:        equ     $-uuid
      crlf:           db      10
      hyphen:         db      "-"

section .text
      global _start
_start:
      mov       rdi, uuid  
      call      GenerateGUID
      ; convert to ascii
      mov       rsi, uuid
      mov       rdi, uuid
      mov       rcx, 32
nextDigit:      
      cld
      lodsb
      call      NIBBLEtoHexASCII
      stosb
      loop      nextDigit
      call      ShowGUID
      mov       rax, SYS_EXIT
      xor       rdi, rdi
      syscall

ShowGUID:
; in  :: RDI = pointer to GUID string (32 bytes long)
; out :: void
      mov       rdi, STDOUT
      mov       rax, SYS_WRITE
      mov       rsi, uuid
      mov       rdx, 8
      syscall
      mov       rsi, hyphen
      mov       rdx, 1
      mov       rax, SYS_WRITE
      syscall
      mov       rsi, uuid.g2
      mov       rdx, 4
      mov       rax, SYS_WRITE
      syscall
      mov       rsi, hyphen
      mov       rdx, 1
      mov       rax, SYS_WRITE
      syscall
      mov       rsi, uuid.g3
      mov       rdx, 4
      mov       rax, SYS_WRITE
      syscall
      mov       rsi, hyphen
      mov       rdx, 1
      mov       rax, SYS_WRITE
      syscall      
      mov       rsi, uuid.g4
      mov       rdx, 4
      mov       rax, SYS_WRITE
      syscall
      mov       rsi, hyphen
      mov       rdx, 1
      mov       rax, SYS_WRITE
      syscall      
      mov       rsi, uuid.g5
      mov       rdx, 12
      mov       rax, SYS_WRITE
      syscall
      mov       rsi, crlf
      mov       rdx, 1
      mov       rax, SYS_WRITE
      syscall
      ret
      
GenerateGUID:
; in  :: RDI = pointer to buffer to store 32 bytes
; out :: RDI = pointer to buffer with GUID
      mov       rcx, 32
.@@1:      
      mov       rax, 0                          ; lower boundary of interval
      mov       rdx, 0xF                        ; higher boundary of interval
      call      GenerateRandom
      cld
      stosb
      loop      .@@1
      ret      

NIBBLEtoHexASCII:
; in  :: AL = NIBBLE or 4 bits (least significant)
; out :: AL = Hexadecimal ASCII of NIBBLE
      and       al, 0x0F
      or        al, "0"
      cmp       al, "9"
      jbe       .@@1
      add       al, 39
.@@1:
      ret

GenerateRandom:
; in RAX :: lower boundary of interval
;    RDX :: higher boundary of interval
      ; interval length is 0xF
      mov       rbx, 0xF
      rdtsc                     ; read cpu time stamp counter
      push      rax
      rdtsc                     ; read cpu time stamp counter
      mov       rax, rdx
      pop       rax     
      rol       rdx, 32         ; mov EDX in high 32 bits of RAX
      or        rax, rdx        ; RAX = seed
      call      XorShift        ; get a pseudo random number

      and       rax, 0xF
      ret
      
XorShift:
      mov       rdx, rax        ; XORSHIFT algorithm
      shl       rax, 13
      xor       rax, rdx
      mov       rdx, rax
      shr       rax, 17
      xor       rax, rdx
      mov       rdx, rax
      shl       rax, 5
      xor       rax, rdx        ; RAX random 64 bit value
      ret