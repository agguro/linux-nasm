; Name:     createstruct.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o createstruct.o createstruct.asm
;           g++ -m32 -o createstruct createstruct.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.71

extern  malloc
extern  free

global  CreateTestStruct
global  ReleaseTestStruct

; the structure in nasm
struc TEST_STRUC
    .Val8:  resb    1
    .Pad8:  resb    1
    .Val16: resw    1
    .Val32: resd    1
    .Val64: resq    1
    .size:
endstruc

; assuming that ts is represented in eax
%define ts.Val8         byte[eax+TEST_STRUC.Val8]
%define ts.Val16        word[eax+TEST_STRUC.Val16]
%define ts.Val32        dword[eax+TEST_STRUC.Val32]
%define ts.Val64.low    dword[eax+TEST_STRUC.Val64]
%define ts.Val64.high   dword[eax+TEST_STRUC.Val64+4]
%define ts.size         TEST_STRUC.size

section .text

; extern "C" TestStruct* CreateTestStruct(int8_t val8, int16_t val16, int32_t val32, int64_t val64);
;
; Description:  This function allocates and initializes a new TestStruct.
;
; Returns:      A pointer to the new TestStruct or NULL error occurred.

%define val8        [ebp+8]
%define val16       [ebp+12]
%define val32       [ebp+16]
%define val64.low   [ebp+20]
%define val64.high  [ebp+24]
	
CreateTestStruct:
    push    ebp
    mov     ebp,esp
    ; Allocate a block of memory for the new TestStruct; note that 
    ; malloc() returns a pointer to memory block in EAX
    push    ts.size
    call    malloc
    add     esp,4
    or      eax,eax					; NULL pointer test
    jz      .mallocError			; Jump if malloc failed
    ; Initialize the new TestStruct
    mov     dl,val8
    mov     ts.Val8,dl
    mov     dx,val16
    mov     ts.Val16,dx
    mov     edx,val32
    mov     ts.Val32,edx
    mov     ecx,val64.low
    mov     edx,val64.high
    mov     ts.Val64.low,ecx
    mov     ts.Val64.high,edx
.mallocError:
    pop     ebp
    ret

; extern "C" void ReleaseTestStruct(const TestStruct* p);
;
; Description:  This function release a previously created TestStruct.
;
; Returns:      None.

%define p   dword[ebp+8]

ReleaseTestStruct:
    push    ebp
    mov     ebp,esp
    ; Call free() to release previously created TestStruct
    push    p
    call    free
    add     esp,4
    pop     ebp
    ret
