; Name:     callingconvention1.asm
;
; Remark:   Allthough this example was for VC++ and GCC uses a different ABI
;           I converted this example to GCC to demonstrate the use of a
;           stackframe to store the intermediate sum of a, b, c, d and 
;           e, f, g and h.  At the end the program reads both intermediate sums,
;           add them together and returns it to the calling routine.
;           Another thought is that since this function is a leaf function,
;           we don't need to push rbp onto the stack and save rsp.  We can use
;           rsp to write directly into the memory below rsp to store the intermediate
;           results as long as they don't exceed the 128 bytes of red zone.
;           More on that in another example.
;
; Source:   Modern x86 Assembly Language Programming p.524

bits 64
global Cc1_
section .text

; extern "C" Int64 Cc1_(Int8 a, Int16 b, Int32 c, Int64 d, Int8 e, Int16 f, Int32 g, Int64 h);
;
; Description:  The following function illustrates how to create and 
;               use a basic x86-64 stack frame pointer.

%define FRAMESIZE   16      ; number of bytes to preserve (2 variables x 8 bytes)
%define RETURNADDR  16      ; size of rbp and returnaddress on the stack

Cc1_:
    ; Registers: rdi = a
    ;            rsi = b
    ;            rdx = c
    ;            rcx = d
    ;            r8  = e
    ;            r9  = f
    ;            stack g
    ;            stack h
    ; Function prolog
    push    rbp                                     ;save caller's rbp register
    sub     rsp,FRAMESIZE                           ;create space on stack for our arguments
    mov     rbp,rsp                                 ;set frame pointer
    ;Calculate a + b + c + d
    movsx   rdi,dil                                 ;sign_extend(a)
    movsx   rsi,si                                  ;sign_extend(b)
    movsx   rdx,edx                                 ;sign_extend(c)
    mov     rax,rdi                                 ;rax = a
    add     rax,rsi                                 ;rax = a + b
    add     rax,rcx                                 ;rax = a + b + c
    add     rax,rdx                                 ;rax = a + b + c + d
    mov     [rbp+FRAMESIZE-8],rax                   ;Save temporarly sum
    ;Calculate e + f + g + h
    movsx   r8,r8b                                  ;sign_extend(e)
    movsx   r9,r9w                                  ;sign_extend(f)
    mov     eax,dword[rbp+FRAMESIZE+RETURNADDR]     ;get g
    movsx   r11,eax                                 ;sign_extend(g)
    mov     rax,r8                                  ;rax = e
    add     rax,r9                                  ;rax = e + f
    add     rax,r11                                 ;rax = e + f + g
    add     rax,qword[rbp+FRAMESIZE+RETURNADDR+8]   ;rax = e + f + g + h
    mov     [rbp+FRAMESIZE-16],rax                  ;Save temporarly sum
    ;Get the intermediate sum to calculate the final sum
    mov     rax,[rbp+FRAMESIZE-8]                   ;get a + b + c + d
    add     rax,[rbp+FRAMESIZE-16]                  ;add e + f + g + h
    ; Function epilog
    add     rsp,FRAMESIZE                           ;release local stack space
    pop     rbp                                     ;restore caller's rbp register
    ret
