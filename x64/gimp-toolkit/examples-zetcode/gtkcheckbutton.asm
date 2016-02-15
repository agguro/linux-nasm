; Name        : gtkcheckbutton
; Build       : see makefile
; Run         : ./gtkcheckbutton
; Description : Gtk widgets examples

; for this program to link you need sudo apt-get install gtk+-3.0-dev
; this will install libgtk3-dev and a lot more development libraries.

; C - source : http://zetcode.com/tutorials/gtktutorial/gtkwidgets/

bits 64

[list -]
     
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
     %define   TRUE           1

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
     extern    gtk_check_button_new_with_label
     extern    gtk_toggle_button_set_active
     extern    gtk_widget_set_size_request
     extern    gtk_widget_set_can_focus
     extern    gtk_toggle_button_get_active
[list +]

section .data
     logo:               incbin    "logo.png"
          .size:         equ       $-logo    
     window:
          .title:
               db        "GtkCheckButton"
          .endtitle:     db        0
     signal:
          .destroy:      db        "destroy", 0
          .clicked:      db        "clicked", 0
     checkbutton:
          .caption:      db   "Show title", 0

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

     call      gtk_fixed_new
     mov       r14, rax                                     ; save pointer to frame
     
     mov       rsi, rax                                     ; pointer to frame
     mov       rdi, r13                                     ; pointer to window
     call      gtk_container_add
     
     ; R13 = pointer to window
     ; R14 : pointer to frame     
     ; if R15 is used, save it before calling this routine

     mov       rdi, checkbutton.caption
     call      gtk_check_button_new_with_label;
     mov       r15, rax
     mov       rdi, r15                                     ; pointer to checkbutton
     mov       rsi, TRUE
     call      gtk_toggle_button_set_active
     mov       rdi, r15
     mov       rsi, TRUE
     call      gtk_widget_set_can_focus
     xor       r9, r9                                       ; combination of GConnectFlags
     xor       r8, r8                                       ; a GClosureNotify for data
     mov       rcx, r13                                     ; pointer to window instance in RCX
     mov       rdx, toggle_title                            ; pointer to the handler
     mov       rsi, signal.clicked                          ; pointer to the signal
     mov       rdi, r15                                     ; pointer to checkbutton in RDI
     call      g_signal_connect_data                          ; GtkCheckButton example

     mov       rsi, r15                                     ; pointer to button
     mov       rdi, r14                                     ; pointer to fixed
     mov       rdx, 50                                      ; coordinates on window for fixed widget
     mov       rcx, rdx
     call      gtk_fixed_put

     mov       rdi, r13                                     ; pointer to window instance in RDI
     call      gtk_widget_show_all

     call      gtk_main
Exit:
     xor       rdi, rdi
     call      exit

toggle_title:
     ; RDI = pointer to the calling checkbutton
     ; RSI = pointer to the parent window
     ; events always start with a stackframe
     push      rbp
     mov       rbp, rsp
     ; check if the checkbutton is checked
     mov       r15, rsi                                     ; save pointer to window
     call      gtk_toggle_button_get_active
     mov       rdi, r15
     mov       rsi, window.title
     cmp       eax, TRUE
     je        .set_title
     mov       rsi, window.endtitle
.set_title:
     call      gtk_window_set_title
     leave
     ret