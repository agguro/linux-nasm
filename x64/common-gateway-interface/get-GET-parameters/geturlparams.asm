; Name:        geturlparams
; Build:       see makefile
; Description: Get the URL parameters and displays them in a HTML table.
; Remark:      For those who like to observe the network traffic, you can use:
;              sudo tcpdump -i lo -s0 -w capture.pcap to capture network traffic to a file
;              which you can open with wireshark.
; To test this application on the commandline you can export the QUERY_STRING with his value.
; example in a terminal : export QUERY_STRING='=fname=firstname&lname=lastname&age=99'

bits 64

[list -]
    %include "unistd.inc"
[list +]

section .bss   
section .data

top: db 'Content-type: text/html', 0x0A, 0x0A
     db '<!DOCTYPE html><html><head><title>CGI : Get URL parameters</title></head>'
     db '<body><pre><h1>Get URL parameters</h1>'
top.length: equ $-top

tabletop:     
     db '<table align="left" width="25',0x25,'" border="0" cellpadding="0" cellspacing="0" class="params">'
     db '<tr><td><b><u>name</u></b></td><td><b><u>value</u></b></td></tr><tr><td class="name">'
tabletop.length: equ $-tabletop

newcolumn:
     db '</td><td class="value">'
newcolumn.length: equ $-newcolumn

middle:    
     db '</td></tr><tr><td class="name">'
middle.length: equ $-middle

noparameters:
     db '<b>no url parameters</b>'
noparameters.length: equ $-noparameters

tablebottom:
     db '</td></tr></table>'
tablebottom.length: equ $-tablebottom

bottom:     
     db '</pre></body></html>'
bottom.length: equ $-bottom

htmlbr:
     db '<br />'
htmlbr.length: equ $-htmlbr    

buffer:
     db 0
buffer.length: equ $-buffer

requiredVar:
     db 'QUERY_STRING'
requiredVar.length: equ $-requiredVar

section .text
     global _start
        
_start:
     ; write the first part of the webpage
     mov       rsi, top
     mov       rdx, top.length
     call      .write
     
     ; adjust the stack to point to the web servers variables
     pop       rax
     pop       rax
     pop       rax
     cld
     ; let's loop through the webserver variables
.getvariable:
     pop       rsi
     or        rsi, rsi                            ; done yet?
     je        .done    
     ; RSI contains a pointer to a variable string
     ; look for the required variable name amongst them
     mov       rcx, requiredVar.length
     mov       rdi, requiredVar
     rep       cmpsb                               ; compare RCX bytes
     jne       .getvariable                        ; no match get the next variable, if any
     ; we found the variable   
     ; determine the length of the parameterstring,
     ; RSI points to the '=' character, therefore we adjust the counter RCX at the end
     xor       rcx, rcx
     mov       rbx, rsi
.nextparamstringchar:    
     lodsb
     cmp       al, 0
     je        .endofparamstring
     inc       rcx
     jmp       .nextparamstringchar
.endofparamstring:
     ; we reached the end of the parameterstring, restore RSI. if length = 0 then there aren't
     ; parameters and we show that instead of the parameters.
     dec       rcx                                 ; length = RCX - 1 for '='
     cmp       rcx, 0
     je        .noparameters        
     push      rcx
     push      rbx
     ; print top of table
     
     mov       rsi, tabletop
     mov       rdx, tabletop.length
     call      .write
     
     pop       rbx
     pop       rcx
     ; parse the parameterstring
     mov       rsi, rbx                            ; RSI points to the first '='
     inc       rsi
.getparamchar:    
     xor       rax, rax
     lodsb                                       ; read byte
     cmp       al, 0                               ; if zero then string end
     je        .tablebottom
     push      rsi                                 ; save rsi (1)
     cmp       al, '='                             ; start with value
     je        .newcolumn
     cmp       al, '&'                             ; new parameter
     je        .newrow      
     mov       BYTE[buffer], al
     
     mov       rsi, buffer
     mov       rdx, buffer.length
     jmp       .getnextparam
     
.newcolumn:
     mov       rsi, newcolumn
     mov       rdx, newcolumn.length
     jmp       .getnextparam
        
.newrow:
     mov       rsi, middle
     mov       rdx, middle.length
        
.getnextparam:        
     call      .write
     pop       rsi                                     ; restore rsi (1)
     jmp       .getparamchar
        
.tablebottom:       
     mov       rsi, tablebottom
     mov       rdx, tablebottom.length
     call      .write
     jmp       .done   
.noparameters:
     mov       rsi, noparameters
     mov       rdx, noparameters.length
     call      .write
.done:    
     ; we are at the end of our search, print the rest of the HTML form
     ; write the second part of the webpage
     mov       rsi, bottom
     mov       rdx, bottom.length
     call      .write

     mov       rdi, 0
     mov       rax, SYS_EXIT
     syscall

.write:
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     ret