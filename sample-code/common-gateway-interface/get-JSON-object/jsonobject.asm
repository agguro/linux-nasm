; Name:        jsonobject
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
 
section .data
 
     ; this works fine enough although other sources mention
     ; 'Content-type: text/json' and
     ; 'Content-Type: application/javascript' and
     ; 'Content-type: application/json'
JsonObject:
          db   'Content-type: text/html', 0x0A, 0x0A
          db   '{ "name": "agguro", "website": "http://www.agguro.be", "email": "emailaddress", "avalue": 7 }'
.length:  equ  $-JsonObject
 
section .text
     global _start
 
_start:
 
     ; send the JSON object to the client
     mov       rdi, STDOUT
     mov       rsi, JsonObject
     mov       rdx, JsonObject.length
     mov       rax, SYS_WRITE
     syscall
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall