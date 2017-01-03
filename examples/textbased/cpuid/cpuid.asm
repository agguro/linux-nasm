; Name:         cpuid
;
; Build:        nasm "-felf64" cpuid.asm -l cpuid.lst -o cpuid.o
;               ld -s -melf_x86_64 -o cpuid cpuid.o 
;
; Description:  Checks if CPUID instruction is supported and if yes, shows also the Vendor ID
;
; Remark:
; To-Do:        Extend the program to show CPU capabilities and properties

bits 64

[list -]
    %include "cpu/cpu.inc"
    %include "unistd.inc"
[list +]

section .bss

section .data

    output:          db      "The processor Vendor ID is '"
    .regEBXvalue:    db      "xxxx"
    .regEDXvalue:    db      "xxxx"
    .regECXvalue:    db      "xxxx"
                    db      "'", 10
    .length:         equ     $-output

    nosupport:       db      "CPUID is not supported", 10
    .length:         equ     $-nosupport

section .text
        global _start

_start:

bits 32         ; assemble in 32 bit mode
        
    ; returns 1 if CPUID is supported, 0 otherwise (ZF is also set accordingly)
    pushfd                                  ; get 32 bits flags
    pop     eax                             ; and put in EAX
    mov     ecx, eax                        ; save the original flags state in ECX 
    xor     eax, 0x200000                   ; flip bit 21 
    push    eax                             ; and put via EAX
    popfd                                   ; on stack
    pushfd                                  ; get the flags again
    pop     eax                             ; put in EAX
    xor     eax, ecx                        ; and check if bit 21 is the same as stored before
    shr     eax, 21                         ; move bit 21 to bit 0
    and     eax, 1                          ; and mask others
    push    ecx                             ;
    popfd                                   ; and restore original flags
    jz      .notSupported

; 64 bit assembly from here or we have Segmentation fault error
bits 64

    ; CPUID is supported
    xor     eax,eax                         ; get vendor ID
    cpuid
    mov     [output.regEBXvalue],ebx        ; first 4 letters of vendor from ebx in place
    mov     [output.regEDXvalue],edx        ; next 4 letters of vendor from edx in place
    mov     [output.regECXvalue],ecx        ; last 4 letters of vendor from ecx in place
    mov     rsi, output                     ; address message in RSI
    ; we cannot save the length of the message in RDX without losing 4 letters of the vendor id,
    ; therefor we put it on the stack
    push    output.length                   ; message length on stack
    jmp     Write                           ; write the message to STDOUT

.notSupported:
    mov     rsi, nosupport
    mov     rdx, nosupport.length
    jmp     Write.syscall
Write:
    pop     rdx                             ; message length from stack
.syscall:    
    syscall write, stdout

    ; exit program
    syscall exit, 0
