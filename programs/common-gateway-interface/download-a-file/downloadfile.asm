; Name:   downloadfile.asm
; Build:  see makefile
; Description: cgi program to download a file (logo.png in this example).
; If you should see errors instead of a download window check if fastcgi is enabled on your apache server.
; appearantle mod-cgi alone isn't enough to serve this program
; sudo apt-get install libapache2-mod-fastcgi
; sudo a2enmod fastcgi
; sudo service apache2 restart

[list -]
     %include "unistd.inc"
     %include "fileio.inc"
[list +]

bits 64

section .bss
     memalloc:      resq 1    ; pointer to memory break
     fd:            resq 1    ; filedescriptor
      
section .data

     httpheader:         db   'Content-type: application/octet-stream', 10
                         db   'Content-Disposition: attachment; filename="logo.png"', 10, 10
     .length:            equ  $-httpheader
     response:           db   'Content-type: text/html', 10, 10
                         db   '<span>the file was not found</span>', 10
     .length:            equ  $-response
     filename:           db   'downloads/logo.png',0    ; put it wherever you want, just keep track of the right location in your path
     errorfile:          db   '[downloadfile] $[CGIROOT]/downloads/logo.png not found error', 10
     .length:            equ  $-errorfile
     errorNoMemory:      db   '[downloadfile error] out of memory error', 10     ; this message will be written to the Apache error log
     .length:            equ  $-errorNoMemory
     
     STAT stat      ; STAT structure instance for FSTAT syscall in fileio.inc
       
section .text
     global _start
     
_start:
     
     ; open the file and get filedescriptor
     mov       rdi, filename
     mov       rsi, O_RDONLY
     mov       rax, SYS_OPEN
     syscall
     cmp       rax, 0
     jl        error                         ; Error, file doesn't exists
     mov       QWORD[fd], rax                ; save filedescriptor
          
     ; read the filesize
     mov       rdi, QWORD[fd]
     mov       rsi, stat
     mov       rax, SYS_FSTAT
     syscall
          
     ; get memory break
     mov       rdi, 0
     mov       rax, SYS_BRK
     syscall
          
     cmp       rax, 0
     jle       errormemory                   ; no memory available to allocate
          
     mov       QWORD[memalloc], rax          ; save pointer to memory break
     add       rax, QWORD[stat.st_size]      ; add filesize to allocate memory
          
     ; try to allocate additional memory
     mov       rdi, rax
     mov       rax, SYS_BRK
     syscall
     cmp       rax, rdi                      ; new memory break equal to calculated one?
     jne       error                         ; not enough memory available
               
          ; read the file in the allocated memory
     mov       rdi, QWORD[fd]
     mov       rsi, QWORD[memalloc]
     mov       rdx, QWORD[stat.st_size] ; bytes to read
     mov       rax, SYS_READ
     syscall

     ; close the file
     mov       rdi, QWORD[fd]
     mov       rax, SYS_CLOSE
     syscall

     ; write the HTTP header
     mov       rdi, STDOUT
     mov       rsi, httpheader
     mov       rdx, httpheader.length
     mov       rax, SYS_WRITE
     syscall
     ; write the filecontents
     mov       rdi, STDOUT
     mov       rsi, QWORD[memalloc]
     mov       rdx, QWORD[stat.st_size]
     mov       rax, SYS_WRITE
     syscall
          
     ; release allocated memory
     mov       rdi, QWORD[memalloc]
     mov       rax, SYS_BRK
     syscall
exit:
     ; exit the program
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall

errormemory:
     mov       rsi, errorNoMemory
     mov       rdx, errorNoMemory.length
     jmp       error.tologfile
error:
     mov       rsi, response
     mov       rdx, response.length
     mov       rdi, STDOUT                        ; to web client
     mov       rax, SYS_WRITE
     syscall
     mov       rsi, errorfile
     mov       rdx, errorfile.length
.tologfile:     
     mov       rdi, STDERR                        ; to Apache log file
     mov       rax, SYS_WRITE
     syscall
     jmp       exit