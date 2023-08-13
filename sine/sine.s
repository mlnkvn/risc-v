.globl sine

char_offset = '0'
dot = '.'
max_cube_root = 2097153
max_input = 922337203685477579
max_fifth = 6208
max_seventh = 512
max_nineth = 128
max11 = 53
max13 = 29
max15 = 19
max17 = 13
max19 = 10
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
	ret

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
	ret

pow:
	li a5, 0
	mv t4, a4
	mv t6, a3
	beqz a3, PowRet
	li a5, 1
	PowLoop:
	beqz t4, PowRet
	mv a7, ra
	mv a3, a5
	mv a4, t6
	call mul
	mv ra, a7
	addi t4, t4, -1
	j PowLoop
	PowRet:
	ret

eq:
	EqLoop:
	blt t6, t1, Check
	beq t6, t1, Check
	mv a3, t5
	li a4, 10
	mv a7, ra
	call div
	mv ra, a7
	mv a7, a5
	slli a7, a7, 1
	slli t5, a7, 2
	add t5, t5, a7
	sub a4, a3, t5
	mv a7, t5
	mv t5, a5
	addi t6, t6, -1
	j EqLoop
	Check:
	li a3, 5
	blt a4, a3, Equalize
	addi t5, t5, 1
	Equalize:
	sub t2, t1, t6
	EqualizeLoop:
	beqz t2, EqualizeEnd
	slli t5, t5, 1
	slli t3, t5, 2
	add t5, t5, t3
	addi t2, t2, -1
	j EqualizeLoop
	EqualizeEnd:
	mv t6, t1
	ret

sine:
	mv a0, ra
	lb t0, 0(a1)
	li t1, 0
	li t3, 0
	li a6, dot
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
	li t4, max_input
	ResizeLoop:
	bge t3, t4, Calc
	slli t3, t3, 1
	slli t2, t3, 2
	add t3, t3, t2
	addi t1, t1, 1
	J:
	j ResizeLoop

	Calc:
	la t0, var
	sd t3, 0(t0)
	sw t1, 8(t0)
	mv t0, t3

	mv a6, t1
	mv a3, t0
	li a7, max_cube_root
	ReduceLoop3:
	bge a7, a3, ReduceResult3
	li a4, 10
	call div
	mv a4, a5
	slli a4, a4, 1
	slli t2, a4, 2
	add a4, a4, t2
	sub t4, a3, a4
	addi a6, a6, -1
	mv a3, a5
	j ReduceLoop3
	ReduceResult3:
	li t2, 5
	blt t4, t2, NoCarry3
	addi a3, a3, 1
	NoCarry3:
	li a4, 3
	call pow
	mv a3, a5
	li a4, 6
	call div
	mv a7, a5
	mv a3, a6
	li a4, 3
	call mul
	mv t6, a5
	mv t5, a7
	call eq
	sub t0, t0, t5

	la a7, var
	lw a6, 8(a7)
	ld a7, 0(a7)
	mv a3, a7
	li a7, max_fifth
	ReduceLoop:
	bge a7, a3, ReduceResult
	li a4, 10
	call div
	mv a4, a5
	slli a4, a4, 1
	slli t2, a4, 2
	add a4, a4, t2
	sub t4, a3, a4
	addi a6, a6, -1
	mv a3, a5
	j ReduceLoop
	ReduceResult:
	li t2, 5
	blt t4, t2, NoCarry5
	addi a3, a3, 1
	NoCarry5:
	li a4, 5
	call pow
	mv a3, a5
	li a4, 120
	call div
	mv a7, a5
	mv a3, a6
	li a4, 5
	call mul
	mv t6, a5
	mv t5, a7
	call eq
	add t0, t0, t5

	la a7, var
	lw a6, 8(a7)
	ld a7, 0(a7)
	mv a3, a7
	li a7, max_seventh
	ReduceLoop7:
	bge a7, a3, ReduceResult7
	li a4, 10
	call div
	mv a4, a5
	slli a4, a4, 1
	slli t2, a4, 2
	add a4, a4, t2
	sub t4, a3, a4
	addi a6, a6, -1
	mv a3, a5
	j ReduceLoop7
	ReduceResult7:
	li t2, 5
	blt t4, t2, NoCarry7
	addi a3, a3, 1
	NoCarry7:
	li a4, 7
	call pow
	mv a3, a5
	li a4, 5040
	call div
	mv a7, a5
	mv a3, a6
	li a4, 7
	call mul
	mv t6, a5
	mv t5, a7
	call eq
	sub t0, t0, t5

	la a7, var
	lw a6, 8(a7)
	ld a7, 0(a7)
	mv a3, a7
	li a7, max_nineth
	ReduceLoop9:
	bge a7, a3, ReduceResult9
	li a4, 10
	call div
	mv a4, a5
	slli a4, a4, 1
	slli t2, a4, 2
	add a4, a4, t2
	sub t4, a3, a4
	addi a6, a6, -1
	mv a3, a5
	j ReduceLoop9
	ReduceResult9:
	li t2, 5
	blt t4, t2, NoCarry9
	addi a3, a3, 1
	NoCarry9:
	li a4, 9
	call pow
	mv a3, a5
	li a4, 362880
	call div
	mv a7, a5
	mv a3, a6
	li a4, 9
	call mul
	mv t6, a5
	mv t5, a7
	call eq
	add t0, t0, t5

	la a7, var
	lw a6, 8(a7)
	ld a7, 0(a7)
	mv a3, a7
	li a7, max11
	ReduceLoop11:
	bge a7, a3, ReduceResult11
	li a4, 10
	call div
	mv a4, a5
	slli a4, a4, 1
	slli t2, a4, 2
	add a4, a4, t2
	sub t4, a3, a4
	addi a6, a6, -1
	mv a3, a5
	j ReduceLoop11
	ReduceResult11:
	li t2, 5
	blt t4, t2, NoCarry11
	addi a3, a3, 1
	NoCarry11:
	li a4, 11
	call pow
	mv a3, a5
	li a4, 39916800
	call div
	mv a7, a5
	mv a3, a6
	li a4, 11
	call mul
	mv t6, a5
	mv t5, a7
	call eq
	sub t0, t0, t5

	la a7, var
	lw a6, 8(a7)
	ld a7, 0(a7)
	mv a3, a7
	li a7, max13
	ReduceLoop13:
	bge a7, a3, ReduceResult13
	li a4, 10
	call div
	mv a4, a5
	slli a4, a4, 1
	slli t2, a4, 2
	add a4, a4, t2
	sub t4, a3, a4
	addi a6, a6, -1
	mv a3, a5
	j ReduceLoop13
	ReduceResult13:
	li t2, 5
	blt t4, t2, NoCarry13
	addi a3, a3, 1
	NoCarry13:
	li a4, 13
	call pow
	mv a3, a5
	li a4, 6227020800
	call div
	mv a7, a5
	mv a3, a6
	li a4, 13
	call mul
	mv t6, a5
	mv t5, a7
	call eq
	add t0, t0, t5

	la a7, var
	lw a6, 8(a7)
	ld a7, 0(a7)
	mv a3, a7
	li a7, max15
	ReduceLoop15:
	bge a7, a3, ReduceResult15
	li a4, 10
	call div
	mv a4, a5
	slli a4, a4, 1
	slli t2, a4, 2
	add a4, a4, t2
	sub t4, a3, a4
	addi a6, a6, -1
	mv a3, a5
	j ReduceLoop15
	ReduceResult15:
	li t2, 5
	blt t4, t2, NoCarry15
	addi a3, a3, 1
	NoCarry15:
	li a4, 15
	call pow
	mv a3, a5
	li a4, 1307674368000
	call div
	mv a7, a5
	mv a3, a6
	li a4, 15
	call mul
	mv t6, a5
	mv t5, a7
	call eq
	sub t0, t0, t5

	la a7, var
	lw a6, 8(a7)
	ld a7, 0(a7)
	mv a3, a7
	li a7, max17
	ReduceLoop17:
	bge a7, a3, ReduceResult17
	li a4, 10
	call div
	mv a4, a5
	slli a4, a4, 1
	slli t2, a4, 2
	add a4, a4, t2
	sub t4, a3, a4
	addi a6, a6, -1
	mv a3, a5
	j ReduceLoop17
	ReduceResult17:
	li t2, 5
	blt t4, t2, NoCarry17
	addi a3, a3, 1
	NoCarry17:
	li a4, 17
	call pow
	mv a3, a5
	li a4, 355687428096000
	call div
	mv a7, a5
	mv a3, a6
	li a4, 17
	call mul
	mv t6, a5
	mv t5, a7
	call eq
	add t0, t0, t5

	la a7, var
	lw a6, 8(a7)
	ld a7, 0(a7)
	mv a3, a7
	li a7, max19
	ReduceLoop19:
	bge a7, a3, ReduceResult19
	li a4, 10
	call div
	mv a4, a5
	slli a4, a4, 1
	slli t2, a4, 2
	add a4, a4, t2
	sub t4, a3, a4
	addi a6, a6, -1
	mv a3, a5
	j ReduceLoop19
	ReduceResult19:
	li t2, 5
	blt t4, t2, NoCarry19
	addi a3, a3, 1
	NoCarry19:
	li a4, 19
	call pow
	mv a3, a5
	li a4, 121645100408832000
	call div
	mv a7, a5
	mv a3, a6
	li a4, 19
	call mul
	mv t6, a5
	mv t5, a7
	call eq
	sub t0, t0, t5

	mv t6, t1
	ToString:
	beqz t0, Result
	mv a3, t0
	li t4, 0
	li a4, 10
	CountDigitLoop:
	beqz a3, CountDigitEnd
	addi t4, t4, 1
	call div
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
	j Result
	ToStringCont:
	li t3, char_offset
	sb t3, 0(a2)
	sb t3, 0(a7)
	li t3, dot
	sb t3, 1(a2)
	sb t3, 1(a7)
	li t3, char_offset
	mv t1, t6
	addi t1, t1, 2
	DumpAnswer:
	li t6, 2
	beq t1, t6, Result
	mv t0, t5
	li a4, 10
	call div
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
	Result:
	mv ra, a0
	ret