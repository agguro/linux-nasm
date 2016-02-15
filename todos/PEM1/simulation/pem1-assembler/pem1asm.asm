;Name:          pem1asm.asm
;Build:         see makefile
;Run:           ./pem1asm sourcefile -o binaryfile
;description:   Simple assembler for PEM1
;               -o creates binary file for PEM1 program.  This program cannot be run from any commandline!

BITS 64

[list -]
    %include "pem1asm.inc"
[list +]

section .bss
    %include "sectionbss.asm"
    
section .data
    %include "errorlist.asm"
    
    COLONmsg:           db      ": "
    COLONmsg.length:    equ     $-COLONmsg
    CRLFmsg:            db      10
    CRLFmsg.length:     equ     $-CRLFmsg
    
    binary:             db      "TEST BINARY FILE",10
    binary.length:      equ     $-binary
    
    errorline:          db      "at line: "
    .length:            equ     $-errorline
    errorpos:           db      " position: "
    .length:            equ     $-errorpos
        
    ; stat structure
    STAT stat
    TERMIOS termios
        
section .text

global _start
_start:

    pop         rax                 ; argc
    cmp         rax, ARGC
    je          parseCommandLine    ; argumentcount is correct
    jmp         usage
parseCommandLine:    
    pop         rax             ; pointer to programname
    pop         rsi             ; pointer to sourcefilename
    pop         rax             ; read option -o
    pop         rdi                             ; pointer to destination file
    mov         ax, word[rax]
    cmp         ax, "-o"        ; option -o?
    je          checkFiles
    mov         rax, EILEGALOPTION
    call        getError
    call        PrintSTDERR
usage:
    mov         rax, ESHOWUSAGE
    call        getError
    call        PrintSTDERR
    jmp         exit

checkFiles:
    ; RSI has the pointer to the sourcefile
    ; RDI has the pointer to the destinationfile
    
    mov         qword[ptrSourceFile], rsi
    mov         qword[ptrDestinationFile], rdi
    
    ; Open the source file
    mov         rdi, qword [ptrSourceFile]
    mov         rsi, O_RDONLY
    mov         rax, SYS_OPEN
    syscall
    cmp         rax, 0
    jg          gotfdsource                                         ; we got a filedescriptor
    mov         rsi, qword [ptrSourceFile]
    call        PrintFileError
    jmp         exit
gotfdsource:
        ; save the descriptor for later use
    mov         [fdsource], rax
    
    ; try to open the destination file
    mov         rdi, qword[ptrDestinationFile]
    mov         rsi, O_RDWR                                         ; open in read/write mode
    mov         rax, SYS_OPEN
    syscall
    cmp         rax, 0              ; file exists?
    jl          createfile          ; file doesn't exists, create it
    
    mov         qword[fddestination], rax                       ; save fd
    mov         rsi, qword [ptrDestinationFile]
    mov         rax, EFILEEXISTS                
    call        PrintFileError
    
continueWaiting:
    call        WaitForKeyPress
    cmp         al,"Y"
    je          gotAnswer
    cmp         al,"n"
    jne         continueWaiting      
gotAnswer:
    push        rax                                             ; save the answer
    ; print the users answer
    mov         rsi, buffer
    mov         rdx, 1
    call        Print
    mov         rsi, CRLFmsg
    call        Print
    pop         rax                                             ; retrieve the answer
    cmp         al,"Y"
    je          startAssembling

    ; we may not use the existing destination file,
    ; inform user, ask to select other name or quit
    mov         rsi, qword[ptrDestinationFile]
    mov         rax, ENOTUSING
    call        PrintFileError
    jmp         closeDestinationFile

createfile:
    ; file doesn't exists, create the file with permissions 644 octal,
    ; taking umask in consideration
    mov         rdi, qword [ptrDestinationFile]
    mov         rsi, 644q              ; access mode
    mov         rax, SYS_CREAT
    syscall
    ; if we got a file descriptor then the file is created
    cmp         rax, 0
    jge         savefddestination
    ; we got an error creating the file, inform user and close fd source
    mov         rsi, qword [ptrDestinationFile]
    call        PrintFileError
    jmp         closeSourceFile
    
savefddestination:
    mov         qword[fddestination], rax
    
startAssembling:

; read the length of the source file
    mov         rdi, qword[fdsource]
    mov         rsi, stat
    mov         rax, SYS_FSTAT
    syscall
    cmp         rax, 0
    jl          fileStatError
          
readFileSize:
    mov         rcx, qword [stat.st_size]                       ; get the file size
    mov         byte[firstCharInLine], 1                        ; set first char in line true
    mov         byte[ignoreLine], 0                             ; set ignore line false
    mov         qword[charInLine], 0
    mov         qword[sourcelines], 1

