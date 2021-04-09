;name: cpuid.asm
;
;description: Checks if CPUID instruction is supported and if yes, shows also the Vendor ID
;

    %include "../../../qmake/basics/cpuid/cpuid.inc"

global main

section .bss
;uninitialized read-write data 

section .data
;initialized read-write data
    output:         db  "The processor Vendor ID is '"
    .regEBXvalue:   db  "xxxx"
    .regEDXvalue:   db  "xxxx"
    .regECXvalue:   db  "xxxx"
                    db  "'", 10
    .len:           equ $-output

    nosupport:      db  "CPUID is not supported", 10
    .len:           equ $-nosupport

section .rodata
;read-only data

section .text

main:
    push    rbp
    mov     rbp,rsp

;assemble in 32 bit mode
bits 32

    ;returns 1 if CPUID is supported, 0 otherwise (ZF is also set accordingly)
    pushfd                                  ;get 32 bits flags
    pop     eax                             ;and put in EAX
    mov     ecx,eax                         ;save the original flags state in ECX
    xor     eax,0x200000                    ;flip bit 21
    push    eax                             ;and put via EAX
    popfd                                   ;on stack
    pushfd                                  ;get the flags again
    pop     eax                             ;put in EAX
    xor     eax,ecx                         ;and check if bit 21 is the same as stored before
    shr     eax,21                          ;move bit 21 to bit 0
    and     eax,1                           ;and mask others
    push    ecx                             ;
    popfd                                   ;and restore original flags
    test    eax,eax                         ;if eax is zero then CPUID is not supported
    jnz     .supported

;assemble in 32 bit mode
bits 64

    syscall write,stdout,nosupport,nosupport.len
    syscall exit

    .supported:
    ; CPUID is supported
    xor     eax,eax                         ;get vendor ID
    cpuid
    mov     [output.regEBXvalue],ebx        ;first 4 letters of vendor from ebx in place
    mov     [output.regEDXvalue],edx        ;next 4 letters of vendor from edx in place
    mov     [output.regECXvalue],ecx        ;last 4 letters of vendor from ecx in place
    syscall write,stdout,output,output.len

    xor     rax,rax             ;return error code
    mov     rsp,rbp
    pop     rbp
    ret                         ;exit is handled by compiler
