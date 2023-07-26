.globl sine

default_answer = 0x312d
char_offset = '0'
dot = '.'
max_cube_root = 1626
.section .data
# if you need some data, put it here
var:
.align 8
.space 100


.section .text
# Mul
#   Params
#       a0 -- ret address
#       a3 -- left number
#       a4 -- right number
#       a5 -- output a3 * a4
mul:
        li t4, 0
        MulWhile:
        beqz a4, MulWhileEnd
        srli t2, a4, 1
        slli t2, t2, 1
        neg t2, t2
        add t2, t2, a4
        srli a4, a4, 1
        beqz t2, MulIncr
        mv t2, a3
        sll t2, t2, t4
        add a5, a5, t2

        MulIncr:
        addi t4, t4, 1
        j MulWhile
        MulWhileEnd:
        jr a0

# Div
#   Params
#       a0 -- ret address
#       a3 -- numerator
#       a4 -- denominator
#       a5 -- output a3 / a4
div:
	li a5, 0
	li t2, 62
	li t3, 0
	srli t5, a3, 63 # t5 -- current subnumber
	NewDivWhile:
	blt t5, a4, ContinueWhileDiv
	ForDebug:
	sub t5, t5, a4
	addi a5, a5, 0x01
	ContinueWhileDiv:
	slli a5, a5, 1
	slli t5, t5, 1
	srl t3, a3, t2
	andi t3, t3, 0x01
	add t5, t5, t3
	bne t2, zero, NewDivWhileCont
	blt t5, a4, NewDivWhileEnd
	addi a5, a5, 0x01
	j NewDivWhileEnd
	NewDivWhileCont:
	addi t2, t2, -1
	j NewDivWhile

	NewDivWhileEnd:
	jr a0


# Sine
#   Params
#       a1 -- input buffer will contain string with the argument
#       a2 -- output string buffer for the string result
sine:
        lb t0, 0(a1)
        li t1, 0
        li t3, 0
        li a6, dot
        li t6, 0
        li a5, max_cube_root
        Loop:
        beqz t0, End
        li t2, 10
        beq t0, t2, End
        beq t1, t2, End
        addi t1, t1, 1
        bne t0, a6, Digits
        mv t6, t1
        j Cont
        Digits:
        addi t4, t0, -char_offset
        slli t5, t3, 1
        slli t3, t3, 3
        add t3, t3, t5
        add t3, t3, t4
        bge t3, a5, Cont
        mv  a3, t3
        mv  a4, t1
        Cont:
        mv t2, a1
        add t2, t2, t1
        lb t0, 0(t2)
        j Loop
        End:

# t3 -- input as a decimal number
        bne t3, zero, NonZero
        addi t3, t3, char_offset
        sb t3, 0(a2)
        sb zero, 1(a2)
        j Result
        NonZero:
        neg t6, t6
        add t1, t1, t6
# t1 -- number of symbols after dot

# a3 -- input precised
        add a4, a4, t6
# a4 -- number of digits in a3 after dot
        mv t0, t3
        mv a6, a4

# t0 -- input as decimal
# t1 -- length of t0 after dot
# a3 -- input precised
# a6 -- length of a3 after dot

        la a0, Square
        mv a4, a3
        li a5, 0
        j mul
        Square:

        la a0, Cube
        mv a4, a5
        li a5, 0
        j mul
        Cube:
# new part!
        mv t5, a5
# t5 -- x^3

        la a0, Length
        mv  a3, a6
        li  a4, 3
        li a5, 0
        j mul
        Length:
        mv t6, a5

# t6 -- length of t5 after dot

        la a0, Division6
        mv a3, t5
        li a4, 6
        j div
        Division6:

        mv t5, a5

# t5 -- x^3 / 6

        mv t2, t6
        neg t3, t1
        add t2, t2, t3

        Expand:
        beqz t2, ExpandEnd
        slli t0, t0, 1
        slli t3, t0, 2
        add t0, t0, t3
        addi t2, t2, -1
        j Expand
        ExpandEnd:

        neg t5, t5
        add t0, t0, t5

# t0 -- practically, answer
# t6 -- power of 10
# conversion to string

        ToString:
        beqz t0, ToStringEnd

        mv a3, t0
        #call count_digits

        li t4, 0
        li a4, 10
        CountDigitLoop:
        beqz a3, CountDigitEnd
        la a0, Division10
        addi t4, t4, 1
        j div
        Division10:
        beqz a5, CountDigitEnd
        mv a3, a5
        j CountDigitLoop
        CountDigitEnd:
        mv a3, t0
        mv a4, t4


        mv t1, a4
# t1 -- number of digits in answer

        la a7, var

        li t3, char_offset
        sb t3, 0(a2)
        sb t3, 0(a7)
        li t3, dot
        sb t3, 1(a2)
        sb t3, 1(a7)
        li t3, char_offset
        mv t4, t6
        sub t4, t4, t1
        li t5, 2
        addi t4, t4, 2
        FillZeros:
        beq t5, t4, FillZerosEnd
        add a6, a2, t5
        sb t3, 0(a6)
        add a6, a7, t5
        sb t3, 0(a6)
        addi t5, t5, 1
        j FillZeros
        FillZerosEnd:

        add t1, t1, t5
        addi t1, t1, -1
        addi t5, t5, -1
        DumpAnswer:
        beq t1, t5, ToStringEnd
	mv t0, t5 #CHANGED
        li a4, 10
        la a0, DivDump
        j div
	DivDump:
	mv t5, t0 # CHANGED
        mv t3, a5
        mv t0, a3

        slli a3, a5, 3
        slli a5, a5, 1
        add a5, a5, a3

        sub t6, t0, a5
        add a6, a2, t1
        addi t6, t6, char_offset
        sb t6, 0(a6)
        add a6, a7, t1
        sb t6, 0(a6)
        mv a3, t3
        addi t1, t1, -1
        j DumpAnswer

        ToStringEnd:
        Result:

        ret
