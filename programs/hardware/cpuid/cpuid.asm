; Name:         cpuid
; Build:        see makefile
; Run:          ./cpuid
; Description:  Show the if CPUID instruction is supported and if yes, the Vendor ID
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

BITS 32         ; assemble in 32 bit mode
        
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

BITS 64

        ; CPUID is supported
        xor     eax,eax                         ; get vendor ID
        cpuid
        mov     [output.regEBXvalue],ebx        ; first 4 letters of vendor from ebx in place
        mov     [output.regEDXvalue],edx        ; next 4 letters of vendor from edx in place
        mov     [output.regECXvalue],ecx        ; last 4 letters of vendor from ecx in place
        push    output                          ; offset message on stack
        push    output.length                   ; message length on stack
        jmp     Write                           ; write the message to STDOUT

.notSupported:
        push    nosupport
        push    nosupport.length
        
Write:
        pop     rdx                             ; message length from stack
        pop     rsi                             ; message offset from stack
        mov     rdi, STDOUT                     ; to terminal screen
        mov     rax, SYS_WRITE                  ; the write system call
        syscall

        ; exit program
        mov     rax, SYS_EXIT
        xor     rdi,rdi
        syscall