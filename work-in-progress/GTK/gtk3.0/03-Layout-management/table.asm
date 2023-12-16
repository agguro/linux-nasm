; Name        : gtktable.asm
;
; Build       : nasm -felf64 -o gtktable.o -l gtktable.lst gtktable.asm
;               ld -s -m elf_x86_64 aboutbox.o -o aboutbox -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : layout example - calculator demo
;
; C - source : http://zetcode.com/tutorials/gtktutorial/gtklayoutmanagement/

bits 64

[list -]
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
     %define   FALSE                 0
     %define   TRUE                  1
     
     extern    exit
     extern    gtk_init
     extern    gtk_window_new
     extern    gtk_window_set_title
     extern    gtk_window_set_default_size
     extern    gtk_window_set_position
     extern    gtk_button_new_with_label
     extern    gtk_container_set_border_width
     extern    gtk_table_attach_defaults
     extern    gtk_table_new
     extern    gtk_table_set_col_spacings
     extern    gtk_table_set_row_spacings
     extern    gtk_button_new_with_label
     extern    g_signal_connect_data
     extern    gtk_container_add
     extern    gtk_widget_show_all
     extern    gtk_main
     extern    gtk_main_quit
[list +]

section .data
    window:
      .handle:     dq  0
      .title:      db  "GtkTable",0
    table:
      .handle:     dq  0
    button:
      .handle:     dq  0
    signal:
      .destroy:    db  "destroy",0
    values:        db  "7","8","9","/","4","5","6","*","1","2","3","-","0",".","=","+"
    .size:         equ $-values
    buffer:        db  0,0			; to store values temporarly

section .text
    global _start

_start:
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     QWORD[window.handle], rax

    mov     rdi, QWORD[window.handle]
    mov     rsi, window.title
    call    gtk_window_set_title

    mov     rdi, qword [window.handle]
    mov     rsi, 250
    mov     rdx, 180
    call    gtk_window_set_default_size

    mov     rdi, QWORD[window.handle]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    mov     rdi, qword[window.handle]
    mov     rsi, 5
    call    gtk_container_set_border_width
    
    mov     rdi, 4
    mov     rsi, 4
    mov     rdx, TRUE
    call    gtk_table_new
    mov     qword[table.handle], rax
    
    mov     rdi, qword[table.handle]
    mov     rsi, 2
    call    gtk_table_set_row_spacings
    
    mov     rdi, qword[table.handle]
    mov     rsi, 2
    call    gtk_table_set_col_spacings
    
    mov     rsi, values
    mov     rdi, buffer
    mov     rcx, values.size
    ; start adding buttons to the table
.nextbutton:
    cld
    lodsb				; load values[i] in AL
    stosb				; store in buffer
    dec     rdi				; adjust buffer offset
    dec     rcx                         ; adjust counter
    
    push    rdi
    push    rsi
    push    rax
    push    rcx
    
    push    rcx
    mov     rdi, buffer
    call    gtk_button_new_with_label
    mov     qword[button.handle], rax
    pop     rcx
    
    ; rcx is the loopcounter, and goes from from 0xF to 0x0
    ; the one's complement gives us 0x0 ... 0xF
    ; if we put it in a table we get
    ;       xx00   xx01   xx10   xx11
    ; 00xx    7     8      9      /
    ; 01xx    4     5      6      *
    ; 10xx    1     2      3      -
    ; 11xx    0     .      =      +
    ; so for the columns we use the two lowest bits, for the rows we use the two highest bits of the lowest four bits of rcx
    ; this method is quit shorter than when using two count variables i and j like we should do in higher level programs
    
    not     rcx
    and     rcx, 0xF			; exclude all other bits except lowest 4
    ;; calculate i
    mov     r8, rcx
    shr     r8, 2
    ;; calculate i+1
    mov     r9, r8
    inc     r9
    ;; calculate j
    mov     rdx, rcx
    and     rdx, 3
    ; calculate j+1
    mov     rcx, rdx
    inc     rcx   
    mov     rdi, qword[table.handle]
    mov     rsi, qword[button.handle]
    call    gtk_table_attach_defaults
    pop     rcx
    pop     rax
    pop     rsi
    pop     rdi
    and     rcx, rcx
    jnz	    .nextbutton

    
    mov     rdi, qword[window.handle]
    mov     rsi, qword[table.handle]
    call    gtk_container_add
    
    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, gtk_main_quit      ; pointer to the handler
    mov     rsi, signal.destroy     ; pointer to the signal
    mov     rdi, QWORD[window.handle]      ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now
       
    mov     rdi, QWORD[window.handle]
    call    gtk_widget_show_all

    call    gtk_main

    xor     rdi, rdi                ; we don't expect much errors now thus errorcode=0
    call    exit