; start reading file contents 
readFileContents:
      
  ; int 3  DEBUGGING
    ; FOR ALL bytes IN file DO
      
    push        rcx
    mov         rsi, buffer
    mov         rdx, 1                                          ; read one char at the time
    mov         rax, SYS_READ
    syscall
    cmp         rax, 0
    jle         fileStatError                                   ; in case of an error treat it as a file status error
    
    ; no read error, start parsing
    mov         al, byte[buffer]
    cmp         al, 0x0A
    je          eol
    cmp         al, 0x0D  
    jne         noeol
eol:
    add         qword[sourcelines],1
    mov         byte[ignoreLine], 0                             ; if EOL in remark line set ignore line false

          ; added line to print EOL on STDOUT 26/06/2014
          call        PrintBuffer
         
    mov         qword[charInLine], 0
    jmp         readNextByte
  
noeol:
    inc         qword[charInLine]
    cmp         al, ";"                                         ; if remark, ignore all following chars until 0x0A is met
    jne         nocomment
    mov         byte[ignoreLine], 1                             ; set ignore line true
    jmp         readNextByte
    
nocomment:
    cmp         byte[ignoreLine], 1                             ; if ignore line true then don't parse
    je          readNextByte
    cmp         al, " "                                         ; if a space is met, read the next byte
    je          readNextByte
    cmp         al, 0x09                                        ; if a tab is met, read the next byte
    je          readNextByte
    ;cmp         al, "R"                                         ; R is allowed but not printed, next char must be 0..9 or A..F
    ;je          readNextByte
    cmp         al, "0"                                         ; possible registernumbers, if second and right after R then third must be ':'
    je          writeChar
    cmp         al, "1"                                         ; else memory address, nothing but spaces or '#' allowed
    je          writeChar
    cmp         al, "2"
    je          writeChar
    cmp         al, "3"
    je          writeChar
    cmp         al, "4"
    je          writeChar
    cmp         al, "5"
    je          writeChar
    cmp         al, "6"
    je          writeChar
    cmp         al, "7"
    je          writeChar
    cmp         al, "8"
    je          writeChar
    cmp         al, "9"
    je          writeChar
    cmp         al, "A"
    je          writeChar
    cmp         al, "B"
    je          writeChar
    cmp         al, "C"
    je          writeChar
    cmp         al, "D"
    je          writeChar
    cmp         al, "E"
    je          writeChar
    cmp         al, "F"
    je          writeChar
    cmp         qword[charInLine],1
    je          errorIllegalChar
    cmp         al, "H"
    je          writeChar
    cmp         al, "L"
    je          writeChar
    cmp         al, "O"
    je          writeChar
    cmp         al, "S"
    je          writeChar
    cmp         al, "T"
    je          writeChar
    cmp         al, "U"
    je          writeChar
errorIllegalChar:    
    mov         rax, EILEGALCHAR
    call        getError
    call        PrintSTDOUT
    mov         rsi, errorline
    mov         rdx, errorline.length
    call        PrintSTDOUT
    
    mov         rax, qword[sourcelines]
    call        PrintDecimal
    mov         rsi, errorpos
    mov         rdx, errorpos.length
    call        PrintSTDOUT
    mov         rax, qword[charInLine]
    call        PrintDecimal
    mov         rsi, CRLFmsg
    mov         rdx, CRLFmsg.length
    call        PrintSTDOUT
    jmp         closeDestinationFile  

writeChar:
    call        PrintBuffer
    je          readNextByte
              
readNextByte:     
    pop         rcx
    dec         rcx
    cmp         rcx, 0
    jne         readFileContents  

; END OF ASSEMBLING
endAssembling:
; save the assembled binary
    mov         rdi, qword[fddestination]
    mov         rsi, binary
    mov         rdx, binary.length
    mov         rax, SYS_WRITE
    syscall
    jmp         closeDestinationFile
    
fileStatError:
    mov         rsi, qword[ptrSourceFile]
    call        PrintFileError
    
deleteDestinationFile:  
    mov         rdi, qword[ptrDestinationFile]
    mov         rax, SYS_UNLINK
    syscall
    cmp         rax, 0
    jge         closeDestinationFile
    mov         rsi, qword[ptrDestinationFile]
    call        PrintFileError

closeDestinationFile:
    mov         rdi, qword[fddestination]
    mov         rax, SYS_CLOSE
    syscall
closeSourceFile:        
    mov         rdi, qword[fdsource]
    mov         rax, SYS_CLOSE
    syscall
        
exit:
    ; test n sourcelines read
    mov         rax, qword[sourcelines]
    
    mov         rdi, 0
    mov         rax, SYS_EXIT
    syscall
;*********************************************
; END PROGRAM
;*********************************************

; SUBROUTINES
getError:
    ; RAX has the error number
    neg         rax                             ; get positive value
    dec         rax                             ; decrement to adjust in list
    shl         rax, 3                          ; multiplicate with 8 (8 bytes = 64 bits)
    mov         rsi, [errorList+rax]            ; load the error message pointer
    call        getStringLength
    ret
    
getStringLength:
    ; RSI has the pointer to the string     
    push        rax
    push        rcx
    push        rdi
    mov         rdi, rsi
    mov         rcx, -1                         ; calculate the length
    xor         al, al                          ; search for terminating 0
    repne       scasb
    neg         rcx
    dec         rcx
    mov         rdx, rcx                        ; length in RDX
    pop         rdi
    pop         rcx
    pop         rax
    ret

