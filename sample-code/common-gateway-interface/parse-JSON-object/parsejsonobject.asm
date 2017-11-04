; Name:        parsejsonobject
; Build:       see makefile
; Description: reply data in the form of a JSON object.  After building this application, you need
;              to upload this to your webservers cgi root folder.
; Remark:      For those who like to observe the network traffic, you can use:
;              sudo tcpdump -i lo -s0 -w capture.pcap to capture the network traffic in a file
;              which you can open with wireshark.
 
bits 64

[list -]
     %include "unistd.inc"
[list +]

section .bss

     oldbrkaddr:         resq 1
     charbuffer:         resb 1
     content:            resq 1   ; memory to store content length in
    
section .data

     requestmethod:      db   "REQUEST_METHOD=POST"
     .length:            equ  $-requestmethod
     contentlength:      db   "CONTENT_LENGTH="
     .length:            equ  $-contentlength

top:
          db   'Content-type: text/html', 0x0A, 0x0A,'{"'
.length:  equ  $-top

middle:
          db   '":"'
.length:  equ  $-middle    

separator:
          db   '","'
.length:  equ  $-separator

bottom:
          db   '"}'
.length:  equ  $-bottom

section .text
     global _start

_start:

     ; first check if the form was posted
     ; adjust stack to environment parameters
     pop       rax
     pop       rax
     pop       rax
     mov       rbp, rsp                 ; save begin of list in rbp
     ; let's loop through the webserver variables, searching for REQUEST_METHOD=POST
     cld
.getrequestmethod:
     pop       rsi
     or        rsi, rsi                ; done yet?
     jz        .exit                   ; we didn't find the REQUEST_METHOD=POST string   
     ; RDI contains a pointer to CONTENT_LENGTH=POST the variable we are searching for
     ; look for the required variable name amongst them
     mov       rcx, requestmethod.length
     mov       rdi, requestmethod
     rep       cmpsb                   ; compare RCX bytes
     jne       .getrequestmethod       ; no match get the next variable, if any

     ; we got a match, now read the CONTENT_LENGTH
     ; restore top of (list-1)
     mov       rsp, rbp
     cld                                 ; just in case
.getcontentlength:
     pop       rsi
     or        rsi, rsi                ; done yet
     jz        .exit                   ; this shouldn't occur
     ; RDI contains a pointer to CONTENT_LENGTH= the variable we are searching for
     mov       rcx, contentlength.length
     mov       rdi, contentlength
     rep       cmpsb                   ; compare RCX bytes
     jne       .getcontentlength       ; no match get the next variable, if any

     ; we got the CONTENT_LENGTH=, RSI points to the first character of the ASCII digit of the length
     ; initialise rcx
     xor       rcx, rcx
.nextparamstringchar:
     xor       rax, rax
     lodsb                               ; get digit
     and       al, al                   ; if 0 then no digits
     je        .endofparamstring

     xor       rdx, rdx
     mov       rbx, 10
     imul      rcx, rbx
     and       al, 0x0F
     add       rcx, rax                ; previous digit x 10 + current digit    
     jmp       .nextparamstringchar
.endofparamstring:   
     ; RCX contains the content_length in hexadecimal
     ; reserve space on, the heap to store the parameters from STDIN
     mov       QWORD[content], rcx
     mov       rdi, 0
     mov       rax, SYS_BRK
     syscall
     mov         QWORD[oldbrkaddr], rax  ; save the address to de-allocate memory

     ; reserve memory for the parameters
     add       rax, QWORD[content]            ; add contentlength to the program break
     mov       rdi, rax
     mov       rax, SYS_BRK
     syscall
     cmp       rax, 0
     je        .exit                   ; if RAX = 0 then no memory is available, now we exit

     ; read the params in our created buffer
     mov       rsi, QWORD[oldbrkaddr]
     mov       rdx, QWORD[content]               ; length of the parameterstring
     mov       rdi, STDIN
     mov       rax, SYS_READ
     syscall

     ; start the output of the data as a JSON object
     mov       rdi, STDOUT
     mov       rsi, top
     mov       rdx, top.length
     mov       rax, SYS_WRITE
     syscall

     ; parse the data to a JSON object
     ; loop through the data until '='
     mov         rsi, QWORD[oldbrkaddr]
     cld
.repeat:    
     lodsb
     and       al, al
     jz        .endloop
     cmp       al,"="
     je        .printmiddle
     cmp       al,"&"
     je        .printseparator
     cmp       al,"+"
     jne       .printchar
     ; + will be replaced by space
     mov       al, " "
.printchar:    
     push      rsi                             ; rsi on stack    
     ; print the character
     mov       BYTE[charbuffer], al
     mov       rsi, charbuffer
     mov       rdx, 1
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     pop       rsi
     jmp       .repeat
.printmiddle:
     push      rsi
     mov       rsi, middle
     mov       rdx, middle.length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     pop       rsi
     jmp       .repeat
.printseparator:
     push      rsi
     mov       rsi, separator
     mov       rdx, separator.length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     pop       rsi
     jmp       .repeat
.endloop:       
     mov       rdi, STDOUT
     mov       rsi, bottom
     mov       rdx, bottom.length
     mov       rax, SYS_WRITE
     syscall

     ; release the reserved memory
     ; free the allocated memory
     mov       rdi, QWORD[oldbrkaddr]
     mov       rax, SYS_BRK
     syscall

     ; and exit the program
.exit:
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall    