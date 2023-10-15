; Name        : gtkseparators.asm
;
; Build       : nasm -felf64 -o gtkseparators.o -l gtkseparators.lst gtkseparators.asm
;               ld -s -m elf_x86_64 gtkseparators.o -o gtkseparators -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : Gtk widgets examples
;
; C - source : http://zetcode.com/tutorials/gtktutorial/gtkwidgets/


bits 64

[list -]
     
     %define   GTK_WINDOW_TOPLEVEL           0
     %define   GTK_WIN_POS_CENTER            1
     %define   GTK_JUSTIFY_CENTER            2
     %define   TRUE                          1
     %define   FALSE                         0
     %define   GTK_ORIENTATION_HORIZONTAL    0
     %define   GTK_ORIENTATION_VERTICAL      1
     
     extern    exit
     extern    gtk_init
     extern    gtk_window_new
     extern    gtk_window_set_title
     extern    gtk_window_set_default_size
     extern    gtk_window_set_position
     extern    gtk_window_set_icon
     extern    gtk_widget_show_all
     extern    gtk_main
     extern    gtk_main_quit
     extern    g_signal_connect_data
     extern    gdk_pixbuf_new_from_file
     extern    gdk_pixbuf_loader_new
     extern    gdk_pixbuf_loader_write
     extern    gdk_pixbuf_loader_get_pixbuf
     extern    gtk_container_add    
     extern    gtk_window_set_resizable
     extern    gtk_container_set_border_width
     extern    gtk_vbox_new
     extern    gtk_box_pack_start
     extern    gtk_label_new
     extern    gtk_label_set_line_wrap
     extern    gtk_hseparator_new
[list +]

section .data
	window:			dq		0
	label1:			dq		0
	label2:			dq		0
	hseparator:		dq		0
	vbox:			dq		0
	szTitle:		db		"GtkSeparators",0
	szDestroy:		db		"destroy",0
	szZinc:			incbin	"../zinc.txt"
					db		0
	szCopper:		incbin	"../copper.txt"
					db		0

section .text
     global _start

_start:

     xor       rsi, rsi                  ; argv
     xor       rdi, rdi                  ; argc
     call      gtk_init

     ; the main window
     xor       rdi, rdi                                  ; GTK_WINDOW_TOPLEVEL = 0 in RDI
     call      gtk_window_new
     mov       [window],rax                                  ; pointer to window in R15

     mov       rdi, [window]                                  ; pointer to window in RDI
     mov       rsi, GTK_WIN_POS_CENTER
     call      gtk_window_set_position
     
     mov       rdi,[window]                                 ; pointer to window in RDI
     mov       rsi,szTitle
     call      gtk_window_set_title

     mov       rdi,[window]
     mov       rsi, TRUE;FALSE
     call      gtk_window_set_resizable
     
     mov       rdi,[window]
     mov       rsi, 10
     call      gtk_container_set_border_width
     
     ; label1
     mov       rdi,szZinc
     call      gtk_label_new
     mov       [label1],rax
     
     mov       rdi,[label1]
     mov       rsi,TRUE
     call      gtk_label_set_line_wrap
     
     ; label2
     mov       rdi,szCopper
     call      gtk_label_new
     mov       [label2],rax
     
     mov       rdi,[label2]
     mov       rsi, TRUE
     call      gtk_label_set_line_wrap

     mov       rdi,FALSE
     mov       rsi,10
     call      gtk_vbox_new
     mov       [vbox],rax                                   ; pointer to box

     mov       rsi,[vbox]
     mov       rdi,[window]
     call      gtk_container_add
     
     call      gtk_hseparator_new
     mov	[hseparator],rax
     
     mov       rdi,[vbox]                                     ; pointer to box
     mov       rsi,[label1]                                   ; pointer to label1
     mov       rdx, FALSE
     mov       rcx, TRUE
     xor       r8, r8
     call      gtk_box_pack_start
    
     mov       rdi,[vbox]
     mov       rsi,[hseparator]
     mov       rdx, FALSE
     mov       rcx, TRUE
     mov       r8, 10
     call      gtk_box_pack_start

     mov       rdi,[vbox]                                     ; pointer to box
     mov       rsi,[label2]                                   ; pointer to label2
     mov       rdx, FALSE
     mov       rcx, TRUE
     xor       r8, r8
     call      gtk_box_pack_start

     xor       r9d, r9d                        ; combination of GConnectFlags
     xor       r8d, r8d                        ; a GClosureNotify for data
     mov       rcx, [window]                   ; pointer to window instance in RCX
     mov       rdx, gtk_main_quit              ; pointer to the handler
     mov       rsi, szDestroy		           ; pointer to the signal
     mov       rdi, [window]                   ; pointer to window instance in RDI
     call      g_signal_connect_data           ; the value in RAX is the handler, but we don't store it now

     mov       rdi,[window]                    ; pointer to window instance in RDI
     call      gtk_widget_show_all

     call      gtk_main
Exit:
     xor       rdi, rdi
     call      exit
