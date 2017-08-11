; Name:         leapyear.asm
;
; Build:        nasm -felf64 leapyear.asm -o leapyear.o 
;
; in  :  RDI holds the year in hexadecimal format. Year is a positive number.
; out :  RAX = -1, no leap, RAX = 0 leap

global pagesize
    
section .text

LeapYear:
      push      rbx                ; save used registers
      push      rcx
      push      rdx
      mov       rax, rdi
      xor       rcx, rcx           ; help register = 0
      dec       rcx                ; assume not leap, rcx = -1
      test      rax, 3             ; last two bits 0?
      jnz       .@1                ; if not year is not disible by 4 -> no leapyear
      inc       rcx                ; assume year is a leapyear, rcx = 0
      xor       rdx, rdx           ; prepare rdx for division
      mov       rbx, 100           ; year / 100
      div       rbx
      and       rdx, rdx           ; remainder = 0?
      jnz       .@1                ; no, no leapyear
      test      rax, 3             ; multiples of 100 aren't leap years except if last two bits
                                   ;  are zero 0 (divisible by 4) then also divisible by 400
      jz        .@1                ; yes, leap year
      dec       rcx                ; no, not leap year, rcx = -1
.@1:
      mov       rax, rcx           ; mov result in RAX
      pop       rdx
      pop       rcx
      pop       rbx
      ret