;source: https://stackoverflow.com/questions/4812869/how-to-write-self-modifying-code-in-x86-assembly

global f4

section .text

f4:
    push    rbp             ; standard function start
    mov     rsp,rbp

f:
    mov	    rax, 1          ; moving one to %eax
    mov     byte[f+1],0     ; overwriting operand in mov instuction over
                            ; the new immediate value is now 0. f+1 is the place
                            ; in the program for the first operand.

    pop rbp                 ; standard end
    ret
