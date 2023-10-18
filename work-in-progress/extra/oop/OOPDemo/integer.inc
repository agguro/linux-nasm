%ifndef _integer_inc_
%define _integer_inc_

struc INT_STRUC
	.value:	resq	1
	.Get:	resq	1		;;pointer to get value of integer
endstruc

%macro Integer 1-2 0
	[section .data]
	%1:	istruc INT_STRUC
		at INT_STRUC.value, dq %2
		at INT_STRUC.Get,	dq INTEGER_GET
	iend
	%define %1.value %1+INT_STRUC.value
	%define %1.Get   INTEGER_GET %1

	%macro INTEGER_GET %1
		[section .text]
		GETMETHOD:
			mov		rdi,%1
			mov		rax,qword[%1+INT_STRUC.value]
			and		rax,rax
			jz		.done				;pointer in NULL
			call	[rax]
		.done:
			ret
	%endif ;; _integer_methods_

%endmacro


%endif 		;; _integer_inc_
