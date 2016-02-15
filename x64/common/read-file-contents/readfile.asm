;Name:      readfile
;Build:     see makefile
;Run:       ./readfile filename
;description:   shows the contents of a file in plain text, quit the same as linux cat command   

BITS 64

[list -]
    %include "unistd.inc"
    %include "sys/stat.inc"
[list +]

section .bss
    data:           resb    1
    
section .data
    usageMessage:   db  "usage: readfile filename",10
    .length:        equ $-usageMessage
    errorMessage:   db  "The program terminated with error: 0x"
    .length:        equ $-errorMessage
    charBuffer:     db  0
    crlf:           db  10

    ; file status structure
    STAT stat                                     ; in sys/stat.inc

section .text

global _start
_start:
     
      pop       rax                             ; argc
      pop       rax                             ; pointer to name
      pop       rcx                             ; pointer to file
      jz        showUsage
      pop       rax                             ; more arguments?
      or        rax, rax
      jnz       showUsage                       ; yes, show the usage message

OpenFile:      
      mov       rsi, O_RDONLY
      mov       rdi, rcx
      mov       rax, SYS_OPEN
      syscall
      cmp       rax, 0
      jl        Error
      push      rax                             ; save fd
        
ReadTheFileSpec:
      pop       rdi                             ; get fd
      push      rdi                             ; save fd
      mov       rsi, stat                       ; stat structure pointer
      mov       rax, SYS_FSTAT
      syscall
           
      mov       rcx, QWORD [stat.st_size]       ; get the file size
     
ReadFileContents:
      push      rcx
      mov       rsi, charBuffer                 ; place for one byte
      mov       rdx, 1                          ; read one char at the time
      mov       rax, SYS_READ
      syscall
      
      call      Print
      pop       rcx
      dec       rcx
      cmp       rcx, 0
      jne       ReadFileContents

      call      PrintCRLF
      
CloseFile:
      pop       rdi                             ; fd in RDI
      mov       rax, SYS_CLOSE                  ; close the file
      syscall
      jmp       Exit

showUsage:
      mov       rsi, usageMessage
      mov       rdx, usageMessage.length
      call      Print
      jmp       Exit      
      
Error:
      mov       rsi, errorMessage
      mov       rdx, errorMessage.length
      call      Print
      neg       rax                             ; get the error
      xor       rcx, rcx
getNextBits:
      inc       rcx 
      cmp       rcx, 17                         ; 16 bytes processed?
      je        ErrorEnd                        ; Exit program
      xor       rdx, rdx
      rcl       rax, 1                          ; get 4 bits starting at MSBit
      rcl       rdx, 1                          ; store in rdx
      rcl       rax, 1                          ; get next bit starting at MSBit
      rcl       rdx, 1                          ; store in rdx
      rcl       rax, 1                          ; get next bit starting at MSBit
      rcl       rdx, 1                          ; store in rdx
      rcl       rax, 1                          ; get next bit starting at MSBit
      rcl       rdx, 1                          ; store in rdx
      cmp       BYTE[data], 1                   ; are there already databits printed?
      je        skipZeroCheck
      cmp       dl, 0                           ; data in it?
      jz        getNextBits
      mov       BYTE[data], 1                   ; when data is True then print al following zeros
skipZeroCheck:      
      cmp       dl,9
      jle       toASCII
      add       dl,7
toASCII:
      add       dl, "0"
      mov       BYTE[charBuffer], dl
      mov       rsi, charBuffer
      mov       rdx, 1
      call      Print                           ; print the byte
      jmp       getNextBits
ErrorEnd:
      call      PrintCRLF
      jmp       Exit
      
Print:
      push      rax
      push      rdi
      push      rcx
      mov       rdi, STDOUT
      mov       rax, SYS_WRITE
      syscall
      pop       rcx
      pop       rdi
      pop       rax
      ret

PrintCRLF:
      mov       rsi, crlf
      mov       rdx, 1
      call      Print
      ret
      
Exit:      
      xor       rdi, rdi
      push      SYS_EXIT
      pop       rax
      syscall