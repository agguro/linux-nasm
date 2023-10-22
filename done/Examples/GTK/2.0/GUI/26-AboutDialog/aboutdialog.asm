; Name        : aboutdialog.asm
;
; Build       : nasm -felf64 -o aboutdialog.o -l aboutdialog.lst aboutdialog.asm
;               ld -s -m elf_x86_64 aboutdialog.o -o aboutdialog -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 `pkg-config --libs gtk+-2.0`
;
; Description : a dialogbox, rightclick on the window to show the aboutdialog
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtkdialogs/

bits      64
align     16

[list -]
     %define   GTK_WINDOW_TOPLEVEL      0
     %define   GTK_WIN_POS_CENTER       1
     %define   TRUE                     1
     %define   FALSE                    0
     %define   GTK_TOOLBAR_ICONS        0
     %define   GTK_JUSTIFY_CENTER       2
     %define   GTK_RESPONSE_OK         -5
     %define   GTK_STATE_NORMAL         0
     %define	GDK_BUTTON_PRESS_MASK	256
     extern    gtk_init
     extern    gtk_window_new
     extern    gtk_window_set_position
     extern    gtk_window_set_default_size     
     extern    gtk_window_set_title
     extern    gtk_window_set_modal
     extern    gtk_window_set_transient_for
     extern    gtk_vbox_new
     extern    gtk_container_add
     extern    gtk_toolbar_new
     extern    gtk_toolbar_set_style
     extern    gtk_container_set_border_width
     extern    gtk_tool_button_new_from_stock
     extern    gtk_toolbar_insert
     extern    gtk_box_pack_start
     extern    gtk_label_new
     extern    gtk_label_set_justify
     extern    g_signal_connect_data
     extern    gtk_main_quit
     extern    gtk_widget_show_all
     extern    gtk_main
     extern    exit
     extern    gtk_color_selection_dialog_new
     extern    gtk_dialog_run
     extern    gtk_color_selection_dialog_get_color_selection
     extern    gtk_color_selection_get_current_color
     extern    gtk_widget_modify_fg
     extern    gtk_widget_destroy
     extern	gtk_widget_add_events
     extern	gdk_pixbuf_new_from_file
     extern	gtk_about_dialog_new
     extern gtk_about_dialog_set_comments
     extern gtk_about_dialog_set_copyright
     extern	gtk_about_dialog_set_logo
     extern	gtk_about_dialog_set_name
     extern	gtk_about_dialog_set_version
     extern	gtk_about_dialog_set_website
     extern	g_object_unref
     

section	.rodata
	batteryimage:		db	"battery.png",0
	name:				db	"About",0
	version:			db  "Battery 0.9",0
	copyright:			db	"(c) Jan Bodnar",0
	comments:			db	"Battery is a simple tool for battery checking.",0
	website:			db	"http://www.batteryhq.net",0
	title:				db	"Battery",0
	
	signal:
	.buttonpressevent:	db	"button-press-event",0
	.destroy:			db	"destroy",0
	
section .data
	window:		dq	0
	about:		dq	0
	battery:	dq	0
	dialog:		dq	0
	pixbuf:		dq	0
	
section .text
	global _start
	
_start:

	xor		rdi,rdi
	xor		rsi,rsi
	call	gtk_init

	mov		rdi,GTK_WINDOW_TOPLEVEL
	call	gtk_window_new
	mov		[window],rax
	
	mov		rdi,[window]
	mov		rsi,GTK_WIN_POS_CENTER
	call	gtk_window_set_position

	mov		rdi,[window]
	mov		rsi,220
	mov		rdx,150
	call	gtk_window_set_default_size
	
	mov		rdi,[window]
	mov		rsi,title
    call	gtk_window_set_title

    mov		rdi,[window]
    mov		rsi,15
	call	gtk_container_set_border_width
	
	mov		rdi,[window]
	mov		rsi,GDK_BUTTON_PRESS_MASK
	call	gtk_widget_add_events

    xor     r9d, r9d                             ; combination of GConnectFlags 
    xor     r8d, r8d                             ; a GClosureNotify for data
    mov     rcx, [window]             ; pointer to the data to pass
    mov     rdx, show_about                     ; pointer to the handler
    mov     rsi, signal.buttonpressevent         ; pointer to the signal
    mov     rdi, [window]              ; pointer to the widget instance
    call    g_signal_connect_data                ; the value in RAX is the handler, but we don't store it now

    xor     r9d, r9d                             ; combination of GConnectFlags 
    xor     r8d, r8d                             ; a GClosureNotify for data
    mov     rcx, [window]             ; pointer to the data to pass
    mov     rdx, gtk_main_quit                     ; pointer to the handler
    mov     rsi, signal.destroy         ; pointer to the signal
    mov     rdi, [window]              ; pointer to the widget instance
    call    g_signal_connect_data                ; the value in RAX is the handler, but we don't store it now

    mov		rdi,[window]
	call	gtk_widget_show_all

	call	gtk_main

	xor		rdi,rdi
	call 	exit


show_about:
	push	rbp
	mov		rbp,rsp
	;rdi = widget
	;rsi = gpointer data
	mov		rdi,batteryimage
	xor		rsi,rsi
	call	gdk_pixbuf_new_from_file
	mov		[pixbuf],rax

	call	gtk_about_dialog_new
	mov		[dialog],rax

	mov		rdi,[dialog]
	mov		rsi,battery
	call	gtk_about_dialog_set_name
	
	mov		rdi,[dialog]
	mov		rsi,version
	call	gtk_about_dialog_set_version
	
	mov		rdi,[dialog]
	mov		rsi,copyright
	call	gtk_about_dialog_set_copyright

	mov		rdi,[dialog]
	mov		rsi,comments
	call	gtk_about_dialog_set_comments

	mov		rdi,[dialog]
	mov		rsi,website
	call	gtk_about_dialog_set_website
     
	mov		rdi,[dialog]
	mov		rsi,[pixbuf]
	call	gtk_about_dialog_set_logo
  
	mov		rdi,[pixbuf]
	call	g_object_unref
	
;	pixbuf = NULL;
  
	mov		rdi,[dialog]
	call	gtk_dialog_run
  
	mov		rdi,[dialog]
	call	gtk_widget_destroy

	mov		rsp,rbp
	pop		rbp
	ret
