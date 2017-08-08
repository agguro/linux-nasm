; Name:         leapyear.asm
;
; Build:        nasm "-felf64" leapyear.asm -l leapyear.lst -o leapyear.o
;               ld -s -melf_x86_64 -o leapyear leapyear.o 
;
; Description:  reads a year from the commandline and determine if a year is a leapyear or not. The result is printed to STDOUT.
;

bits 64

[list -]
      %include "unistd.inc"
[list +]
 
 
section .bss
      sign:             resb    1
section .data
      noleap:           db      "no "
      leap:             db      "leapyear", 10
      noleap.length:    equ     $-noleap
      leap.length:      equ     $-leap
      usage:            db      "usage: leapyear year", 10
                        db      "       year must be an integer bigger than -46 and not larger than a 18446744073709551615 bits integer and non-zero.", 10
                        db      "                 not less than -45 because Julian took effect in 45 B.C.",10
                        db      "                 not zero because zero wasn't a year at all.", 10
      .length:          equ     $-usage
      
section .text
      global _start
 
_start:
      xor       r8, r8             ; sign flag = 0 (no minus sign)
      pop       rax
      cmp       rax, 1
      jle       .usage
      cmp       rax, 2
      jg        .usage
      pop       rax
      pop       rsi
      xor       rax, rax
      cld
.repeat:
      lodsb
      and       al, al
      jz        .done
      cmp       al, "-"
      jne        .nosign
      cmp       r8, 1                ; if sign is already set then we have two signs thus an error
      je        .usage
      mov       r8, 1
      jmp       .repeat
.nosign:      
      cmp       al, "0"
      jb        .usage
      cmp       al, "9"
      ja        .usage
      and       al, 0x0F
      shl       rdx, 1
      mov       rcx, rdx
      shl       rdx, 2
      add       rdx, rcx
      add       rdx, rax
      jmp       .repeat
.done:
      mov       rax, rdx
      and       rax, rax
      jz        .usage
      cmp       r8, 1
      jne       .calculate
      cmp       rax, 45
      jg        .usage
.calculate:
      call      LeapYear
      and       al, al
      jz        .noleap
      mov       rsi, leap
      mov       rdx, leap.length
      jmp       .write
.noleap:
      mov       rsi, noleap
      mov       rdx, noleap.length
      jmp       .write
.usage:
      mov       rsi, usage
      mov       rdx, usage.length
.write:
      syscall   write, stdout
.exit:      
      syscall   exit, 0

; LeapYear
; RAX holds the year in hexadecimal format. Year is a positive number.
LeapYear:
      xor       rcx, rcx                        ; help register = 0
      test      rax, 3                          ; last two bits 0?
      jnz       .@1                             ; if not year is not disible by 4 -> no leapyear
      inc       rcx                             ; assume year is a leapyear
      xor       rdx, rdx                        ; prepare rdx for division
      mov       rbx, 100                        ; year / 100
      div       rbx
      and       rdx, rdx                        ; remainder = 0?
      jnz       .@1                             ; no, no leapyear
      xor       rcx, rcx                        ; yes, multiples of 100 aren't leap years...
      test      rax, 3                          ; ...except if last two bits are zero 0 (divisble by 4)
      jnz       .@1                             ; no, not leap year
      mov       rcx, 1                          ; if last two bits are zero then year is divisible by 4 too, so divisible by 400 = leapyear
.@1:
      mov       rax, rcx                        ; mov result in RAX
      ret
