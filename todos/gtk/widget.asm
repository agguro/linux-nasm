; Name			: simple.asm

bits 64

[list -]
	%define GTK_WINDOW_TOPLEVEL   0
	%define GTK_WIN_POS_CENTER    1
	extern  gtk_widget_show
	extern  gtk_window_new
	extern  gtk_window_set_title
	extern  g_signal_connect_data
	extern  gtk_window_set_decorated
	
[list +]

%include "unistd.inc"
%include "../gtkapp.class"

section .data
	GTKAPP	app
	init_failed_msg:	db		"app not initialized.",10
		.len:			equ		$-init_failed_msg
	init_success_msg:	db		"app initialized.",10
		.len:			equ		$-init_success_msg
	
	window:
	.handle:      dq    0
	.title:       db    0,"A simple window",0
	signal:
	.destroy:     db    "destroy",0
    
section .text
global _start

_start:
	;not really needed but as a demonstration
	mov	rdi,OnInitFailFunc
	app.onInitFail
	mov	rdi,OnInitSuccessFunc
	app.onInitSuccess

	app.Init		
	app.Run
.exit:
	mov		rdi,rax
	app.Exit
	
OnInitFailFunc:
	syscall 	write,stderr,init_failed_msg,init_failed_msg.len
	ret
OnInitSuccessFunc:
	syscall 	write,stderr,init_success_msg,init_success_msg.len
	call	mainwindow
	ret
	
mainwindow:
	push 	rbp
	mov 	rbp,rsp
	mov     rdi,GTK_WINDOW_TOPLEVEL
	call    gtk_window_new
	mov     qword[window.handle],rax
	;set the title
	;mov     rdi,rax
	;mov     rsi,window.title
	;call    gtk_window_set_title
	;connect the destroy signal to gtk_main_quit event handler
	xor     r9d,r9d                    ; combination of GConnectFlags 
	xor     r8d,r8d                    ; a GClosureNotify for data
	xor     rcx,rcx                    ; pointer to the data to pass
	mov     rdx,gtk_main_quit          ; pointer to the handler
	mov     rsi,signal.destroy         ; pointer to the signal
	mov     rdi,qword[window.handle]   ; pointer to the widget instance
	call    g_signal_connect_data
	;show the window
	mov     rdi,qword[window.handle]
	mov		rsi,0
	call    gtk_window_set_decorated
	
	mov     rdi,qword[window.handle]
	call    gtk_widget_show


	mov		rsp,rbp
	pop 	rbp
	ret
