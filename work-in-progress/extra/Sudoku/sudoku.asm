;name: sudoku.asm
;
;build: nasm -felf64 -Fdwarf -o sudoku.o sudoku.asm
;       ld -melf_x86_64 -g -o sudoku sudoku.o
;
;description: sudoku solver

bits 64

%include "unistd.inc"

global _start

section .data

grid: db 0, 9, 0, 0, 0, 0, 8, 5, 3
      db 0, 0, 0, 8, 0, 0, 0, 0, 4 },
	  db				   { 0, 0, 8, 2, 0, 3, 0, 6, 9 },
	  db					   { 5, 7, 4, 0, 0, 2, 0, 0, 0 },
	  db					   { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
						   { 0, 0, 0, 9, 0, 0, 6, 4, 7 },
						   { 9, 4, 0, 1, 0, 8, 5, 0, 0 },
						   { 7, 0, 0, 0, 0, 6, 0, 0, 0 },
						   { 6, 8, 2, 0, 0, 0, 0, 9, 0 } };


section .text
_start:



exit:
    syscall exit,0
