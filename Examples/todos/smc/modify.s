.globl f4
.data     

f4:
    pushl %ebp       #standard function start
    movl %esp,%ebp

f:
    movl $1,%eax # moving one to %eax
    movl $0,f+1  # overwriting operand in mov instuction over
                 # the new immediate value is now 0. f+1 is the place
                 # in the program for the first operand.

    popl %ebp    # standard end
    ret
