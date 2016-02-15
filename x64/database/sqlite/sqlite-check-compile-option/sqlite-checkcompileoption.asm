; Name:        sqlite-checkcompileoption
; Build:       see makefile
; Run:         ./sqlite-checkcompileoption
; Description: Checks if a compile option was enabled at the library build.
;              Mostly for diagnostic purposes.  As a demonstration I've added a list of known
;              compile options from the website.
; See Also:    http://www.sqlite.org/compile.html
; Note:        For this program to link you need the libsqlite3-dev library.
;              [sudo apt-get install libsqlite3-dev]

BITS 64

[list -]
      extern   printf
      extern   exit
      extern   sqlite3_compileoption_used
[list +]

section .bss
    
section .data

    compileoption: db 'Option %s', 0
    notused:       db ' not', 0
    stringend:     db ' enabled', 10, 0
    website:       db 'A detailed explanation can be found at '
                   db 'http://www.sqlite.org/compile.html', 10, 0
    
    ; these options may be lower cased too, just beware not to add additional spaces before or
    ; after the optionname.
    option1:    db 'DEFAULT_AUTOVACUUM', 0
    option2:    db 'DEFAULT_CACHE_SIZE', 0
    option3:    db 'ENABLE_COLUMN_METADATA', 0
    option4:    db 'ENABLE_FTS3', 0
    option5:    db 'ENABLE_RTREE', 0
    option6:    db 'ENABLE_UNLOCK_NOTIFY', 0
    option7:    db 'OMIT_LOOKASIDE', 0
    option8:    db 'SECURE_DELETE', 0
    option9:    db 'SOUNDEX', 0
    option10:   db 'TEMP_STORE', 0
    option11:   db 'THREADSAFE', 0
    
    optionList: dq option1
                dq option2
                dq option3
                dq option4
                dq option5
                dq option6
                dq option7
                dq option8
                dq option9
                dq option10
                dq option11           
                dq 0
    
section .text
        global _start

_start:
    mov     rbx, optionList
.repeat:    
    mov     rsi, QWORD[rbx]
    and     rsi, rsi                             ; end of options list
    jz      Exit
    mov     rdi, compileoption
    call    Print
    
    mov     rdi, QWORD[rbx]
    call    sqlite3_compileoption_used
    cmp     rax, 1
    je      .printRest
    mov     rdi, notused
    call    Print
.printRest:
    mov     rdi, stringend
    call    Print
    add     rbx, 8
    jmp     .repeat
Exit:
    mov     rdi, website
    call    Print
    call    exit
    
Print:
    xor     rax, rax
    call    printf
    ret