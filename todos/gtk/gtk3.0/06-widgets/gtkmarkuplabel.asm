; Name        : gtkmarkuplabel.asm
;
; Build       : nasm -felf64 -o gtkmarkuplabel.o -l gtkmarkuplabel.lst gtkmarkuplabel.asm
;               ld -s -m elf_x86_64 gtkmarkuplabel.o -o gtkmarkuplabel -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : Gtk widgets examples
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtkwidgets/


bits 64

[list -]
     
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
     %define   GTK_JUSTIFY_CENTER    2

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
     extern    gtk_fixed_new
     extern    gtk_fixed_put
     extern    gtk_label_new
     extern    gtk_label_set_markup
     extern    gtk_label_set_justify
[list +]

section .data
     logo:               incbin    "logo.png"
          .size:         equ       $-logo    
     window:
          .title:        db        "GtkMarkupLabel", 0
     signal:
          .destroy:      db        "destroy", 0

     caption:  db   "Cold was my soul", 10, "Untold was the pain", 10 , "I faced when you left me", 10, "A rose in the rain....", 10
               db   "So I swore to the razor", 10, "That never, enchained", 10, "Would your dark nails of faith", 10, "<i>Be pushed through my veins again</i>", 10, 10
               db   "Bared on your tomb", 10, "<b>I&#39;m a prayer for your loneliness</b>", 10, "And would you ever soon", 10, "Come above onto me?", 10, "<u>For once upon a time</u>", 10
               db   "On the binds of your lowliness", 10, "<b><i><u>I could always find the slot for your sacred key</u></i></b>", 0

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
     mov       rsi, 500
     mov       rdx, 300
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

     mov       rdi, 0
     call      gtk_label_new
     mov       r14, rax
     mov       rdi, r14
     mov       rsi, caption
     call      gtk_label_set_markup
     mov       rdi, r14
     mov       rsi, GTK_JUSTIFY_CENTER
     call      gtk_label_set_justify
     mov       rdi, r13
     mov       rsi, r14
     call      gtk_container_add
  

     mov       rdi, r13                                     ; pointer to window instance in RDI
     call      gtk_widget_show_all

     call      gtk_main
Exit:
     xor       rdi, rdi
     call      exit
