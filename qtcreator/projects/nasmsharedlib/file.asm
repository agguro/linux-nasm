;name: %{FileName}.asm
;
;description: shared library %{FileName}.so
;
;remark: use objdump -T %{FileName}.so | grep "DF" for exported functions
;            objdump -T %{FileName}.so | grep "DO" for exported symbols

bits 64

%include "%{FileName}.inc"

section .bss

section .data

section .text

global main

;this is a dummy procedure, replace by your own
_proc main

_endp main

