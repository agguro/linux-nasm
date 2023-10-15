; Name:     concatstrings.asm
;
; Source:   Modern x86 Assembly Language Programming p.553

; extern "C" int ConcatStrings_(wchar_t* des, int des_size, const wchar_t* const* src, int src_n)
;
; Description:  This function performs string concatenation using
;               multiple input strings.
;
; Returns:      -1          Invalid des_size or src_n
;               n >= 0      Length of concatenated string

global ConcatStrings_

section .text

ConcatStrings_:
;            GCC                Windows
; Registers: rdi    des         rcx
;            rsi    des_size    rdx
;            rdx    src         r8
;            rcx    src_n       r9

; Create stackframe    
    push    rbp
    mov     rbp,rsp
    sub     rsp,8                       ;align stack
    push    r12                         ;save non-volatile register
    push    r13
    push    r14
    push    r15
    push    rbx
    push    rdi                         ;save *des
    mov     rax,-1                      ;assume error

; Make sure des_size and src_n are  greater than zero
    movsxd  rsi,esi                     ;rsi = des_size
    test    rsi,rsi
    jle     .error                      ;jump if des_size <= 0
    movsxd  rcx,ecx                     ;rcx = src_n
    test    rcx,rcx
    jle     .error                      ;jump if src_n <= 0

; Perform required initializations
    mov     rbx,rdi
    mov     r8,rdx
    mov     r9,rcx
    mov     rdx,rsi
    xor     r10,r10                     ;des_index = 0
    xor     r11,r11                     ;i = 0
    mov     dword[rbx],r10d             ;*des = '\0';

; Repeat loop until concatenation is finished
.lp1:
    mov     rdi,[r8+r11*8]              ;rdi = src[i]
    mov     rsi,rdi                     ;rsi = src[i]

; Compute length of s[i]
    xor     rax,rax
    mov     rcx,-1
    repne   scasd                       ;find '\0'
    not     rcx
    dec     rcx                         ;rcx = len(src[i])

; Compute des_index + src_len
    mov     rax,r10                     ;rax= des_index
    add     rax,rcx                     ;rax = des_index + len(src[i])

; Is des_index + src_len >= des_size?
    cmp     rax,rdx
    jge     .done

; Copy src[i] to &des[des_index] (rsi already contains src[i])
    inc     rcx                         ;rcx = len(src[i]) + 1
    lea     rdi,[rbx+r10*4]             ;rdi = &des[des_index]
    rep     movsd                       ;perform string move

; Update des_index
    mov     r10,rax                     ;des_index += len(src[i])

; Update i and repeat if not done
    inc     r11                         ;i += 1
    cmp     r11,r9                      ;is i >= src_n?
    jl      .lp1                        ;jump if i < src_n

; Return length of concatenated string
.done:
    mov     eax,r10d                    ;eax = trunc(des_index)

; Return error code or length of string
.error:
    pop     rdi                         ;restore *des
    pop     rbx                         ;restore non-volatile registers
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    mov     rsp,rbp                     ;restore stack
    pop     rbp
    ret
