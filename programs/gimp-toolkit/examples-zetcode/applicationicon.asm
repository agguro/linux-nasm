; Name        : applicationicon
; Build       : see makefile
; Run         : ./applicationicon
; Description : a simple window with the basic functionalities and a title, centered on screen with application icon

; for this program to link you need sudo apt-get install gtk+-3.0-dev
; this will install libgtk3-dev and a lot more development libraries.

; when copying the linked application to another location you need to copy the image file 'logo.png' with it in the same directory.
; If you want to change the logo.png file with another picture, just overwrite the logo.png file with the new picture.
;
; C - source : http://zetcode.com/tutorials/gtktutorial/firstprograms/

bits 64

[list -]
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
     extern    exit
     extern    printf
     extern    gtk_init
     extern    gtk_window_new
     extern    gtk_window_set_title
     extern    gtk_window_set_default_size
     extern    gtk_window_set_position
     extern    gtk_window_set_icon
     extern    gtk_widget_show
     extern    gtk_main
     extern    gtk_main_quit
     extern    g_signal_connect_data
     extern    gdk_pixbuf_new_from_file
     
[list +]

section .data
     window:
     .handle:       dq   0
     .title:        db   "window with application icon",0
     signal:
     .destroy:      db   "destroy",0
     icon:
     .pixbuffer:    dq   0
     .file:         db   "logo.png",0              ; must reside in the same directory
     .error:        dq   0
     error:
     .nofile:       db   "logo.png not found, using standard icon for application - ERROR:%u",10, 0

section .text
     global _start

_start:
     xor     rsi, rsi                  ; argv
     xor     rdi, rdi                  ; argc
     call    gtk_init
     
     mov     rdi, icon.file
     mov     rsi, icon.error
     call    gdk_pixbuf_new_from_file
     mov     qword [icon.pixbuffer], rax
     mov     rax, qword[icon.error]
     and     rax, rax
     jz      no_icon_file_error
  
     mov       rsi, qword[icon.file]
     mov       rdi, error.nofile
     xor       rax, rax
     call      printf
     
no_icon_file_error:     
     mov     rdi,GTK_WINDOW_TOPLEVEL
     call    gtk_window_new
     mov     qword [window.handle], rax
     
     mov     rdi, qword [window]
     mov     rsi, window.title
     call    gtk_window_set_title

     mov     rdi, qword [window]
     mov     rsi, 230
     mov     rdx, 150
     call    gtk_window_set_default_size
     
     mov     rdi, qword [window]
     mov     rsi, GTK_WIN_POS_CENTER
     call    gtk_window_set_position

     mov     rdi, qword [window]
     mov     rsi, qword [icon.pixbuffer]
     call    gtk_window_set_icon

     xor     r9d, r9d                ; combination of GConnectFlags 
     xor     r8d, r8d                ; a GClosureNotify for data
     xor     rcx, rcx                ; pointer to the data to pass
     mov     rdx, gtk_main_quit      ; pointer to the handler
     mov     rsi, signal.destroy            ; pointer to the signal
     mov     rdi, qword[window]      ; pointer to the widget instance
     call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

     mov     rdi, qword [window]
     call    gtk_widget_show

     call    gtk_main
Exit:
     ; to avoid the error message "(simplewindow:9051): Gtk-CRITICAL **: gtk_main_quit: assertion 'main_loops != NULL' failed"
     xor     rdi, rdi                ; we don't expect much errors now
     call    exit