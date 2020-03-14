%ifndef _SECTION_RODATA_INC_
%define _SECTION_RODATA_INC_

section .rodata
    method_post:	db	"REQUEST_METHOD=POST"
    .length:		equ	$-method_post
    method_get:	db	"REQUEST_METHOD=GET"
    .length:		equ	$-method_get

    content_length:	db	'CONTENT_LENGTH'
    .length:			equ	$-content_length

    start_queue:
        dq  header
        dq  header.length
        dq  startpage
        dq  startpage.length

    postback_queue:
        dq  header
        dq  header.length
        dq  postbackpage
        dq  postbackpage.length


    header:
        INCBIN	"header.txt"
        db	0x0A,0x0A
    .length:	equ	$-header

    startpage:
        INCBIN	"startpage.html"
	.length:	equ	$-startpage
	
    postbackpage:
        INCBIN	"postbackpage.html"
	.length:	equ	$-postbackpage


    top:
	db 'Content-type: text/html', 0x0A, 0x0A
	db '<!DOCTYPE html>'
	db '<html><head><title>CGI : Get POST parameters</title></head>'
	db '<body><pre><h1>Get POST parameters</h1><br /><span>',0x0A
	requiredVar:
	    db 'CONTENT_LENGTH'
	    requiredVar.length: equ $-requiredVar
	db ': <i><b><br />'
	top.length: equ $-top

    nrparams:
	db '</b></i> bytes.</span><br /><span>parameters stripped from HTTP header: <i><b><br />'
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

%endif ; _SECTION_RODATA_INC_
