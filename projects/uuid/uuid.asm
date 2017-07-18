; Name:         uuid.asm
;
; Build:        nasm "-felf64" uuid.asm -l uuid.lst -o uuid.o
;               ld -s -melf_x86_64 -o uuid uuid.o
;
; Description:  Generates a UUID
;
; Remark:
; Because UUID need to be unique (that's why U stands for) the user need to
; check each generated UUID against a table which contains already generated
; UUID's. This algorithm applied 10000 gives 51 same UUIDs, 100000 times
; gives 135 same UUIDs, 1000000 gives us 18884 same UUIDs. So check the presence
; of an already generated uuid. Another possibility is the use of mysql uuid
; but requires the installation of mysql server.

[list -]
        %include "unistd.inc"
[list +]

bits 64

section .data
      uuid:           
      .group1:        db      0,0,0,0,0,0,0,0
      .group2:        db      0,0,0,0
      .group3:        db      0,0,0,0
      .group4:        db      0,0,0,0
      .group5:        db      0,0,0,0,0,0,0,0,0,0,0,0

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
      syscall   exit, 0

ShowGUID:

      syscall   write, stdout, uuid.group1, 8
      syscall   write, stdout, hyphen, 1
      syscall   write, stdout, uuid.group2, 4
      syscall   write, stdout, hyphen, 1
      syscall   write, stdout, uuid.group3, 4
      syscall   write, stdout, hyphen, 1
      syscall   write, stdout, uuid.group4, 4
      syscall   write, stdout, hyphen, 1
      syscall   write, stdout, uuid.group5, 12
      syscall   write, stdout, crlf, 1
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
      jbe       .done
      add       al, 39
.done:
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
