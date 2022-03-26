; Name        : undoredo.asm
;
; Build       : nasm -felf64 -o undoredo.o -l undoredo.lst undoredo.asm
;               ld -s -m elf_x86_64 undoredo.o -o undoredo -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2
;               -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : a window with a toolbar, undo and redo example
;               the set and unset of the toolbar items is limited to the first and last two counter
;               values.  If we don't have to update something than we don't update anything.  In this
;               example is a bit overkill but when you need to perform long routines to update something
;               it's a speed gain.
;
; C - source : http://zetcode.com/gui/gtk2/menusandtoolbars/


bits 64

[list -]
    %define   GTK_WINDOW_TOPLEVEL        0
    %define   GTK_WIN_POS_CENTER         1
    %define   FALSE                      0
    %define   TRUE                       1
    %define   GTK_TOOLBAR_ICONS          0
    %define   MINCOUNT                   1              ;minimum counter value
    %define   MAXCOUNT                   10             ;maximum counter value
    
    extern    gtk_init
    extern    gtk_window_new
    extern    gtk_window_set_position
    extern    gtk_window_set_default_size
    extern    gtk_window_set_title
    extern    gtk_vbox_new
    extern    gtk_container_add
    extern    gtk_toolbar_new
    extern    gtk_toolbar_set_style
    extern    gtk_container_set_border_width
    extern    gtk_tool_button_new_from_stock
    extern    gtk_toolbar_insert
    extern    exit
    extern    gtk_separator_tool_item_new
    extern    gtk_box_pack_start
    extern    g_signal_connect_data
    extern    gtk_widget_show_all
    extern    gtk_main
    extern    gtk_main_quit
    extern    gtk_widget_set_name
    extern    gtk_widget_get_name
    extern    gtk_widget_set_sensitive
    extern    strcmp
[list +]

section .bss
    
section .data
    window:
    .handle:            dq  0
    .title:             db  "toolbar",0
    box:
    .handle:            dq  0
    toolbar:
    .handle:            dq  0
    toolbar.item.undo:
    .handle:            dq  0
    .image:             db  "gtk-"              ;gtk-undo
    .name:              db  "undo",0
    toolbar.item.redo:
    .handle:            dq  0
    .image:             db  "gtk-"              ;gtk-redo
    .name:              db  "redo",0
    toolbar.item.separator:
    .handle:            dq  0
    toolbar.item.quit:
    .handle:            dq  0
    .image:             db  "gtk-quit",0
    thistoolbaritem:    dq  0
    othertoolbaritem:   dq  0
    item:               dq  0    
    signal:
    .clicked:           db  "clicked", 0
    .destroy:           db  "destroy", 0
    count:              dq  5
    
section .text
    global _start

_start:
    ;init gtk
    xor     rsi,rsi                  ; argv
    xor     rdi,rdi                  ; argc
    call    gtk_init
    ;create new window
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword[window.handle],rax
    ;set position
    mov     rdi,qword[window.handle]
    mov     rsi,GTK_WIN_POS_CENTER
    call    gtk_window_set_position
    ;set size
    mov     rdi,qword [window.handle]
    mov     rsi,250
    mov     rdx,200
    call    gtk_window_set_default_size
    ;set title
    mov     rdi,qword[window.handle]
    mov     rsi,window.title
    call    gtk_window_set_title
    ;create a box horizontal oriented
    mov     rdi,FALSE
    mov     rsi,0
    call    gtk_vbox_new
    mov     qword[box.handle],rax
    ;add box to window
    mov     rdi,qword[window.handle]
    mov     rsi,qword[box.handle]
    call    gtk_container_add
    ;create a toolbar
    call    gtk_toolbar_new
    mov     qword[toolbar.handle],rax
    ;set style of toolbar
    mov     rdi, qword[toolbar.handle]
    mov     rsi, GTK_TOOLBAR_ICONS
    call    gtk_toolbar_set_style
    ;set border of toolbar
    mov     rdi, qword[toolbar.handle]
    mov     rsi, 2
    call    gtk_container_set_border_width
    ;create toolbar item undo as image from gtk
    mov     rdi, toolbar.item.undo.image
    call    gtk_tool_button_new_from_stock
    mov     qword[toolbar.item.undo.handle], rax
    ;set the name of the toolbar item
    mov     rdi, qword[toolbar.item.undo.handle]
    mov     rsi, toolbar.item.undo.name
    call    gtk_widget_set_name
    ;insert toolbar item to toolbar
    mov     rdi, qword[toolbar.handle]
    mov     rsi, qword[toolbar.item.undo.handle]
    mov     rdx, -1
    call    gtk_toolbar_insert
    ;create toolbar item undo as image from gtk
    mov     rdi, toolbar.item.redo.image
    call    gtk_tool_button_new_from_stock
    mov     qword[toolbar.item.redo.handle], rax
    ;set the name of the toolbar item
    mov     rdi, qword[toolbar.item.redo.handle]
    mov     rsi, toolbar.item.redo.name
    call    gtk_widget_set_name
    ;insert toolbar item to toolbar
    mov     rdi, qword[toolbar.handle]
    mov     rsi, qword[toolbar.item.redo.handle]
    mov     rdx, -1
    call    gtk_toolbar_insert
    ;create a separator as toolbar item
    call    gtk_separator_tool_item_new
    mov     qword[toolbar.item.separator.handle], rax
    ;set separator to toolbar
    mov     rdi, qword[toolbar.handle]
    mov     rsi, qword[toolbar.item.separator.handle]
    mov     rdx, -1
    call    gtk_toolbar_insert
    ;create toolbar item quit
    mov     rdi, toolbar.item.quit.image
    call    gtk_tool_button_new_from_stock
    mov     qword[toolbar.item.quit.handle], rax
    ;set toolbar item on toolbar
    mov     rdi, qword[toolbar.handle]
    mov     rsi, qword[toolbar.item.quit.handle]
    mov     rdx, -1
    call    gtk_toolbar_insert
    ;set the toolbar in the box
    mov     rdi, qword[box.handle]
    mov     rsi, qword[toolbar.handle]
    mov     rdx, FALSE
    mov     rcx, FALSE
    mov     r8d, 5
    xor     r9d, r9d
    call    gtk_box_pack_start
    ;unset toolbar item undo, count = MINCOUNT
    mov     rax,qword[count]
    cmp     rax,MINCOUNT
    je      .unsetundo
    cmp     rax,MAXCOUNT
    jne     .skipunset
    mov     rdi,qword[toolbar.item.redo.handle]
    call    unset
    jmp     .skipunset
