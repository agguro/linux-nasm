; Name        : version.asm
;
; Build       : /usr/bin/nasm -f elf64 -F dwarf -g version.asm -o version.o
;               ld -m elf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc `pkg-config --libs gtk+-3.0` version.o -o version
;
; Description : The program is restircted to show some data stored in the glib and gtk shared
;               libraries.
;               these strings can be obtained with 
;               objdump -t -T /usr/lib/x86_64-linux-gnu/libglib-2.0.so | grep .rodata
;               objdump -t -T /usr/lib/x86_64-linux-gnu/libgtk-x11-2.0.so | grep .rodata
;               and so on for other libraries.
;
; Source        : http://zetcode.com/gui/gtk2/introduction/

bits 64

[list -]
    ;glib parameters
    extern    glib_minor_version
    extern    glib_micro_version
    extern    glib_major_version
    ;gtk routines
    extern    gtk_get_major_version
    extern    gtk_get_minor_version
    extern    gtk_get_micro_version
    ;stdio
    
    extern    printf
    extern    exit
[list +]

section .rodata
    version:    db    "Glib version: %d.%d.%d",10
                db    "Gtk version: %d.%d.%d",10,0

section .text
global _start

_start:
    push    rbp
    mov     rbp,rsp
    call    gtk_get_major_version
    mov     r8,rax
    call    gtk_get_minor_version
    mov     r9,rax
    call    gtk_get_micro_version
    push    rax
    mov     rcx,[glib_micro_version]    
    mov     rdx,[glib_minor_version]    
    mov     rsi,[glib_major_version]    
    mov     rdi,version
    xor     rax,rax
    call    printf
    mov     rsp,rbp
    pop     rbp
.exit:    
    ;exit program
    xor     rdi,rdi
    call    exit