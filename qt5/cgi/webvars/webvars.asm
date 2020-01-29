;;;;;;; webvars.asm ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Copyright (c) 2000 G. Adam Stanislav
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
;
; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS “AS IS” AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
; OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
; SUCH DAMAGE.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Version 1.0
;
; Started:  8-Dec-2000
; Updated:  8-Dec-2000
; Updated: 22-March-2013 to 64 bits by Agguro
;
; Build:
; nasm -felf64 -o webvars.o webvars.asm
; ld webvars.o -o webvars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BITS 64

%define SYS_EXIT    60
%define SYS_WRITE   1
%define SYS_READ    0
%define STDOUT      1
%define STDIN       0

%MACRO sys.read 0
    mov rax, SYS_READ
    syscall
%ENDMACRO

%MACRO sys.write 0
    mov rax, SYS_WRITE
    syscall
%ENDMACRO

%MACRO sys.exit 0
    mov rax, SYS_EXIT
    syscall
%ENDMACRO
 
%macro STRING 1
    db %1
%endmacro

section .bss

section .data

http:
    STRING {'Content-type: text/html',0x0A,0x0A}
    STRING {'<?xml version="1.0" encoding="UTF-8" />',0x0A}
    STRING {"<!DOCTYPE html public '-//W3C/DTD XHTML Strict//EN' 'DTD/xhtml1-strict.dtd' />",0x0A}
    STRING {'<html xmlns="http://www.w3.org/1999/xhtml" xml.lang="en" lang="en">',0x0A}
    STRING {'<head>',0x0A}
    STRING {'<title>Web Environment</title>'}
    STRING {'<meta name="author" content="G. Adam Stanislav" />',0x0A}
    STRING {'<link type="text/css" href="/css/template.css" rel="stylesheet" />'}
    STRING {'</head>',0x0A}
    STRING {'<body>',0x0A}
    STRING {'<div class="webvars">',0x0A}
    STRING {'<h1>Web Environment</h1>',0x0A}
    STRING {'<p>The following <b>environment variables</b> are defined on this web server:</p>',0x0A}
    STRING {'<table align="center" width="100',0x25,'" border="0" cellpadding="5" cellspacing="0" class="webvars">',0x0A}
httplen:    equ $-http

left:
    STRING {'<tr>',0x0A,'<td class="name"><tt>'}
leftlen:    equ $-left

middle:
    STRING {'</tt></td>',0x0A,'<td class="value"><tt><b>'}
midlen:     equ $-middle

undef:
    STRING {'<i>(undefined)</i>'}
undeflen:   equ $-undef

right:
    STRING {'</b></tt></td>',0x0A,'</tr>',0x0A}
rightlen:   equ $-right

wrap:
    STRING {'</table>',0x0A,'</div>',0x0A,'</body>',0x0A,'</html>',0x0A,0x0A}
wraplen:    equ $-wrap
  
section .text
        global _start
        
_start:
    
     ; first, send out all the http and xhtml stuff that is
     ; needed before we start showing the environment
     mov       rsi, http
     mov       rdx, httplen
     mov       rdi, STDOUT
     sys.write
     
     ; now find how far on the stack the environment pointers are.
     ; we need to remove the following from the stack:
     ;   8 bytes of argc
     ;   RAX * 8 bytes of argv
     ;   8 bytes of the NULL after argv
     ;
     ; Total 16 + RAX * 8
     ;
     ; Because the stack grows down, we need to ADD that many bytes
     ; to RSP
     pop       rax
     pop       rax
     pop       rax
     cld                             ; this should already be the case, but let's be sure
     
     ; loop through the environment, printing it out
.loop:
     pop       rdi
     or        rdi, rdi                ; done yet?
     je        .wrap
     
     ; print the left part of HTML
     push      rdi
     push      rcx
     mov       rsi, left
     mov       rdx, leftlen
     mov       rdi, STDOUT
     sys.write
     pop       rcx
     pop       rdi
     
     ; It may be tempting to search for the '=' in the env string next.
     ; But it is possible there is no '=', so we search for the terminating
     ; NUL first
     
     mov       rsi, rdi                ; save start of string
     sub       rcx, rcx
     not       rcx                     ; RCX = FFFFFFFFFFFFFFFF
     sub       rax, rax
     repne     scasb
     not       rcx                     ; RCX = string length + 1
     mov       rbx, rcx                ; save it in RBX
     
     ; now it's time to find '='
     mov       rdi, rsi                ; start of string
     mov       al, '='
     repne     scasb
     not       rcx
     add       rcx, rbx                ; length of name
     
     push      rdi
     push      rcx
     mov       rdx, rcx                ; length of name
     mov       rdi, STDOUT
     sys.write
     
     ; print the middle part of HTML table code
     mov       rsi, middle
     mov       rdx, midlen
     mov       rdi, STDOUT
     sys.write
     pop       rcx
     pop       rdi
     
     ; find the length of the value
     not       rcx
     lea       rbx, [rbx+rcx-1]
     
     ; print "undefined" if 0
     or        rbx, rbx
     jne       .value

     mov       rsi, undef
     mov       rdx, undeflen
     jmp       .write

.value:
     mov       rdx, rbx
     mov       rsi, rdi
.write:    
     mov       rdi, STDOUT
     sys.write

     ; print the right part of the table row
     mov       rsi, right
     mov       rdx, rightlen
     mov       rdi, STDOUT
     sys.write

     jmp       .loop

.wrap:
     ; print the rest of HTML
     mov       rsi, wrap
     mov       rdx, wraplen
     mov       rdi, STDOUT
     sys.write

     ; return success
     xor       rdi, rdi
     sys.exit