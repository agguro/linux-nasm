; Name        : undoredo.asm
;
; Build       : nasm -felf64 -o undoredo.o -l undoredo.lst undoredo.asm
;               ld -s -m elf_x86_64 timer.o -o timer -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3 -lpango-1.0 -latk-1.0 -lgio-2.0
;               -lpangoft2-1.0  -lpangocairo-1.0 -lcairo -lfreetype -lfontconfig  -lgmodule-2.0 -lgthread-2.0 -lrt
;
; Description : a window with a toolbar, undo and redo example
;
; C - source : http://zetcode.com/tutorials/gtktutorial/menusandtoolbars/


bits 64

[list -]
     ; you can search following values with:
     ; grep "[search string" /usr/include/gtk-3.0/gdk/*.h   for GDK_
     ; or grep "search string" /usr/include/gtk-3.0/gtk/*.h for GTK_
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
     %define   FALSE                 0
     %define   TRUE                  1
     %define   GTK_TOOLBAR_ICONS     0
     
     extern    gtk_init
     extern    gtk_window_new
     extern    gtk_window_set_position
     extern    gtk_window_set_default_size
     extern    gtk_window_set_title
     extern    gdk_pixbuf_new_from_file
     extern    gtk_window_set_icon
     extern    gtk_box_new
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
    window:          resq    1   ; pointer to the GtkWidget, in this case the window
    pixbuffer:       resq    1       ; pointer to pixel buffer for icon
    error:           resq    1
    box:             resq    1
    toolbar:         resq    1
    undo:            resq    1
    redo:            resq    1
    sep:             resq    1
    quit:            resq    1
    
    widget:          resq    1
    item:            resq    1
    
section .data
    mainwindow:
    .title:      db  "toolbar",0
      
    icon:        db  "icon",0
    .file:       db  "logo.png",0              ; must reside in the same directory
    toolbaritem:
    .undo:	 db  "gtk-"
    .undoname:   db  "undo", 0
    .redo:       db  "gtk-"
    .redoname:   db  "redo", 0
    .quit:       db  "gtk-quit", 0
    signal:
    .clicked:	 db  "clicked", 0
    .destroy:    db  "destroy", 0
    count:	 dd  2
    
section .text
    global _start

_start:
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     QWORD[window], rax

    mov     rdi, QWORD[window]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    mov     rdi, qword [window]
    mov     rsi, 250
    mov     rdx, 200
    call    gtk_window_set_default_size

    ; gtk_window_set_title
    mov     rdi, QWORD[window]
    mov     rsi, mainwindow.title
    call    gtk_window_set_title

    mov     rdi, icon.file
    mov     rsi, error
    call    gdk_pixbuf_new_from_file
    mov     qword [pixbuffer], rax

    mov     rdi, qword [window]
    mov     rsi, qword [pixbuffer]
    call    gtk_window_set_icon
    
    mov     rdi, TRUE					; for vertical menus use FALSE
    mov     rsi, 0
    call    gtk_box_new					; don't use gtk_vbox_new <- deprecated
    mov     qword[box], rax
    
    mov     rdi, qword[window]
    mov     rsi, qword[box]
    call    gtk_container_add
    
    call    gtk_toolbar_new
    mov     qword[toolbar], rax
    
    mov     rdi, qword[toolbar]
    mov     rsi, GTK_TOOLBAR_ICONS
    call    gtk_toolbar_set_style
    
    mov     rdi, qword[toolbar]
    mov     rsi, 2
    call    gtk_container_set_border_width
    
    mov     rdi, toolbaritem.undo
    call    gtk_tool_button_new_from_stock
    mov     qword[undo], rax
    
    mov     rdi, qword[undo]
    mov     rsi, toolbaritem.undoname
    call    gtk_widget_set_name
    
    mov     rdi, qword[toolbar]
    mov     rsi, qword[undo]
    mov     rdx, -1
    call    gtk_toolbar_insert
    
    mov     rdi, toolbaritem.redo
    call    gtk_tool_button_new_from_stock
    mov     qword[redo], rax
    
    mov     rdi, qword[redo]
    mov     rsi, toolbaritem.redoname
    call    gtk_widget_set_name
    
    mov     rdi, qword[toolbar]
    mov     rsi, qword[redo]
    mov     rdx, -1
    call    gtk_toolbar_insert
    
    call    gtk_separator_tool_item_new
    mov     qword[sep], rax
    
    mov     rdi, qword[toolbar]
    mov     rsi, qword[sep]
    mov     rdx, -1
    call    gtk_toolbar_insert
    
    mov     rdi, toolbaritem.quit
    call    gtk_tool_button_new_from_stock
    mov     qword[quit], rax
    
    mov     rdi, qword[toolbar]
    mov     rsi, qword[quit]
    mov     rdx, -1
    call    gtk_toolbar_insert

    mov     rdi, qword[box]
    mov     rsi, qword[toolbar]
    mov     rdx, FALSE
    mov     rcx, FALSE
    mov     r8d, 5
    xor     r9d, r9d
    call    gtk_box_pack_start
    
    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    mov     rcx, qword[redo]        ; pointer to the data to pass
    mov     rdx, proc_undo_redo
    mov     rsi, signal.clicked     ; pointer to the signal
    mov     rdi, qword[undo]
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    mov     rcx, qword[undo]        ; pointer to the data to pass
    mov     rdx, proc_undo_redo
    mov     rsi, signal.clicked     ; pointer to the signal
    mov     rdi, qword[redo]
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now
    
    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, gtk_main_quit      ; pointer to the handler
    mov     rsi, signal.clicked     ; pointer to the signal
    mov     rdi, QWORD[quit]        ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, gtk_main_quit      ; pointer to the handler
    mov     rsi, signal.destroy     ; pointer to the signal
    mov     rdi, QWORD[window]      ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now
    
    mov     rdi, QWORD[window]
    call    gtk_widget_show_all

    call    gtk_main

    xor     rdi, rdi
    call    exit
proc_undo_redo:
    ; rdi has the pointer to the widget
    ; rsi has the pointer to the item 
	mov	qword[widget],rdi
	mov	qword[item], rsi
	call	gtk_widget_get_name
	mov     eax, dword[rax]
	xor     eax, "undo"
	test	eax, eax
	je	.undo
	inc     dword[count]
	jmp	.redo
.undo:
	dec     dword[count]
.redo:
	mov	eax, dword[count]
	test	eax, eax
	js	.setsensitive
	mov	eax, dword[count]
	cmp	eax, 5
	jle	.done
.setsensitive:	
	mov	rax, qword[widget]
	mov	esi, FALSE
	mov	rdi, rax
	call	gtk_widget_set_sensitive
	mov	rax, qword[item]
	mov	esi, TRUE
	mov	rdi, rax
	call	gtk_widget_set_sensitive
.done:
	ret
