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
      usage:            db      "usage: ",0x1B,"[1m"
                        db      "leapyear"
                        db      0x1B,"[0m"
                        db      " year", 10
                        db      "       year must be between -45 and 18446744073709551615 and not 0.",10
                        db      0x1B,"[3m"
                        db      "       - not before -45 because Julian took effect in 45 B.C.",10
                        db      "       - not zero because zero was not a year at all.",10
                        db      0x1B,"[0m"
      .length:          equ     $-usage
      
section .text
      global _start
 
_start:
      xor       r8, r8             ; sign flag = 0 (no minus sign)
      pop       rax                ; get argc
      cmp       rax, 1             ; no arguments
      je        .usage             ; print usage
      cmp       rax, 2             ; if more than two arguments
      jg        .usage             ; print usage
      pop       rax                ; get name of this program
      pop       rsi                ; get pointer to year string
      xor       rax, rax
      cld
.repeat:
      lodsb                        ; read byte at rsi
      and       al, al             ; if zero then we are at the end of string
      jz        .done
      cmp       al, "-"            ; first character can be minus
      jne        .nosign           ; if not then it may not appear again
      cmp       r8, 1              ; if sign is already set then we have two signs
      je        .usage             ; which is wrong so print usage
      mov       r8, 1              ; set sign flag r8
      jmp       .repeat            ; look for other minus signs
.nosign:                           ; now check rest of string
      cmp       al, "0"
      jb        .usage             ; if char below '0' then wrong input
      cmp       al, "9"
      ja        .usage             ; if char above '9' then wrong input
      and       al, 0x0F           ; unascii char
      ; fast multiply temporary result by ten
      shl       rdx, 1             ; rdx = rdx * 2
      mov       rcx, rdx           ; store in rcx = rdx * 2
      shl       rdx, 2             ; rdx = rdx * 4
      add       rdx, rcx           ; rdx = rdx * 10
      add       rdx, rax           ; add digit to rdx
      jmp       .repeat            ; repeat for all characters in string
.done:
      mov       rax, rdx           ; move decimal in rax
      and       rax, rax           ; if zero
      jz        .usage             ; then print usage, zero wasn't a year
      cmp       r8, 1              ; was year before 0, signflag in r8 = 1
      jne       .calculate         ; no, calculate leapyear
      cmp       rax, 45            ; yes, check the year
      jg        .usage             ; if greater than 45, print usage
.calculate:
      mov       rdi, rax           ; rdi = year (ABI)
      call      LeapYear           ; calculate leapyear
      and       rax, rax           ; if AL = -1 then no leapyear
      js        .noleap            ; year was no leap year
      mov       rsi, leap          ; year was a leap year
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
; in  :  RDI holds the year in hexadecimal format. Year is a positive number.
; out :  RAX = -1, no leap, RAX = 0 leap
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