PrintDecimal:
    ; int 3                       ; DEBUGGING
    push        rsi
    push        rax
    push        rdi
    std
    
    mov         rdi, decbuffer+39               ; end of buffer
.repeat:    
    xor         rdx, rdx
    mov         rbx, 10                         ; base 10
    idiv        rbx                             ; rdx has remainder
    xchg        rax, rdx
    or          al, "0"
    stosb                                       ; save AL
    xchg        rax, rdx
    cmp         rax, 0
    jne         .repeat
    
    inc         rdi
    mov         rsi, rdi
    mov         rdx, rdi
    sub         rdx, decbuffer
    call        PrintSTDOUT
    
    cld
    pop         rdi
    pop         rax
    pop         rsi
    ret

PrintFileError:
    ; RAX has the errornumber
    ; RSI has the pointer to the filename
    push        rsi
    push        rax
    push        rax           
    call        getStringLength
    call        PrintSTDERR
    mov         rsi, COLONmsg
    mov         rdx, COLONmsg.length
    call        PrintSTDERR
    pop         rax
    call        getError
    call        PrintSTDERR
    pop         rax
    pop         rsi
    ret

PrintBuffer:
    push        rcx
    push        rsi
    push        rdx
    mov         rsi, buffer
    mov         rdx, 1
    call        PrintSTDOUT
    pop         rdx
    pop         rsi
    pop         rcx
    ret

PrintSTDERR:
      ; RSI has the pointer to the string
      ; RDX has the length to the string
    push        rdi
    mov         rdi, STDERR
    call        Print
    pop         rdi
    ret
  
PrintSTDOUT:
    push        rdi
    mov         rdi, STDOUT
    call        Print
    pop         rdi
    ret
      
Print:    
    push        rax
    push        rcx
    mov         rax, SYS_WRITE
    syscall
    pop         rcx
    pop         rax
    ret               
    
WaitForKeyPress:
    ; read a key without echoing it back and put the key in a buffer
    ; the buffer is 1 byte long
    call        TermIOS.Canonical.OFF      ; switch canonical mode off
    call        TermIOS.Echo.OFF           ; no echo
    mov         rsi, buffer
    mov         rdx, 1
    mov         rdi, STDIN
    mov         rax, SYS_READ
    syscall
    ; Don't forget to switch canonical mode en echo back on
    call        TermIOS.Canonical.ON       ; switch canonical mode back on
    call        TermIOS.Echo.ON            ; echo on
    mov         al, byte[buffer]
    ret

; **********************************************************************************************    
; TERMIOS functions:
; TermIOS.Canonical.ON        : switch canonical mode on
; TermIOS.Canonical.OFF       : switch canonical mode off
; TermIOS.Echo.ON             : switch echo mode on
; TermIOS.Echo.OFF            : switch echo mode off
; TermIOS.LocalModeFlag.SET   : set the localmode flag described in RAX
; TermIOS.LocalModeFlag.CLEAR : clear the localmode flag described in RAX 
; TermIOS.STDIN.Read          : Read the TERMIO flags
; TermIOS.STDIN.Write         : Write the TERMIO flags
; TermIOS.IOCTL               : Read or write the localmode flags to or from TERMIOS
; **********************************************************************************************

TermIOS.Canonical:
.ON:
    mov         rax, ICANON
    jmp         TermIOS.LocalModeFlag.SET
.OFF:
    mov         rax,ICANON
    jmp         TermIOS.LocalModeFlag.CLEAR
TermIOS.Echo:
.ON:
    mov         rax,ECHO
    jmp         TermIOS.LocalModeFlag.SET
.OFF:
    mov         rax,ECHO
    jmp         TermIOS.LocalModeFlag.CLEAR
TermIOS.LocalModeFlag:
.SET:
    call        TermIOS.STDIN.READ
    or          dword [termios.c_lflag], eax
    call        TermIOS.STDIN.WRITE
    ret
.CLEAR:
    call        TermIOS.STDIN.READ
    not         eax
    and         [termios.c_lflag], eax
    call        TermIOS.STDIN.WRITE
    ret
; subroutine for all TCGETS operation on the syscall IOCTL
; the original value of RCX is restored on exit
TermIOS.STDIN:
.READ:
    mov         rsi, TCGETS
    jmp         TermIOS.IOCTL
; subroutine for all TCSETS operation on the syscall IOCTL
; the original value of RCX is restored on exit
.WRITE:
    mov         rsi, TCSETS
; subroutine for operations on the syscall IOCTL for STDIN
; all registers are restored to their original values on exit of the subroutine
TermIOS.IOCTL:
    push        rax             ; we need to store RAX or TermIOS.LocalFlag functions fail
    mov         rax, SYS_IOCTL
    mov         rdi, STDIN
    mov         rdx, termios
    syscall
    pop         rax
    ret