;name: dynamic.asm
;
;description: shared library dynamic.so
;
;remark: use objdump -T libdynamic.so | grep "DF" for exported functions
;            objdump -T libdynamic.so | grep "DO" for exported symbols

bits 64

%include "../../../qmake/libraries/dynamic/dynamic.inc"

section .bss

section .data
    ;global data residing in the mainprograms data section
    ;don't forget the eol (ascii 10) at the end to flush to stdout or you see nothing on screen.
    versionstring1: db  "sharedlib version 1.0.0.0 by agguro residing in .data section of program",10,0
    .len:           equ $-versionstring1

section .rodata
    ;local rodata
    versionnr:      dw  1,0,0,0
    .len:           equ $-versionnr

    ;global rodata residing in the data section of the library
    versionstring2: db  "sharedlib version 1.0.0.0 by agguro residing in .rodata section of library",10,0
    .len:           equ $-versionstring2
    shortversion:   dq  1
    major_version:  dq  glib_major_version wrt ..sym

section .text

    ;a local function, not accessable from main (unless declared global)
    .localproc:
        mov     rax,major_version wrt ..gotoff
        add     rax,rbx
        mov     rax,[rax]
        ret                             ;we need to add ret ourselves

    ;a global function to get the version number returned in rax
    procedure getversion
        ;two ways to get the external variable
        ;first if it's stored in the datasegment, but this is a long approach
        mov     rax,major_version wrt ..gotoff                  ;get offset to GOT
        add     rax,rbx                                         ;add GOT to get the address to the addres of the variable
        mov     rax,[rax]                                       ;get the address of the variable
        mov     rax,[rax]                                       ;get the value
        ;second, the short approach, is directly from the external libary
        mov     rax,qword[rbx + glib_major_version wrt ..got]   ;read address
        mov     rax,[rax]                                       ;read value at address
    endp getversion

    ;Because versionstring1 is declared global supplied with a size, it will reside in the data
    ;section of the main program instead of the data section of the library.
    ;We have to access it as a global variable instead of local one, therefor we use wrt ..got
    ;https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/doc/nasmdoc.pdf page 120
    procedure getversionstring1                                     ;residing in datasegment of the mainprogram
        mov     rax,[rbx + versionstring1 wrt ..got]            ;the adress to the version string
    endp getversionstring1

    procedure printversionstring1
        mov     rdi,[rbx + versionstring1 wrt ..got]            ;the adress to the version string
        xor     rax,rax                                         ;in .data section of using program
        call    printf wrt ..plt
    endp printversionstring1

    ;versionstring2 isn't declared global, it will reside in the data section of the library rather
    ;than in the mainprograms data section.  Hence we need to use wrt ..gotoff to address it.
    ;https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/doc/nasmdoc.pdf page 120
    procedure getversionstring2                                     ;residing in datasegment of the mainprogram
        mov     rax,versionstring2 wrt ..gotoff                 ;the adress to the version string2
        add 	rax,rbx
    endp getversionstring2

    procedure printversionstring2
        mov     rdi,versionstring2 wrt ..gotoff                 ;the adress to the version string
        add     rdi,rbx                                         ;in .data section of library
        xor     rax,rax
        call    printf wrt ..plt
    endp printversionstring2


