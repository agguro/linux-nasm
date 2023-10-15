;name        : bottomleft.asm
;
;build       : /usr/bin/nasm -felf64 -Fdwarf -g -o bottomleft.o bottomleft.asm
;              ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -no-pie -melf_x86_64 -g -o bottomleft bottomleft.o -lc -lgtk-x11-2.0 -lgdk-x11-2.0 -lgobject-2.0 -lgdk_pixbuf-2.0 -lglib-2.0
;
;description : layout example
;
;source : http://zetcode.com/tutorials/gtktutorial/gtklayoutmanagement/

bits 64

[list -]
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
     %define   FALSE                 0
     %define   TRUE                  1
	%define   FLOAT1		              0x3F800000     
     
    extern    gtk_alignment_new
	extern    gtk_container_add
	extern    gtk_container_set_border_width
	extern    gtk_init
	extern    gtk_label_new
	extern    gtk_main
	extern    gtk_main_quit
	extern    gtk_widget_show_all
	extern    gtk_window_new
	extern    gtk_window_set_default_size
	extern    gtk_window_set_position
	extern    gtk_window_set_title
	extern	g_signal_connect_data
    extern    exit
[list +]

section .data

     window:
      .handle:     dq  0
      .title:      db  "gtkAlignment",0
    bttnOK:
      .label:      dq  "OK", 0
      .handle:     dq  0
    bttnClose:
      .label:      dq  "Close", 0
      .handle:     dq  0
    signal:
      .destroy:    db  "destroy",0
	label:
		.text:		db	"bottom-left",0
	
	hLabel:        dq  0
    hAlign:        dq  0
    
section .text
    global _start

_start:
    ; init gtk
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    cmp     rax, FALSE			; gtk could not be initialized
    je      Exit
    
    ; create a new window instance
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     QWORD[window.handle], rax
	;set window title
    mov     rdi, QWORD[window.handle]
    mov     rsi, window.title
    call    gtk_window_set_title
	;set default size
    mov     rdi, qword [window.handle]
    mov     rsi, 300
    mov     rdx, 250
    call    gtk_window_set_default_size
   ; set window position
    mov     rdi, QWORD[window.handle]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position
	;set border
    mov     rdi, qword[window.handle]
    mov     rsi, 5
    call    gtk_container_set_border_width
	;new alignment
	pxor	xmm3, xmm3
	pxor	xmm2, xmm2
    mov     r14, FLOAT1
    movq    xmm1, r14
	pxor	xmm0, xmm0
	call	gtk_alignment_new
	mov		[hAlign],rax
	;new label
	mov 	rdi,label.text
	call	gtk_label_new
	mov		[hLabel],rax
	;add	containers to their parents
	mov		rdi,[hAlign]
	mov		rsi,[hLabel]
	call	gtk_container_add
	mov		rdi,[window.handle]
	mov		rsi,[hAlign]
	call	gtk_container_add
	;connect signal
    mov     rdi, QWORD[window.handle]      ; pointer to the widget instance
    mov     rsi, signal.destroy            ; pointer to the signal
    mov     rdx, gtk_main_quit             ; pointer to the handler
    mov     rcx, qword[window.handle]      ; pointer to the data to pass
    xor     r8d, r8d                	   ; a GClosureNotify for data
    xor     r9d, r9d                	   ; combination of GConnectFlags 
    call    g_signal_connect_data          ; the value in RAX is the handler, but we don't store it now
	;show window
    mov     rdi, QWORD[window.handle]
    call    gtk_widget_show_all
	;main window event loop
    call    gtk_main

Exit:    
    xor     rdi, rdi                ; we don't expect much errors now thus errorcode=0
    call    exit
