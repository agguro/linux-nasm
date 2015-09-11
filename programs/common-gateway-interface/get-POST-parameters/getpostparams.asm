; Name:         getpostparams
; Build:        see makefile
; Description:  Get the post parameters.
; Use:          This program allow us to see the posted parameters from almost any website.
; Disadvantage: Posted files contents can corrupt the output on the webbrowser, a work around wil
;               be made soon and wil show the file contents in hexademal.
; How to test:  in a terminal type export CONTENT_LENGTH=[value for content length]
;               start the application
;               once 'parameters stripped from HTTP header: <i><b>' is on screen you can type your
;               parameter-value pairs like an url string and press enter.
;               You should see those in the output.
;               example: export CONTENT_LENGTH=14
;               as input a=10&b=20&c=30.

bits 64

[list -]
    %include "unistd.inc"
[list +]

section .bss

     oldbrkaddr:         resq  1
     contentlength:      resq  1

     buffer:             resb  1
     buffer.length:      equ   $-buffer

section .data

top:
    db 'Content-type: text/html', 0x0A, 0x0A
    db '<!DOCTYPE html><html><head><title>CGI : Get POST parameters</title></head>'
    db '<body><pre><h1>Get POST parameters</h1><br /><span>',10
requiredVar:    
    db 'CONTENT_LENGTH'
requiredVar.length: equ $-requiredVar    
    db ': <i><b>'
top.length: equ $-top

nrparams:
    db '</b></i> bytes.</span><br /><span>parameters stripped from HTTP header: <i><b>'
nrparams.length: equ $-nrparams

table:
    db '</b></i><br /><br />'
    db '<table align="left" width="25',0x25,'" border="0" cellpadding="0" cellspacing="0" class="params">'
    db '<tr><td><b><u>name</u></b></td><td><b><u>value</u></b></td></tr><tr><td class="name">'
table.length: equ $-table

newcolumn:
    db '</td><td class="value">'
newcolumn.length: equ $-newcolumn

middle:    
    db '</td></tr><tr><td class="name">'
middle.length: equ $-middle

bottom:
    db '</td></tr></table></pre></body></html>'
bottom.length: equ $-bottom

htmlbr:
    db '<br />'
htmlbr.length: equ $-htmlbr    

section .text
     global _start

_start:
     ; write the first part of the webpage
     mov         rsi, top
     mov         rdx, top.length
     mov         rdi, STDOUT
     mov         rax, SYS_WRITE
     syscall
     
     ; adjust the stack to point to the web servers variables
     pop         rax
     pop         rax
     pop         rax
     cld
     ; let's loop through the webserver variables
.getvariable:
     pop         rsi
     or          rsi, rsi                ; done yet?
     jz          .done
     
     ; RDI contains a pointer to CONTENT_LENGTH the variable we are searching for
     ; look for the required variable name amongst them
     mov         rcx, requiredVar.length
     mov         rdi, requiredVar
     rep         cmpsb                   ; compare RCX bytes
     jne         .getvariable            ; no match get the next variable, if any
     
     ; we found the variable, parse the length of the post parameters
     ; RSI points to the = sign, increment RSI to point to the character after '='
     inc         rsi
     
     ; initialise rcx, rcx wil contain the hexadecimal value of CONTENT_LENGTH
     xor       rcx, rcx
.nextparamstringchar:
     xor       rax, rax
     lodsb                               ; get digit
     cmp       al, 0                   ; if 0 then no digits
     je        .endofparamstring
     
     xor       rdx, rdx
     mov       rbx, 10
     imul      rcx, rbx
     mov       BYTE[buffer], al
     and       al, 0x0F
     add       rcx, rax                ; previous digit x 10 + current digit
     
     push      rsi
     mov       rsi, buffer
     mov       rdx, buffer.length
     mov       rdi, STDOUT
     push	     rcx
     mov       rax, SYS_WRITE
     syscall
     pop       rcx
     pop       rsi
     
     jmp       .nextparamstringchar
.endofparamstring:

     inc 	     rcx
     mov		QWORD[contentlength], rcx

     ; end the number of parameters in HTML

     mov       rsi, nrparams
     mov       rdx, nrparams.length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     
     ; RCX contains the content_length in hexadecimal
     ; reserve space on, the heap to store the parameters from STDIN

     mov       rdi, 0
     mov       rax, SYS_BRK
     syscall
     
     mov       QWORD[oldbrkaddr], rax  ; save the address to de-allocate memory

     ; reserve memory for the parameters
     add       rax, QWORD[contentlength]
     
     mov       rdi, rax
     mov       rax, SYS_BRK
     syscall
     
     and       rax, rax
     jz        .done                   ; if RAX = 0 then no memory is available, now we exit

     ; read the params in our created buffer                                
     
     mov       rsi, QWORD[oldbrkaddr]
     mov       rdx, QWORD[contentlength]                ; length of the parameterstring
     mov       rdi, STDIN
     mov       rax, SYS_READ
     syscall
     
     ; print the entire parameterstring
     ; rsi and rdx already contains the string to print and the string length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     
     mov       rsi, table
     mov       rdx, table.length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     
     nop
     ; parse the parameter string
     mov       rsi, QWORD[oldbrkaddr]
.nextbyte:
     xor       rax, rax
     lodsb                               ; read byte
     
     push      rsi                     ; save pointer
     cmp       al, 0
     je        .done                   ; if zero -> end of string
     cmp       al, '='
     je        .newcolumn              ; if '=' -> next byte is parametervalue
     cmp       al, '&'
     je        .newrow                 ; if '&' -> next byte is parametername
     mov       BYTE[buffer], al        ; otherwise print the byte

     ; write the character in the buffer
     mov       rsi, buffer
     mov       rdx, buffer.length
     jmp       .writechar
     
     ; end previous column and start new one
.newcolumn:
     mov       rsi, newcolumn
     mov       rdx, newcolumn.length
     jmp       .writechar
     
     ; end previous row and start new one
.newrow:
     mov       rsi, middle
     mov       rdx, middle.length
     
     ; write to STDOUT
.writechar:    
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     pop       rsi
     jmp       .nextbyte

.done:
     ; free the allocated memory
     mov       rdi, QWORD[oldbrkaddr]
     mov       rax, SYS_BRK
     syscall

     ; we are at the end of our search, print the rest of the HTML form
     
     mov       rsi, bottom
     mov       rdx, bottom.length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall