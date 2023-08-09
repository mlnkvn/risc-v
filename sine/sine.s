.globl sine

default_answer = 0x312d
char_offset = '0'
dot = '.'
max_cube_root = 2642246
max_input = 461168601842738790
max_fifth = 7132

.section .data
var:
.align 8
.space 100

.section .text
mul:
	li a5, 0
	li t2, 0
	mv t3, a4
	bge a3, a4, MulLoop
	mv t3, a3
	mv a3, a4
	mv a4, t3
	MulLoop:
	beqz t3, MulReturn
	andi t5, t3, 0x01
	beqz t5, MulLoopEnd
	sll t5, a3, t2
	add a5, a5, t5
	MulLoopEnd:
	addi t2, t2, 1
	srl t3, t3, 1
	j MulLoop
	MulReturn:
	jr a0

div:
	li a5, 0
	li t2, 62
	li t3, 0
	srli t5, a3, 63
	DivLoop:
	blt t5, a4, DivCont
	sub t5, t5, a4
	addi a5, a5, 0x01
	DivCont:
	slli a5, a5, 1
	slli t5, t5, 1
	srl t3, a3, t2
	andi t3, t3, 0x01
	add t5, t5, t3
	bne t2, zero, DivLoopEnd
	blt t5, a4, DivReturn
	addi a5, a5, 0x01
	j DivReturn
	DivLoopEnd:
	addi t2, t2, -1
	j DivLoop
	DivReturn:
	jr a0

pow:
	mv a7, a0
	li a5, 0
	mv t4, a4
	mv t6, a3
	beqz a3, PowRet
	li a5, 1
	PowLoop:
	beqz t4, PowRet
	la a0, PowCont
	mv a3, a5
	mv a4, t6
	j mul
	PowCont:
	addi t4, t4, -1
	j PowLoop
	PowRet:
	jr a7

eq:
	bge t6, t1, Equalize
	mv t2, t0
	mv t0, t5
	mv t5, t2
	mv t2, t1
	mv t1, t6
	mv t6, t2
	Equalize:
	sub t2, t6, t1
	EqualizeLoop:
	beqz t2, EqualizeEnd
	slli t0, t0, 1
	slli t3, t0, 2
	add t0, t0, t3
	addi t2, t2, -1
	j EqualizeLoop
	EqualizeEnd:
	add t0, t0, t5
	mv t1, t6
	jr a0

sine:
	lb t0, 0(a1)
	li t1, 0
	li t3, 0
	li a6, dot
	li a5, max_cube_root
	Loop:
	beqz t0, End
	li t2, 10
	beq t0, t2, End
	li t2, max_input
	bge t3, t2, End
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
	bne t3, zero, NonZero
	addi t3, t3, char_offset
	sb t3, 0(a2)
	sb zero, 1(a2)
	j Result
	NonZero:
	sub t1, t1, t6
	sub a4, a4, t6
	mv t0, t3
	mv a6, a4
	la a0, Cube
	li a4, 3
	j pow
	Cube:
	la a0, Divided6
	mv a3, a5
	li a4, 6
	j div
	Divided6:
	mv a7, a5
	la a0, LengthForCube
	mv a3, a6
	li a4, 3
	j mul
	LengthForCube:
	mv t6, a5
	mv t5, a7
	mv a3, t0
	mv a4, t1
	neg t5, t5
	la a0, Next
	j eq
	Next:
	mv a7, a3
	mv a6, a4
	la a0, MaxLength
	mv a3, t1
	li a4, 5
	j div
	MaxLength:
	mv a3, a7
	addi a7, a5, 1
	ReduceLoop:
	blt a6, a7, ReduceResult
	la a0, Reduced
	li a4, 10
	j div
	Reduced:
	addi a6, a6, -1
	mv a3, a5
	j ReduceLoop
	ReduceResult:
	la a0, FifthPow
	li a4, 5
	j pow
	FifthPow:
	la a0, Divided120
	mv a3, a5
	li a4, 120
	j div
	Divided120:
	mv a7, a5
	la a0, LengthForFifth
	mv a3, a6
	li a4, 5
	j mul
	LengthForFifth:
	mv t6, a5
	mv t5, a7
	la a0, Next2
	j eq
	Next2:
	mv t6, t1
	ToString:
	beqz t0, ToStringEnd
	mv a3, t0
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
	la a7, var
	bge t6, t1, ToStringCont
	li t3, 49
	sb t3, 0(a2)
	ret
	ToStringCont:
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
	mv t0, t5
	li a4, 10
	la a0, DivDump
	j div
	DivDump:
	mv t5, t0
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
