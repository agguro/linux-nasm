; Name:        sqlite-version
; Build:       see makefile
; Run:         ./sqlite-version
; Description: Shows version string and number
; See also:    http://www.sqlite.org/c3ref/libversion.html
; Note:        For this program to link you need the libsqlite3-dev library.
;              [sudo apt-get install libsqlite3-dev]

BITS 64

[list -]
      extern sqlite3_libversion
      extern sqlite3_libversion_number
      extern printf
      extern exit
[list +]

section .bss
    
section .data
    versionformat   db "SQLITE version: %s", 10, 0
    version         db "SQLITE version number: %d", 10, 0
    
section .text
        global _start

_start:
    
    call    sqlite3_libversion
    mov     rsi, rax
    mov     rdi, versionformat
    xor     rax, rax
    call    printf
    
    call    sqlite3_libversion_number
    mov     rsi, rax
    mov     rdi, version
    xor     rax, rax
    call    printf
    
    call    exit
