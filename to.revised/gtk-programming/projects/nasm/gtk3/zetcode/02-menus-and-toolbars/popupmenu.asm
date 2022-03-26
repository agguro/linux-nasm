; Name        : popupmenu.asm
;
; Build       : nasm -felf64 -o popupmenu.o -l popupmenu.lst popupmenu.asm
;               ld -s -m elf_x86_64 popupmenu.o -o popupmenu -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2
;               -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk-3
;
; Description : a popup menu example
;
; C - source  : http://zetcode.com/gui/gtk2/menusandtoolbars/
; Remark      : I've tried to find the g_signal_connect_swapped function but that one doesn't exists in the
;               library.  It's a C function, probably defined in some include file.  To perform this function
;               you have to put 2 in r9d as connect flag.

bits 64

[list -]
    %define   GTK_WINDOW_TOPLEVEL   0
    %define   GTK_WIN_POS_CENTER    1
    %define   FALSE                 0
    %define   TRUE                  1
    %define   GTK_ORIENTATION_HORIZONTAL 1
    %define   GTK_ORIENTATION_VERTICAL   0
    %define   GDK_BUTTON_PRESS           4
    %define   RIGHT_CLICK                3
    ;in file /usr/include/glib-2.0/gobject/gsignal.h
    %define   G_CONNECT_SWAPPED          2
    
    ;the GdkEventButton structure.
    STRUC GDKEVENTBUTTON_STRUC
        .type:          resq    1               ;GdkEventType type;
        .window:        resq    1               ;GdkWindow *window;
        .send_event:    resd    1               ;gint8 send_event;
        .time:          resd    1               ;guint32 time;
        .x:             resq    1               ;gdouble x;
        .y:             resq    1               ;gdouble y;
        .axes:          resq    1               ;gdouble *axes;
        .state:         resd    1               ;guint state;
        .button:        resd    1               ;guint button;
        .device:        resq    1               ;GdkDevice *device;
        .x_root:        resq    1               ;gdouble x_root
        .y_root:        resq    1               ;gdouble y_root
    ENDSTRUC

    extern    exit
    extern    gtk_init
    extern    gtk_window_new
    extern    gtk_window_set_title
    extern    gtk_window_set_default_size
    extern    gtk_window_set_position
    extern    gtk_widget_show
    extern    gtk_widget_show_all
    extern    gtk_main
    extern    gtk_main_quit
    extern    g_signal_connect_data
    extern    gtk_event_box_new
    extern    gtk_container_add
    extern    gtk_menu_bar_new
    extern    gtk_menu_new
    extern    gtk_menu_item_new_with_label
    extern    gtk_menu_item_set_submenu
    extern    gtk_menu_shell_append
    extern    gtk_box_pack_start
    extern   gtk_menu_popup
    extern   gtk_window_iconify
[list +]

section .bss
    
section .data

    window:
    .handle:    dq  0
    .title:     db  "popup menu",0
    eventbox:
    .handle:    dq  0
    menubar:
    .handle:    dq  0
    popupmenu:
    .handle:    dq  0
    popupmenuitem:
    .minimize.handle:   dq  0
    .minimize.text:     db  "Minimize",0
    .quit.handle:       dq  0
    .quit.text:         db  "Quit",0
    signal:
    .destroy:           db  "destroy",0
    .activate:          db  "activate",0
    .buttonpress:       db  "button-press-event",0
    
section .text
    global _start

