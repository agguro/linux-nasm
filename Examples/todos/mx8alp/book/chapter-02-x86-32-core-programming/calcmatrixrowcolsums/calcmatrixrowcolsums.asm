; Name:     calcmatrixrowcolsums.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o calcmatrixrowcolsums.o calcmatrixrowcolsums.asm
;           g++ -m32 -o calcmatrixrowcolsums calcmatrixrowcolsums.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.62

global  CalcMatrixRowColSums

section .text

; extern "C" int CalcMatrixRowColSums(const int* x, int nrows, int ncols, int* row_sums, int* col_sums);
;
; Description:  The following function sums the rows and columns of a
;               2-D matrix.
;
; Returns:      0 = 'nrows' or 'ncols' is invalid
;               1 = success

%define x           [ebp+8]         ; matrix nrows x ncols
%define nrows       [ebp+12]
%define ncols       [ebp+16]
%define row_sums    [ebp+20]        ; matrix nrows x 1
%define col_sums    [ebp+24]        ; matrix 1 x ncols
    
CalcMatrixRowColSums:
    push    ebp
    mov     ebp,esp
    push    ebx
    push    esi
    push    edi
    ; Make sure 'nrow' and 'ncol' are valid
    xor     eax,eax                     ;error return code
    cmp     dword nrows,0               ;[ebp+12] = 'nrows'
    jle     .invalidArg                 ;jump if nrows <= 0
    mov     ecx,ncols                   ;ecx = 'ncols'
    cmp     ecx,0
    jle     .invalidArg                 ;jump if ncols <= 0
    ; Initialize elements of 'col_sums' array to zero
    mov     edi,col_sums                ;edi = 'col_sums'
    xor     eax,eax                     ;eax = fill value
    rep stosd                           ;fill array with zeros
    ; Initialize outer loop variables
    mov     ebx,x                       ;ebx = 'x'
    xor     esi,esi                     ;i = 0
    ; Outer loop
.lp1:
    mov     edi,row_sums                ;edi = 'row_sums'
    mov     dword[edi+esi*4],0          ;row_sums[i] = 0
    xor     edi,edi                     ;j = 0
    mov     edx,esi                     ;edx = i
    imul    edx,ncols                   ;edx = i * ncols
    ; Inner loop
.lp2:
    mov     ecx,edx                     ;ecx = i * ncols
    add     ecx,edi                     ;ecx = i * ncols + j
    mov     eax,[ebx+ecx*4]             ;eax = x[i * ncols + j]
    mov     ecx,row_sums                ;ecx = 'row_sums'
    add     [ecx+esi*4],eax             ;row_sums[i] += eax
    mov     ecx,col_sums                ;ecx = 'col_sums'
    add     [ecx+edi*4],eax             ;col_sums[j] += eax
    ; Is inner loop finished?
    inc     edi                         ;j++
    cmp     edi,ncols 
    jl      .lp2                        ;jump if j < ncols
    ; Is outer loop finished?
    inc     esi                         ;i++
    cmp     esi,nrows
    jl      .lp1                        ;jump if i < nrows
    mov     eax,1                       ;set success return code
.invalidArg:
    pop     edi
    pop     esi
    pop     ebx
    pop     ebp
    ret
