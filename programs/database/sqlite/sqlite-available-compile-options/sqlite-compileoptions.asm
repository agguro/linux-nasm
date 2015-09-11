; Name:        sqlite-compileoptions
; Build:       see makefile
; Run:         ./sqlite-compileoptions
; Description: Shows the compile options available. Mostly for diagnostic purposes.
; See Also:    http://www.sqlite.org/compile.html
; Note:        For this program to link you need the libsqlite3-dev library.
;              [sudo apt-get install libsqlite3-dev]

bits 64

[list -]
      extern   printf
      extern   exit
      extern   sqlite3_compileoption_get
[list +]

section .bss
    
section .data
    compileoptions  db 'The library was compiled with the following C-preprocessor '
                    db 'symbols:', 10
                    db 'A detailed explanation can be found at '
                    db 'http://www.sqlite.org/compile.html', 10, 0
    versionformat   db  '%s', 10, 0
    
section .text
        global _start

_start:
    
    mov     rdi, compileoptions
    call    Print
    
    xor     rdi, rdi                    ; start at 0
.repeat:    
    push    rdi                         
    call    sqlite3_compileoption_get
    and     rax, rax                    ; if at end of option list end program
    jz      Exit
    mov     rsi, rax
    mov     rdi, versionformat
    call    Print
    pop     rdi
    inc     rdi
    jmp     .repeat
Exit:       
    call    exit
    
Print:
    xor     rax, rax
    call    printf
    ret