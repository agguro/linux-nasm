; Name        : listview.asm
;
; Build       : nasm -felf64 -o listview.o  listview.asm
;               ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -melf_x86_64 -g -o listview listview.o -lc -lgtk-x11-2.0 -lgdk-x11-2.0 -lgobject-2.0 -lgdk_pixbuf-2.0 -lglib-2.0
;
; Description : a listview with some functionality
;               debugging the C source reveals that only register rbx can be
;               used in a safe way to store the value of the label pointer in
;               the on_changed event routine.
; Source      : http://zetcode.com/gui/gtk2/gtktreeview/ (listview.c)

bits 64

[list -]
    %define    GTK_WINDOW_TOPLEVEL   0
    %define    GTK_WIN_POS_CENTER    1
    %define    FALSE                 0
    %define    TRUE                  1
    %define    LIST_ITEM             0
    %define    N_COLUMNS             1
    %define    G_TYPE_STRING        64

    extern     gtk_init
    extern     gtk_main
    extern     gtk_main_quit
    extern     gtk_widget_show_all
    extern     gtk_window_new
    extern     gtk_window_set_title
    extern     gtk_tree_view_new
    extern     gtk_container_set_border_width
    extern     gtk_window_set_default_size
    extern     gtk_window_set_position
    extern     gtk_tree_view_set_headers_visible
    extern     gtk_vbox_new
    extern     gtk_box_pack_start
    extern     gtk_container_add
    extern     gtk_tree_view_get_selection
    extern     gtk_label_new
    extern     gtk_tree_view_column_new_with_attributes
    extern     gtk_tree_view_append_column
    extern     gtk_tree_view_set_model
    extern     gtk_list_store_append
    extern     gtk_list_store_new
    extern     gtk_cell_renderer_text_new
    extern     gtk_tree_view_get_model
    extern     gtk_list_store_set
    extern     gtk_tree_selection_get_selected
    extern     gtk_tree_model_get
    extern     gtk_label_set_text
    extern     g_signal_connect_data
    extern     g_free
    extern     g_object_unref
    extern     exit
[list +]

section .rodata
    szTitle:      db    "list view - Store",0
    szDestroy:    db    "destroy",0
    szChanged:    db    "changed",0
    szLabel:      db    "",0
    szAliens:       db  "Aliens",0
    szLeon:         db  "Leon",0
    szNorthFace:    db  "North face",0
    szTheVerdict:   db  "The verdict",0
    szDerUntergang: db  "Der Untergang",0
    szText:         db  "text",0
    szListItems:    db  "List Items",0
 
section .bss   
    model:        resq  1
    value:        resq  1
    iter:         resq  1
    selectiter:   resq  1
    window:       resq  1
    list:         resq  1
    vbox:         resq  1
    label:        resq  1
    selection:    resq  1
    renderer:     resq  1
    column:       resq  1
    store:        resq  1
    liststore:    resq  1

section .text
global _start

