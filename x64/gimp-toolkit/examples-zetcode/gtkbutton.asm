; Name        : gtkbutton
; Build       : see makefile
; Run         : ./gtkbutton
; Description : Gtk widgets examples

; for this program to link you need sudo apt-get install gtk+-3.0-dev
; this will install libgtk3-dev and a lot more development libraries.

; C - source : http://zetcode.com/tutorials/gtktutorial/gtkwidgets/


bits 64

[list -]
     
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
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
     extern    gtk_button_new_with_label
     extern    gtk_widget_set_size_request

[list +]

section .data
     logo:               incbin    "logo.png"
          .size:         equ       $-logo    
     window:
          .title:        db        "GtkButton", 0
     signal:
          .destroy:      db        "destroy", 0
          .clicked:      db        "clicked", 0
    button:
          .caption:      db        "Quit", 0

     section .text

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

     ; R13 has the pointer to window, this must remain unchanged
     ; R14 has the pointer to the frame
     ; if R15 is used, save it before calling this routine

     mov       rdi, button.caption
     call      gtk_button_new_with_label
     mov       r15, rax                                     ; pointer to button
     mov       rdi, rax                                     ; pointer to button
     mov       rsi, 80
     mov       rdx, 35
     call      gtk_widget_set_size_request
     xor       r9, r9                                       ; combination of GConnectFlags
     xor       r8, r8                                       ; a GClosureNotify for data
     mov       rcx, r13                                     ; pointer to window instance in RCX
     mov       rdx, gtk_main_quit                           ; pointer to the handler
     mov       rsi, signal.clicked                          ; pointer to the signal
     mov       rdi, r15                                     ; pointer to button in RDI
     call      g_signal_connect_data                        ; the value in RAX is the handler, but we don't store it now

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