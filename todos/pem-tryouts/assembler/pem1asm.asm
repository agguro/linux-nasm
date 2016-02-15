;Name:          pem1asm.asm
;Build:         see makefile
;Run:           ./pem1asm sourcefile -o binaryfile
;description:   Simple assembler for PEM1
;               -o creates binary file for PEM1 program.  This program cannot be run from any commandline!

BITS 64

[list -]
    %include "pem1asm.inc"
[list +]

%define ARGC 4
%define O_CREAT     0100

section .bss
    binary:             resb    16
    fdsource:           resq    1
    fddestination:      resq    1
    ptrSourceFile:      resq    1
    ptrDestinationFile: resq    1
section .data
    usageMessage:       db  "usage: pem1asm sourcefile -o binaryfile"
    usageMessageL:      equ $-usageMessage
    
    errorMessage:       db "error" ;;;;;;;
    errorMessageL:      equ $-errorMessage  ;;;;;;;;;;;;;
    errorOpening:       db  "error opening sourcefile: "
    errorOpeningL:       equ $-errorOpening
    errorcreatingfile:  db  "error creating destinationfile: "
    errorcreatingfileL:  equ $ - errorcreatingfile
    errorfileexistsp1:    db  "destination "
    errorfileexistsp1L:    equ $-errorfileexistsp1
    errorfileexistsp2:    db " file exists, overwrite [Y/n]"
    errorfileexistsp2L:    equ $-errorfileexistsp2
    
    charBuffer          db  0
    crlf                db  10
    dataTrue            db  0
    
    ; stat structure
    STAT stat

section .text

global _start
_start:
     
    pop     rax             ; argc
    cmp     rax, ARGC
    jne     showUsage       ; more arguments than needed
    pop     rax             ; pointer to programname
    pop     rsi             ; pointer to sourcefilename
    pop     rax             ; read option -o
    mov     ax, WORD[rax]
    cmp     ax, "-o"        ; option -o?
    jne     showUsage
    pop     rdi             ; read destination filename
    cmp     rdi, 0
    je      showUsage

    ; RSI has the pointer to the sourcefile
    ; RDI has the pointer to the destinationfile
    
    mov     QWORD[ptrSourceFile], rsi
    mov     QWORD[ptrDestinationFile], rdi
    
    ; Open the source file
    mov     rdi, QWORD [ptrSourceFile]
    mov     rsi, O_RDONLY
    mov     rax, SYS_OPEN
    syscall
    cmp     rax, 0
    jg      savefdsource
    mov     rsi, errorOpening
    mov     rdx, errorOpeningL
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall
    ; calculate length for displaying the name
    mov     rdi,QWORD [ptrSourceFile]
    mov     rcx, -1
    xor     al, al            ; search for terminating 0
    repne   scasb
    neg     rcx
    dec     rcx
    ; output source filename
    mov     rdx, rcx
    mov     rsi, QWORD [ptrSourceFile]
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall
    ; ouput a LineFeed
    mov     rsi, crlf
    mov     rdx, 1
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall
    jmp     exit
savefdsource:
    mov     [fdsource], rax
    
tryopenfile:
    ; try to open the destination file
    mov     rdi, QWORD[ptrDestinationFile]
    mov     rsi, O_RDONLY
    mov     rax, SYS_OPEN
    syscall
    ; if file doesn't exists create the file
    cmp     rax, 0              ; file exists?
    jl      createfile          ; file doesn't exists, create it
    ; the file exists, inform user
fileexists:
    push    rax                         ; save FD destination file
    ; display first part message
    mov     rsi, errorfileexistsp1
    mov     rdx, errorfileexistsp1L
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall
    ; calculate length destination filename
    mov     rdi, QWORD [ptrDestinationFile]
    mov     rcx, -1
    xor     al, al            ; search for terminating 0
    repne   scasb
    neg     rcx
    dec     rcx
    ; display destination filename
    mov     rdx, rcx
    mov     rsi, QWORD [ptrDestinationFile]
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall
    ; display second part of message
    mov     rsi, errorfileexistsp2
    mov     rdx, errorfileexistsp2L
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall    
    ; display LineFeed
    mov     rsi, crlf
    mov     rdx, 1
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall
    ; close the file if it may not be overwritten
    pop     rdi                         ; get FD destinationfile
    mov     rax, SYS_CLOSE
    syscall
    ; close the source file
    jmp     closesourcefile
    
