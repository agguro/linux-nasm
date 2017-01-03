; Name        : gtkentry.asm
;
; Build       : nasm -felf64 -o gtkentry.o -l gtkentry.lst gtkentry.asm
;               ld -s -m elf_x86_64 gtkentry.o -o gtkentry -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3 -lpango-1.0 -latk-1.0 -lgio-2.0
;               -lpangoft2-1.0 -lpangocairo-1.0 -lcairo -lfreetype -lfontconfig -lgmodule-2.0 -lgthread-2.0 -lrt
;
; Description : Gtk widgets examples
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtkwidgets/


bits 64

[list -]
     
     %define   GTK_WINDOW_TOPLEVEL           0
     %define   GTK_WIN_POS_CENTER            1
     %define   GTK_JUSTIFY_CENTER            2
     %define   TRUE                          1
     %define   FALSE                         0
     %define   GTK_FILL                  4
     %define   GTK_EXPAND                1
     %define   GTK_SHRINK                2

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
     extern    gtk_container_set_border_width
     extern    gtk_label_new
     extern    gtk_table_attach
     extern    gtk_table_new
     extern    gtk_entry_new
[list +]

section .data
     logo:               incbin    "logo.png"
          .size:         equ       $-logo    
     window:
          .title:        db        "GtkEntry", 0
     signal:
          .destroy:      db        "destroy", 0
     label:
          .caption:      db        "Name:", 0

section .text
     global _start

_start:

     ; Folowing code generates a window, shows it and can be closed. It has an application icon set
     ; and will be used for all GtkWidget demonstrations
     xor       rsi, rsi                  ; argv
     xor       rdi, rdi                  ; argc
     call      gtk_init

     ; loading the the application icon in a buffer -> pixbuffer

     call      gdk_pixbuf_loader_new
     mov       r13, rax                                  ; pointer to loader in R15

     mov       rdi, r13
     mov       rsi, logo
     mov       edx, logo.size
     xor       rcx, rcx
     call      gdk_pixbuf_loader_write

     mov       rdi, r13
     call      gdk_pixbuf_loader_get_pixbuf
     mov       r14, rax                                  ; pointer to pixbuffer in R14

     ; the main window
     xor       rdi, rdi                                  ; GTK_WINDOW_TOPLEVEL = 0 in RDI
     call      gtk_window_new
     mov       r13, rax                                  ; pointer to window in R15

     mov       rdi, r13                                  ; pointer to window in RDI
     mov       rsi, window.title
     call      gtk_window_set_title

     mov       rdi, r13                                  ; pointer to window in RDI
     mov       rsi, 200
     mov       rdx, 10
     call      gtk_window_set_default_size

     mov       rdi, r13                                  ; pointer to window in RDI
     mov       rsi, GTK_WIN_POS_CENTER
     call      gtk_window_set_position

     mov       rdi, r13                                  ; pointer to window instance in RDI
     mov       rsi, r14                                  ; pointer to pixbuffer instance in RSI
     call      gtk_window_set_icon

     xor       r9d, r9d                        ; combination of GConnectFlags
     xor       r8d, r8d                        ; a GClosureNotify for data
     mov       rcx, r13                        ; pointer to window instance in RCX
     mov       rdx, gtk_main_quit              ; pointer to the handler
     mov       rsi, signal.destroy             ; pointer to the signal
     mov       rdi, r13                        ; pointer to window instance in RDI
     call      g_signal_connect_data           ; the value in RAX is the handler, but we don't store it now

     ; keep in mind R13 is the pointer to the window
     mov       rdi, r13
     mov       rsi, 20
     call      gtk_container_set_border_width
     
     ; the table
     mov       rdi, 1
     mov       rsi, 2
     mov       rdx, FALSE
     call      gtk_table_new
     mov       r14, rax                                     ; pointer to table
     
     mov       rdi, r13                                     ; pointer to window
     mov       rsi, r14                                     ; pointer to table
     call      gtk_container_add

     mov       rdi, label.caption
     call      gtk_label_new
     mov       rsi, rax                                     ; pointer to label
     mov       rdi, r14                                     ; pointer to table
     xor       rdx, rdx
     mov       rcx, 1
     xor       r8, r8
     mov       r9, rcx
     ; last parameter first on stack
     push      5
     push      5
     push      GTK_FILL | GTK_SHRINK
     push      GTK_FILL | GTK_SHRINK
     call      gtk_table_attach
     
     call      gtk_entry_new
     mov       rsi, rax                                     ; pointer to entry
     mov       rdi, r14                                     ; pointer to table
     mov       rdx, 1
     mov       rcx, 2
     xor       r8, r8
     mov       r9, 1
     ; last parameter first on stack
     push      5
     push      5
     push      GTK_FILL | GTK_SHRINK
     push      GTK_FILL | GTK_SHRINK
     call      gtk_table_attach
          
     mov       rdi, r13                                     ; pointer to window instance in RDI
     call      gtk_widget_show_all

     call      gtk_main
Exit:
     xor       rdi, rdi
     call      exit
