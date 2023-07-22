input:
.align 4
.space 100

# This will be used for 0-ended string with result. Use "-1" if you cannot calculate the function
output:
.align 4
.space  100

.section .text
.globl _start

_start:

	li      a7, read
	li      a0, 0
	la      a1, input
	li      a2, 100
	ecall

	la      a1, input
	la      a2, output
	call    sine

	li      a7, write
	li      a0, 1
	la      a1, output
	li      a2, 100
	ecall

        li      a0, 0
        li      a7, exit
        ecall