createfile:        
    ; file doesn't exists, create the file with permissions 644 octal, taking umask in consideration
    mov     rsi, 644q              ; access mode
    mov     rax, SYS_CREAT
    syscall
    ; if we got a file descriptor than the file is created
    cmp     rax, 0
    jge     savefddestination
    ; display error creating file
    mov     rsi, errorcreatingfile
    mov     rdx, errorcreatingfileL
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall
    ; calculate the length
    mov     rdi, QWORD [ptrDestinationFile]
    mov     rcx, -1
    xor     al, al            ; search for terminating 0
    repne   scasb
    neg     rcx
    dec     rcx
    ; display destination file name
    mov     rdx, rcx
    mov     rsi, QWORD [ptrDestinationFile]
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall
    jmp     closesourcefile
    
savefddestination:
    mov     [fddestination], rax
; FROM HERE WE CAN START ASSEMBLING



; END OF ASSEMBLING

; SAVE the binary file to destination file
        mov     rsi, binary
        mov     rdx, 16
        mov     rdi, [fddestination]
        mov     rax, SYS_WRITE
        syscall
closefiles:
        ; close destinationfile
        mov   rdi, QWORD[fddestination]
        mov   rax, SYS_CLOSE
        syscall
        
        ; close sourcefile
closesourcefile:
        mov   rdi, QWORD[fdsource]
        mov   rax, SYS_CLOSE
        syscall
        jmp   exit
    
showUsage:
        mov   rsi, usageMessage
        mov   rdx, usageMessageL
        mov   rdi, STDOUT
        mov   rax, SYS_WRITE
        syscall
exit:        
        mov     rdi, 0
        mov     rax, SYS_EXIT
        syscall
;*********************************************
; END PROGRAM

ReadTheFileSpec:
      mov   rdi, rax
      mov   rsi, stat
      mov   rax, SYS_FSTAT
      syscall
      
      mov   rcx, QWORD [stat.st_size]   ; get the file size
      mov   rax, QWORD [stat.st_ino]    ; file inode
      
      pop   rax         ; restore fd
      
      push  rax
ReadFileContents:
      push  rcx
      mov   rdi, rax        ; fd in RDI
      mov   rsi, charBuffer     ; place for one byte
      mov   rdx, 1          ; read one char at the time
      push  rax
      mov   rax, SYS_READ
      syscall
      call Print
      pop   rax
      pop   rcx
      dec   rcx
      cmp   rcx, 0
      jne   ReadFileContents

      call  PrintCRLF
      nop
      nop
      
CloseFile:
      pop   rax
      mov   rdi, rax        ; file descriptor in RDI
      mov   rax, SYS_CLOSE      ; close the file
      syscall
      jmp   Exit

      call  Print
      call  PrintCRLF
      jmp   Exit      
      
Error:
      mov   rsi, errorMessage
      mov   rdx, errorMessageL
      call  Print
      neg   rax         ; get the error
      xor   rcx, rcx
getNextBits:
      inc   rcx 
      cmp   rcx, 17         ; 16 bytes processed?
      je    ErrorEnd        ; Exit program
      xor   rdx, rdx
      rcl   rax, 1          ; get 4 bits starting at MSBit
      rcl   rdx, 1          ; store in rdx
      rcl   rax, 1          ; get next bit starting at MSBit
      rcl   rdx, 1          ; store in rdx
      rcl   rax, 1          ; get next bit starting at MSBit
      rcl   rdx, 1          ; store in rdx
      rcl   rax, 1          ; get next bit starting at MSBit
      rcl   rdx, 1          ; store in rdx
      cmp   BYTE[dataTrue], 1   ; are there already databits printed?
      je    skipZeroCheck
      cmp   dl, 0           ; data in it?
      jz    getNextBits
      mov   BYTE[dataTrue], 1   ; when dataTrue is True then print al following zeros
skipZeroCheck:      
      cmp   dl,9
      jle   toASCII
      add   dl,7
toASCII:
      add   dl, "0"
      mov   BYTE[charBuffer], dl
      mov   rsi, charBuffer
      mov   rdx, 1
      call  Print           ; print the byte
      jmp   getNextBits
ErrorEnd:
      call  PrintCRLF
      jmp   Exit
      
Print:
      push  rax
      push  rdi
      push  rcx
      mov   rdi, STDOUT
      mov   rax, SYS_WRITE
      syscall
      pop   rcx
      pop   rdi
      pop   rax
      ret

PrintCRLF:
      mov   rsi, crlf
      mov   rdx, 2
      call  Print
      ret
      
Exit:      
      xor   rdi, rdi
      push  SYS_EXIT
      pop   rax
      syscall