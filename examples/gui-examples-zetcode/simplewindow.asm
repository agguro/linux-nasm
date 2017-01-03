; Name        : simplewindow.asm
;
; Build       : nasm -felf64 -o simplewindow.o -l simplewindow.lst simplewindow.asm
;               ld -s -m elf_x86_64 simplewindow.o -o simplewindow -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3 -lpango-1.0 -latk-1.0 -lgio-2.0
;               -lpangoft2-1.0  -lpangocairo-1.0 -lcairo -lfreetype -lfontconfig  -lgmodule-2.0 -lgthread-2.0 -lrt
;
; Description : a simple window with the basic functionalities and a title
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/firstprograms/

bits 64

[list -]
	 extern     gtk_init
	 extern     gtk_main
	 extern     gtk_main_quit
	 extern     gtk_widget_show
	 extern     gtk_window_new
	 extern     gtk_window_set_title
	 extern     g_signal_connect_data
	 extern     exit
[list +]

section .data
	 window:
	 .handle:      dq	0
	 .title:       db  	"A simple window",0
	 signal:
	 .destroy:     db  	"destroy",0

section .text
    global _start

_start:
	 xor     	rsi, rsi                  	; argv
	 xor     	rdi, rdi                  	; argc
	 call    	gtk_init

	 call    	gtk_window_new				; rdi=0, GTK_WINDOW_TOPLEVEL
	 mov     	qword[window.handle], rax	;

	 mov     	rdi, rax
	 mov     	rsi, window.title
	 call    	gtk_window_set_title

	 xor     	r9d, r9d					; combination of GConnectFlags 
	 xor     	r8d, r8d                		; a GClosureNotify for data
	 xor     	rcx, rcx                		; pointer to the data to pass
	 mov     	rdx, gtk_main_quit        	; pointer to the handler
	 mov     	rsi, signal.destroy         	; pointer to the signal
	 mov     	rdi, qword[window.handle]     ; pointer to the widget instance
	 call    	g_signal_connect_data
    
	 mov		rdi, qword[window.handle]
	 call	gtk_widget_show

	 call    	gtk_main
    
	 xor		rdi, rdi
	 call	    exit
