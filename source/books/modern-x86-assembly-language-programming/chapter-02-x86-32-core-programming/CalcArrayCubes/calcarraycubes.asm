; Name:     calcarraycubes.asm
; Source:   Modern x86 Assembly Language Programming p.55

bits 32
global CalcArrayCubes_
section .text

%define y    [ebp+8]
%define x    [ebp+12]
%define n    [ebp+16]

; extern "C" bool CalcArrayCubes_(int* y, const int* x, int n);
; Description:  The following function calculates y[n] = x[n]³
; Returns       0 = Invalid 'n'
;               1 = Success

CalcArrayCubes_:
	push    ebp
	mov     ebp,esp
	push    esi
	push    edi
	push    ebx
	; Load arguments, make sure 'n' is valid
	xor     eax,eax                 ;error return code
	mov     ecx,n                   ;ecx = 'n'
	test    ecx,ecx
	jle     .error                  ;jump if 'n' <= 0
	; Initialize pointer to x[0] and direction flag
	mov     esi,x
	mov     edi,y
	pushfd                          ;save current direction flag
	cld                             ;EFLAGS.DF = 0
	; Repeat loop until array calculation is finished
.repeat:
	lodsd                           ;eax = x[n]
	mov     ebx, eax                ;ebx = x[n]
	imul    eax                     ;x[n]*x[n]
	imul    ebx                     ;x[n]*x[n]*x[n]
	stosd
	dec     ecx                     ;n--
	jnz     .repeat
	popfd                           ;restore direction flag
	mov     eax,1                   ;set success return code
.error:
	pop     ebx
	pop     edi
	pop     esi
	pop     ebp
	ret