_start:
    ;init gtk
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    ;create a window
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword[window.handle], rax
    ;set window position
    mov     rdi, qword[window.handle]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position
    ;set window size
    mov     rdi, qword[window.handle]
    mov     rsi, 300
    mov     rdx, 200
    call    gtk_window_set_default_size
    ;set window title
    mov     rdi, qword[window.handle]
    mov     rsi, window.title
    call    gtk_window_set_title  
    ;create an event box for the menu
    mov     rdi,GTK_ORIENTATION_HORIZONTAL
    mov     rsi,0
    call    gtk_event_box_new
    mov     qword[eventbox.handle],rax
    ;add box to the window
    mov     rdi, qword[window.handle]
    mov     rsi, qword[eventbox.handle]
    call    gtk_container_add
    ;create a popup menu
    call    gtk_menu_new
    mov     qword[popupmenu.handle], rax
    ;create popupmenuitem Minimize
    mov     rdi, popupmenuitem.minimize.text
    call    gtk_menu_item_new_with_label
    mov     qword[popupmenuitem.minimize.handle], rax
    ;show this popup menu item
    mov     rdi,qword[popupmenuitem.minimize.handle]
    call    gtk_widget_show
    ;append to the popupmenu
    mov     rdi,qword[popupmenu.handle]
    mov     rsi,qword[popupmenuitem.minimize.handle]
    call    gtk_menu_shell_append
    ;create popupmenuitem Quit
    mov     rdi, popupmenuitem.quit.text
    call    gtk_menu_item_new_with_label
    mov     qword[popupmenuitem.quit.handle], rax
    ;show this popup menu item
    mov     rdi,qword[popupmenuitem.quit.handle]
    call    gtk_widget_show
    ;append to the popupmenu
    mov     rdi,qword[popupmenu.handle]
    mov     rsi,qword[popupmenuitem.quit.handle]
    call    gtk_menu_shell_append
    ;signal handler when pressing right mouse button
    ;you must use r9d=2 swapped, so that the handler operates on the data passed in rcx.
    ;this means that in the handler instead rdi contains the eventbox.handle it will contain
    ;the popupmenu.handle.
    ;it's the same as g_signal_connect_swapped which is 
    mov     r9d,G_CONNECT_SWAPPED
    xor     r8d,r8d
    mov     rcx,qword[popupmenu.handle]
    mov     rdx,show_popup
    mov     rsi,signal.buttonpress
    mov     rdi,qword[eventbox.handle]
    call    g_signal_connect_data
    ;signal handler when selecting Minimize
    mov     r9d,G_CONNECT_SWAPPED
    xor     r8d,r8d
    mov     rcx,qword[window.handle]
    mov     rdx,gtk_window_iconify
    mov     rsi,signal.activate
    mov     rdi,qword[popupmenuitem.minimize.handle]
    call    g_signal_connect_data
    ;signal handler for window close menu
    xor     r9d, r9d                                ;combination of GConnectFlags 
    xor     r8d, r8d                                ;a GClosureNotify for data
    xor     rcx, rcx                                ;pointer to the data to pass
    mov     rdx, gtk_main_quit                      ;pointer to the handler
    mov     rsi, signal.destroy                     ;pointer to the signal
    mov     rdi, qword[window.handle]               ;pointer to the widget instance
    call    g_signal_connect_data                   ;the value in RAX is the handler, but we don't store it now
    ;signal handler for Quit popupmenu
    xor     r9d, r9d                                ;combination of GConnectFlags 
    xor     r8d, r8d                                ;a GClosureNotify for data
    xor     rcx, rcx                                ;pointer to the data to pass
    mov     rdx, gtk_main_quit                      ;pointer to the handler
    mov     rsi, signal.activate                    ;pointer to the signal
    mov     rdi, qword[popupmenuitem.quit.handle]   ;pointer to the widget instance
    call    g_signal_connect_data                   ;the value in RAX is the handler, but we don't store it now
    ;show the window
    mov     rdi, qword[window.handle]
    call    gtk_widget_show_all
    ;main window loop
    call    gtk_main
    ;exit
    xor     rdi, rdi
    call    exit

show_popup:
    ;this function is swapped connected which means that not the eventbox.handle but the popupmenu.handle
    ;is passed in rdi
    ;rdi = pointer to widget
    ;rsi = pointer to event
    ;rax returns false or true
    push    rbx
    push    rbp
    mov     rbp,rsp
    mov     rax,qword[rsi+GDKEVENTBUTTON_STRUC.type]
    cmp     rax,GDK_BUTTON_PRESS
    jne     .false
    mov     eax,dword[rsi+GDKEVENTBUTTON_STRUC.button]
    cmp     eax,RIGHT_CLICK
    jne     .false
    mov     ebx,dword[rsi+GDKEVENTBUTTON_STRUC.time]
    push    rbx
    mov     r9d,dword[rsi+GDKEVENTBUTTON_STRUC.button]
    xor     r8d,r8d
    xor     rcx,rcx
    xor     rdx,rdx
    xor     rsi,rsi
    call    gtk_menu_popup
    mov     rax,TRUE
.false:    
    mov     rax,FALSE
.done:    
    mov     rsp,rbp
    pop     rbp
    pop     rbx
    ret