%ifndef _SECTION_RODATA_INC_
%define _SECTION_RODATA_INC_

section .rodata

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

%endif ; _SECTION_RODATA_INC_