_start:
    ;init gtk
    xor     rdi,rdi                 
    xor     rsi,rsi
    call    gtk_init
    ;create a new window
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword[window],rax
    call    gtk_tree_view_new
    mov     qword[list],rax
    ;set the title
    mov     rdi,qword[window]
    mov     rsi,szTitle
    call    gtk_window_set_title

    mov     rdi,qword[window]
    mov     rsi,GTK_WIN_POS_CENTER
    call    gtk_window_set_position
    mov     rdi,qword[window]
    mov     rsi,10
    call    gtk_container_set_border_width
    mov     rdi,qword[window]
    mov     rsi,270
    mov     rdx,250
    call    gtk_window_set_default_size
    mov     rdi,qword[list]
    mov     rsi,FALSE
    call    gtk_tree_view_set_headers_visible
    mov     rdi,FALSE
    mov     rsi,0
    call    gtk_vbox_new
    mov     qword[vbox],rax
    mov     rdi,qword[vbox]
    mov     rsi,qword[list]
    mov     rdx,TRUE
    mov     rcx,TRUE
    mov     r8,5
    xor     r9,r9
    call    gtk_box_pack_start
    mov     rdi,szLabel
    call    gtk_label_new
    mov     qword[label],rax
    mov     rdi,qword[vbox]
    mov     rsi,qword[label]
    mov     rdx,FALSE
    mov     rcx,FALSE
    mov     r8,5
    xor     r9,r9
    call    gtk_box_pack_start
    mov     rdi,qword[window]
    mov     rsi,qword[vbox]
    call    gtk_container_add

    ;we only have one list so we can use the global variable
    call    init_list
    mov     rdi,szAliens
    call    add_to_list
    mov     rdi,szLeon
    call    add_to_list
    mov     rdi,szTheVerdict
    call    add_to_list   
    mov     rdi,szNorthFace
    call    add_to_list
    mov     rdi,szDerUntergang
    call    add_to_list
 
    mov     rdi,qword[list]
    call    gtk_tree_view_get_selection
    mov     qword[selection],rax

    ;connect the changed signal to on_changed event handler
    xor     r9d,r9d                    ; combination of GConnectFlags 
    xor     r8d,r8d                    ; a GClosureNotify for data
    mov     rcx,qword[label]             ; pointer to the data to pass
    mov     rdx,on_changed             ; pointer to the handler
    mov     rsi,szChanged              ; pointer to the signal
    mov     rdi,qword[selection]       ; pointer to the widget instance
    ;C programs uses g_signal_connect, this is not a library function.
    call    g_signal_connect_data

    ;connect the destroy signal to gtk_main_quit event handler
    xor     r9d,r9d                    ; combination of GConnectFlags 
    xor     r8d,r8d                    ; a GClosureNotify for data
    xor     rcx,rcx                    ; pointer to the data to pass
    mov     rdx,gtk_main_quit          ; pointer to the handler
    mov     rsi,szDestroy              ; pointer to the signal
    mov     rdi,qword[window]          ; pointer to the widget instance
    ;C programs uses g_signal_connect, this is not a library function.
    call    g_signal_connect_data

    ;show the window
    mov     rdi,qword[window]
    call    gtk_widget_show_all
    ;go into applications main loop
    call    gtk_main
.exit:    
    ;exit program
    xor     rdi,rdi
    call    exit

on_changed:
    ;rdi has the pointer to the widget pointer
    ;rsi has the pointer to the label
    push    rbp
    mov     rbx,rsi                             ;we can use rbx safely
    mov     rsi,model
    mov     rdx,selectiter
    call    gtk_tree_selection_get_selected
    test    rax,rax
    je      .done

    mov     rdi,qword[model]
    mov     rsi,selectiter
    mov     rdx,LIST_ITEM
    mov     rcx,value
    mov     r8d,-1
    call    gtk_tree_model_get

    mov     rdi,rbx
    mov     rsi,qword[value]
    call    gtk_label_set_text

    mov     rdi,qword[value]
    call    g_free
  .done:
    pop     rbp
    ret
 

init_list:
    ;normally rdi has the pointer to the list, because we have only one list we use the global variable
    push    rbp
    call    gtk_cell_renderer_text_new
    mov     qword[renderer],rax
    mov     rdi,szListItems
    mov     rsi,qword[renderer]
    mov     rdx,szText
    mov     rcx,LIST_ITEM
    xor     r8,r8
    xor     r9,r9
    call    gtk_tree_view_column_new_with_attributes
    mov     qword[column],rax
    mov     rdi,qword[list]
    mov     rsi,qword[column]
    call    gtk_tree_view_append_column
    mov     rdi,N_COLUMNS
    mov     rsi,G_TYPE_STRING
    call    gtk_list_store_new
    mov     qword[store],rax
    mov     rdi,qword[list]
    mov     rsi,qword[store]
    call    gtk_tree_view_set_model
    mov     rdi,qword[store]
    call    g_object_unref
    pop     rbp
    ret

add_to_list:
    ;pointer to listitem string in rdi
    push    rbp
    mov     rbx,rdi                              ;save pointer to listitem string
    mov     rdi,qword[list]
    call    gtk_tree_view_get_model
    mov     qword[liststore],rax
    mov     rdi,qword[liststore]
    mov     rsi,iter
    call    gtk_list_store_append
    mov     rdi,qword[liststore]
    mov     rsi,iter
    mov     rdx,LIST_ITEM
    mov     rcx,rbx
    mov     r8d,-1
    call    gtk_list_store_set
    pop     rbp
    ret
