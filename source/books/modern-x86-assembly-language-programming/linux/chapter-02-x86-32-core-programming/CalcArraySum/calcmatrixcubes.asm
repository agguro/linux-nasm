; Name:     calcmatrixcubes.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o calcmatrixcubes.o calcmatrixcubes.asm
;           g++ -m32 -o calcmatrixcubes calcmatrixcubes.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.61

global  CalcMatrixCubes

section .text

; extern "C" int CalcMatrixCubes(int* y, const int* x, int nrows, int ncols);
;
; Description:  This function computes y[i,j] = x[i,j] * x[i,j] * x[i,j] for a given n x m matrix
;
; Returns:      0 = 'nrows' or 'ncols' is invalid
;               1 = success
;
; the matrix is stored at location [ebp+12] with element (1,1) in front
; followed by the row elements and that for each column.
; matrix a  b
;        c  d
; is stored at [ebp+12] : a, b, c, d
; This means that we can treath a matrix as an array of nrows x ncols
; starting at offset [ebp +12].

%define y        [ebp+8]
%define x        [ebp+12]
%define nrows    [ebp+16]
%define ncols    [ebp+20]

CalcMatrixCubes:
    push    ebp
    mov     ebp,esp
    push    ebx
    xor     eax,eax             ;return value on error
    ; Compute number of items
    mov     ecx,nrows
    imul    ecx,ncols
    and     ecx, ecx
    jle     .emptyArray
    ; Initialize matrices
    mov     esi,x               ;source matrix
    mov     edi,y               ;destination matrix
    ; Save flag D
    pushfd
    ; Calculate cube of each element in the array
    cld                         ;clear direction flag
.repeat:
    lodsd                       ;eax = element at esi
    mov     ebx,eax             ;save value
    imul    eax,eax             ;eax=x[i]*x[i]
    imul    eax,ebx             ;eax=x[i]*x[i]*x[i]
    stosd                       ;store result
    loopnz  .repeat             ;repeat for all elements
    ; Restore flag D
    popfd
    mov     eax,1               ;return value on success
.emptyArray:
    pop     ebx
    pop     ebp
    ret
