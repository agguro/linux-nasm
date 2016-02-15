; Name        : gtkseparators
; Build       : see makefile
; Run         : ./gtkseparators
; Description : Gtk widgets examples

; for this program to link you need sudo apt-get install gtk+-3.0-dev
; this will install libgtk3-dev and a lot more development libraries.

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
     extern    gtk_box_new
     extern    gtk_box_pack_start
     extern    gtk_label_new
     extern    gtk_label_set_line_wrap
     extern    gtk_separator_new
[list +]

section .data
     logo:               incbin    "logo.png"
          .size:         equ       $-logo    
     window:
          .title:        db        "GtkSeparators", 0
     signal:
          .destroy:      db        "destroy", 0
     label1:
          .caption:      db        "Zinc is a moderately reactive, blue gray metal that tarnishes in moist air", 10
                         db        "and burns in air with a bright bluish-green flame, giving off fumes of zinc oxide.", 10
                         db        "It reacts with acids, alkalis and other non-metals. If not completely pure, ", 10
                         db        "zinc reacts with dilute acids to release hydrogen.", 0
     label2:
          .caption:      db        "Copper is an essential trace nutrient to all high plants and animals. In animals, ", 10
                         db        "including humans, it is found primarily in the bloodstream, as a co-factor in various ", 10
                         db        "enzymes, and in copper-based pigments. ", 10
                         db        "However, in sufficient amounts, copper can be poisonous and even fatal to organisms.", 0

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

     mov       rdi, r13
     mov       rsi, FALSE
     call      gtk_window_set_resizable
     
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
     
     mov       rdi, GTK_ORIENTATION_VERTICAL
     mov       rsi, 1
     call      gtk_box_new
     mov       r14, rax                                   ; pointer to box
     
     mov       rsi, r14
     mov       rdi, r13
     call      gtk_container_add
     
     ; label1
     mov       rdi, label1.caption
     call      gtk_label_new
     mov       r15, rax
     
     mov       rdi, r15
     mov       rsi, TRUE
     call      gtk_label_set_line_wrap
     
     mov       rdi, r14                                     ; pointer to box
     mov       rsi, r15                                     ; pointer to label1
     mov       rdx, FALSE
     mov       rcx, TRUE
     xor       r8, r8
     call      gtk_box_pack_start
    
     ; the separator
     ; if the box orientation is vertical, set this to horizontal to separate the labels, otherwise set this to vertical
     mov       rdi, GTK_ORIENTATION_HORIZONTAL             
     call      gtk_separator_new
     mov       rsi, rax
     mov       rdi, r14
     mov       rdx, FALSE
     mov       rcx, TRUE
     mov       r8, 10
     call      gtk_box_pack_start
     
     ; label2
     mov       rdi, label2.caption
     call      gtk_label_new
     mov       r15, rax
     
     mov       rdi, r15
     mov       rsi, FALSE
     call      gtk_label_set_line_wrap
     
     mov       rdi, r14                                     ; pointer to box
     mov       rsi, r15                                     ; pointer to label1
     mov       rdx, FALSE
     mov       rcx, TRUE
     xor       r8, r8
     call      gtk_box_pack_start
     
     mov       rdi, r13                                     ; pointer to window instance in RDI
     call      gtk_widget_show_all

     call      gtk_main
Exit:
     xor       rdi, rdi
     call      exit