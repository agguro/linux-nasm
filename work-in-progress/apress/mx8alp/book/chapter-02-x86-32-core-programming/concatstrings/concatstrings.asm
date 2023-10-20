; Name:     concatstrings.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o concatstrings.o concatstrings.asm
;           g++ -m32 -o concatstrings concatstrings.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.76

global  ConcatStrings

section .text

; extern "C" int ConcatStrings(wchar_t* des, int des_size, const wchar_t* const* src, int src_n);
;
; Description:  This function performs string concatenation using
;               multiple input strings.
;
; Returns:      -1          Invalid 'des_size'
;               n >= 0      Length of concatenated string
;
; Locals Vars:  [ebp-4] = des_index
;               [ebp-8] = i

%define des_index   [ebp-4]
%define i           [ebp-8]
%define des         [ebp+8]
%define des_size    [ebp+12]
%define src         [ebp+16]
%define src_n       [ebp+20]
	
ConcatStrings:
    push    ebp
    mov     ebp,esp
    sub     esp,8
    push    ebx
    push    esi
    push    edi
    ; Make sure 'des_size' is valid
    mov     eax,-1                      ;set error code
    mov     ecx,des_size                ;ecx = 'des_size'
    cmp     ecx,0
    jle     .error
    ; Perform required initializations
    xor     eax,eax                     ;set error code
    mov     ebx,des                     ;ebx = 'des'
    mov     [ebx],eax                   ;*des = '\0'
    mov     des_index,eax               ;des_index = 0
    mov     i,eax                       ;i = 0
    ; Repeat loop until concatenation is finished
.Lp1:
    mov     eax,src                     ;eax = 'src'
    mov     edx,i                       ;edx = i
    mov     edi,[eax+edx*4]             ;edi = src[i]
    mov     esi,edi                     ;esi = src[i]
    ; Compute length of s[i]
    xor     eax,eax
    mov     ecx,-1
    repne   scasd                       ;find '\0'
    not     ecx
    dec     ecx                         ;ecx = len(src[i])
    ; Compute des_index + src_len
    mov     eax,des_index               ;eax= des_index
    mov     edx,eax                     ;edx = des_index_temp
    add     eax,ecx                     ;des_index + len(src[i])
    ; Is des_index + src_len >= des_size?
    cmp     eax,des_size
    jge     .done
    ; Update des_index
    add     des_index,ecx               ;des_index += len(src[i])
    ; Copy src[i] to &des[des_index] (esi already contains src[i])
    inc     ecx                         ;ecx = len(src[i]) + 1
    lea     edi,[ebx+edx*4]             ;edi = &des[des_index_temp]
    rep     movsd                       ;perform string move
    ; Update i and repeat if not done
    mov     eax,i
    inc     eax
    mov     i,eax                       ;i++
    cmp     eax,src_n
    jl      .Lp1                        ;jump if i < src_n
    ; Return length of concatenated string
.done:
    mov     eax,des_index               ;eax = des_index
.error:
    pop     edi
    pop     esi
    pop     ebx
    mov     esp,ebp
    pop     ebp
    ret