.unsetundo:    
    mov     rdi,qword[toolbar.item.undo.handle]
    call    unset
.skipunset:    
    ;connect signal clicked for toolbar item redo to event handler proc_undo_redo
    xor     r9d, r9d                                    ;combination of GConnectFlags 
    xor     r8d, r8d                                    ;a GClosureNotify for data
    mov     rcx, qword[toolbar.item.redo.handle]        ;pointer to the data to pass
    mov     rdx, proc_undo_redo
    mov     rsi, signal.clicked                         ;pointer to the signal
    mov     rdi, qword[toolbar.item.undo.handle]
    call    g_signal_connect_data                       ;the value in RAX is the handler, but we don't store it now
    ;connect signal clicked for toolbar item undo to event handler proc_undo_redo
    xor     r9d, r9d                                    ;combination of GConnectFlags 
    xor     r8d, r8d                                    ;a GClosureNotify for data
    mov     rcx, qword[toolbar.item.undo.handle]        ;pointer to the data to pass
    mov     rdx, proc_undo_redo
    mov     rsi, signal.clicked                         ;pointer to the signal
    mov     rdi, qword[toolbar.item.redo.handle]
    call    g_signal_connect_data                       ;the value in RAX is the handler, but we don't store it now
    ;connect signal clicked to gtk_main_quit event handler for toolbar item quit
    xor     r9d, r9d                                    ;combination of GConnectFlags 
    xor     r8d, r8d                                    ;a GClosureNotify for data
    xor     rcx, rcx                                    ;pointer to the data to pass
    mov     rdx, gtk_main_quit                          ;pointer to the handler
    mov     rsi, signal.clicked                         ;pointer to the signal
    mov     rdi, qword[toolbar.item.quit.handle]        ;pointer to the widget instance
    call    g_signal_connect_data                       ;the value in RAX is the handler, but we don't store it now
    ;connect signal destroy to gtk_main_quit event handler for the window
    xor     r9d, r9d                                    ;combination of GConnectFlags 
    xor     r8d, r8d                                    ;a GClosureNotify for data
    xor     rcx, rcx                                    ;pointer to the data to pass
    mov     rdx, gtk_main_quit                          ;pointer to the handler
    mov     rsi, signal.destroy                         ;pointer to the signal
    mov     rdi, qword[window.handle]                   ;pointer to the widget instance
    call    g_signal_connect_data                       ;the value in RAX is the handler, but we don't store it now
    ;show the windom
    mov     rdi, qword[window.handle]
    call    gtk_widget_show_all
    ;enter main loop
    call    gtk_main
    ;exit program
    xor     rdi, rdi
    call    exit
    
proc_undo_redo:
    ;event handler for toolbar items undo and redo
    mov     qword[thistoolbaritem],rdi
    mov     qword[othertoolbaritem],rsi
    call    gtk_widget_get_name
    ;load either 'un' or 're' in al
    ;this is nice because it's distinct and in ascii 'n' is even, while 'e' is uneven
    mov     al,byte[rax]
    ;mask all bits except least significant
    and     al,1
    ;rotate into carryflag
    rcr     al,1
    jnc     .increment              ;redo
    dec     qword[count]            ;undo
    jmp     .updateitems
.increment:
    inc     qword[count]
.updateitems:
    ;check which widget we need to enable or disable
    mov     rax,qword[count]
.@1:
    ;if count == maxcount then unset this toolbar item and set other toolbar item
    ;this occurs with the redo toolbar item
    cmp     rax,MAXCOUNT
    je      .@3
    ;if count == mincount then unset this toolbar item and set other toolbar item
    ;this occurs with the undo toolbar item
    cmp     rax,MINCOUNT
    je      .@3
    ;if count is less than MINCOUNT+2 then we set both toolbar items
    cmp     rax,MINCOUNT+2
    jl      .@2
    ;if count is greater than MAXCOUNT+2 then we set both toolbar items
    cmp     rax,MAXCOUNT-2
    jg      .@2
    ret
.@2:
    ;set both toolbar items
    mov     rdi,qword[thistoolbaritem]
    call    set
    mov     rdi,qword[othertoolbaritem]
    call    set
    ret
.@3:
    ;if count == 0 or count == 5
    ;disable this toolbar item and enable other toolbar item
    mov     rdi,qword[thistoolbaritem]
    call    unset
    mov     rdi,qword[othertoolbaritem]
    call    set
    ret
    
unset:
    ;routine to unset a toolbar item
    mov     esi,FALSE
    jmp     set_sensitive
    ;routine to set a toolbar item
set:
    mov     esi,TRUE
set_sensitive:
    call    gtk_widget_set_sensitive
    ret    
