; Name:        sqlite-threadsafe
; Build:       see makefile
; Run:         ./sqlite-threadsafe
; Description: Checks if the sqlite library is threadsafe.
;              Diagnostic purposes.
; See Also:    http://www.sqlite.org/c3ref/threadsafe.html
; Note:        For this program to link you need the libsqlite3-dev library.
;              [sudo apt-get install libsqlite3-dev]

bits 64

[list -]
      extern sqlite3_threadsafe
      extern printf
      extern exit
[list +]

section .bss
    
section .data

    message:    db "The library was compiled with THREADSAFE=%d", 10, 0
    website:    db "More info can be found at: "
                db "http://www.sqlite.org/c3ref/threadsafe.html", 10, 0
    unsafe:             db "It is unsafe to use the library in a multithreaded program.", 10, 0
    safe:               db "It is safe to use the library in a multithreaded environment.", 10, 0
    safewithexception:  db "The library can be used in a multithreaded program so long as no "
                        db "two threads attempt to use the same database connection (or any "
                        db "prepared statements derived from that database connection) "
                        db "at the same time.", 10, 0
    unknown:            db "The threadsafe function returned an unsupported value.", 10, 0

    infolist:   dq  unsafe
                dq  safe
                dq  safewithexception
                dq  unknown
                
section .text
        global _start

_start:
    call    sqlite3_threadsafe          ; this functions don't take parameters
    cmp     rax, 2                      ; maximum value RAX can obtain in this version
    jle     .showmessage
    mov     rax, 3
.showmessage:
    mov     rsi, rax                    ; return value in RSI
    mov     rdi, message
    push    rax                         ; save the result
    call    Print
    pop     rax
    xor     rdx, rdx                    ; prepare multiplication
    mov     rbx, 8
    imul    rbx                         ; calculate address
    mov     rdi, QWORD[infolist+rax]
    call    Print
    
Exit:
    mov     rdi, website
    call    Print
    call    exit
    
Print:
    xor     rax, rax
    call    printf
    ret