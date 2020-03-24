; Name:     avxgprmulxshiftx.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o
;           nasm -f elf32 -o avxgprmulxshiftx.o avxgprmulxshiftx.asm
;           g++ -m32 -o avxgprmulxshiftx avxgprmulxshiftx.o main.o
;
; Source:   Modern x86 Assembly Language Programming p. 482

global AvxGprMulx
global AvxGprShiftx

section .text

; extern "C" Uint64 AvxGprMulx(Uint32 a, Uint32 b, Uint8 flags[2]);
;
; Description:  The following function demonstrates use of the
;               flagless unsigned integer multiply instruction mulx.
;
; Requires      BMI2.

%define a     [ebp+8]
%define b     [ebp+12]
%define flags [ebp+16]

AvxGprMulx:
    push    ebp
    mov     ebp,esp
; Save copy of status flags before mulx
    mov     ecx,flags
    lahf
    mov     byte[ecx],ah
; Perform flagless multiplication.  The mulx instruction below computes
; the product of explicit source operand [ebp+8] and implicit source
; operand edx. The 64-bit result is saved to the register pair edx:eax.
    mov     edx,b                    ;edx = b
    mulx    edx,eax,a                ;edx:eax = [ebp+8] * edx
; Save copy of status flags after mulx
    push    eax
    lahf
    mov     byte[ecx+1],ah
    pop     eax
    pop     ebp
    ret

; extern "C" void AvxGprShiftx(Int32 x, Uint32 count, Int32 results[3]);
;
; Description:  The following function demonstrates use of the flagless
;               shift instructions sarx, shlx, and shrx.
;
; Requires      BMI2

%define x       [ebp+8]
%define count   [ebp+12]
%define results [ebp+16]

AvxGprShiftx:
    push    ebp
    mov     ebp,esp
; Load argument values and perform shifts.  Note that each shift
; instruction requires three operands: DesOp, SrcOp, and CountOp.
    mov     ecx,count        ;ecx = shift bit count
    mov     edx,results      ;edx = ptr to results
    sarx    eax,x,ecx        ;shift arithmetic right
    mov     [edx],eax
    shlx    eax,x,ecx        ;shift logical left
    mov     [edx+4],eax
    shrx    eax,x,ecx        ;shift logical right
    mov     [edx+8],eax
    pop     ebp
    ret
