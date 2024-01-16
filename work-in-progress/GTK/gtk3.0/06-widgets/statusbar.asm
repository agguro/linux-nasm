; Name        : statusbar.asm
;
; Build       : nasm -felf64 -o statusbar.o -l statusbar.lst statusbar.asm
;               ld -s -m elf_x86_64 statusbar.o -o statusbar -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
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
     extern    gtk_container_set_border_width
     extern    gtk_box_new
     extern    gtk_box_pack_start
     extern    gtk_button_new_with_label
     extern    gtk_fixed_new
     extern    gtk_fixed_put
     extern    gtk_widget_set_size_request
     extern    gtk_statusbar_new
     extern    gtk_button_get_label
     extern    g_strdup_printf
     extern    gtk_statusbar_get_context_id
     extern    gtk_statusbar_push
[list +]

section .data
     logo:               incbin    "logo.png"
          .size:         equ       $-logo    
     window:
          .title:        db        "Statusbar", 0
     signal:
          .destroy:      db        "destroy", 0
          .clicked:      db        "clicked", 0
     button1:
          .caption:      db        "OK", 0
     button2:
          .caption       db        "APPLY", 0
     statusbar:
          .caption:      db        "Button %s clicked", 0

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
     mov       rsi, 280
     mov       rdx, 150
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
     mov       rdi, GTK_ORIENTATION_VERTICAL
     mov       rsi, 2
     call      gtk_box_new
     mov       r14, rax                                               ; pointer to vbox

     mov       rdi, r13                                               ; pointer to window
     mov       rsi, r14                                               ; pointer to vbox
     call      gtk_container_add

     call      gtk_fixed_new
     mov       r12, rax                                               ; pointer to fixed
     
     mov       rdi, r14                                               ; pointer to vbox
     mov       rsi, r12                                               ; pointer to fixed
     mov       rdx, TRUE
     mov       rcx, TRUE
     mov       r8, 1
     call      gtk_box_pack_start
     
     
     call      gtk_statusbar_new
     mov       r15, rax                                               ; pointer to statusbar
     
     ; if you want the status bar below the fixed widget
     mov       rdi, r14                                               ; pointer to vbox
     mov       rsi, r15                                               ; pointer to statusbar
     mov       rdx, FALSE
     mov       rcx, TRUE
     mov       r8, 1
     call      gtk_box_pack_start
     
     ; from here pointer to vbox isn't needed anymore so we can use r14 again
     ; button1
     mov       rdi, button1.caption
     call      gtk_button_new_with_label
     mov       r14, rax                                               ; pointer to button1
     
     mov       rdi, rax
     mov       rsi, 80
     mov       rdx, 30
     call      gtk_widget_set_size_request

     mov       rdi, r12                                               ; pointer to fixed
     mov       rsi, r14                                               ; pointer to button1
     mov       rdx, 50
     mov       rcx, rdx
     call      gtk_fixed_put

     xor       r9d, r9d                        ; combination of GConnectFlags
     xor       r8d, r8d                        ; a GClosureNotify for data
     mov       rcx, r15                        ; pointer to statusbar
     mov       rdx, button_pressed             ; pointer to the handler
     mov       rsi, signal.clicked             ; pointer to the signal
     mov       rdi, r14                        ; pointer to button1
     call      g_signal_connect_data           ; the value in RAX is the handler, but we don't store it now
     
     ; from here pointer to button1 isn't needed anymore so we can use r14 again
     ; button2
     mov       rdi, button2.caption
     call      gtk_button_new_with_label
     mov       r14, rax                                               ; pointer to button1
     
     mov       rdi, rax
     mov       rsi, 80
     mov       rdx, 30
     call      gtk_widget_set_size_request

     mov       rdi, r12                                               ; pointer to fixed
     mov       rsi, r14                                               ; pointer to button1
     mov       rdx, 150
     mov       rcx, 50
     call      gtk_fixed_put

     xor       r9d, r9d                        ; combination of GConnectFlags
     xor       r8d, r8d                        ; a GClosureNotify for data
     mov       rcx, r15                        ; pointer to statusbar
     mov       rdx, button_pressed             ; pointer to the handler
     mov       rsi, signal.clicked             ; pointer to the signal
     mov       rdi, r14                        ; pointer to button1
     call      g_signal_connect_data           ; the value in RAX is the handler, but we don't store it now
           
     mov       rdi, r13                                     ; pointer to window instance in RDI
     call      gtk_widget_show_all

     call      gtk_main
Exit:
     xor       rdi, rdi
     call      exit
     
button_pressed:
     ; this is an event, so create a stackframe
     ; RDI has the pointer to the calling button
     ; RSI the pointer to the statusbar
int 3     
     push      rbp
     mov       rbp, rsp

;     mov       r15, rdi                                 ;save calling button pointer
;     mov       r14, rsi                                 ;save pointer to statusbar
     
     call      gtk_button_get_label                     ;get pointer to label(text)
     mov       rdi,rax
     call      g_strdup_printf
     mov       rsi,rax
     mov       rdi,statusbar.caption

;     mov       rsi, rax
;     xor       rax, rax
;     mov       r12, rax                                     ; pointer to output string
     
;     mov       rdi, r14                                     ; pointer to statusbar
;     mov       rsi, r12                                     ; pointer to string
;     call      gtk_statusbar_get_context_id
     
;     mov       rdi, r14                                     ; pointer to statusbar
;     mov       rsi, rax                                     ; context id
;     mov       rdx, r12                                     ; pointer to string
;     call      gtk_statusbar_push
     
     mov        rsp,rbp
     pop        rbp
     ret

