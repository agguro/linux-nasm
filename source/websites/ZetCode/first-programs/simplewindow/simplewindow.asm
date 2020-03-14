; Name			: simplewindow.asm
; Description	: a simple window with the basic functionalities and a title
; Source  		: http://zetcode.com/gui/gtk2/firstprograms/

bits 64

[list -]
	%define GTK_WINDOW_TOPLEVEL   0
	%define GTK_WIN_POS_CENTER    1
	extern  gtk_init
	extern  gtk_main
	extern  gtk_main_quit
	extern  gtk_widget_show
	extern  gtk_window_new
	extern  gtk_window_set_title
	extern  g_signal_connect_data
	extern  exit
[list +]

section .data
	window:
	.handle:      dq    0
	.title:       db    0,"A simple window",0
	signal:
	.destroy:     db    "destroy",0
    
section .text
global _start

_start:
    ;init gtk
    ;in this example I don't use of argc or argv.
    ;in case you should use commandline arguments refer to:
    ;https://developer.gnome.org/gtk3/stable/gtk3-General.html#gtk-init_with_args
	xor		rdi,rdi						;pointer to argc = null
	xor		rsi,rsi						;pointer to argv = null
    call    gtk_init
    ;when rax returns 0 then gtk_init fails and we terminate the program.
    and     rax,rax
    jz      .exit
    ;create a new window
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
    call    gtk_widget_show
    ;go into applications main loop
    call    gtk_main
.exit:    
    ;exit program
    xor     rdi,rdi
    call    exit
