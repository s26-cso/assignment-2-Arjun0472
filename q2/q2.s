.section .rodata
fmt_int:
	.asciz "%d"

.text
.globl main
main:
	# save registers we keep across libc calls
	addi sp, sp, -96
	sd ra, 88(sp)
	sd s0, 80(sp)
	sd s1, 72(sp)
	sd s2, 64(sp)
	sd s3, 56(sp)
	sd s4, 48(sp)
	sd s5, 40(sp)
	sd s6, 32(sp)
	sd s7, 24(sp)

	# n = number of input integers.
	addi s0, a0, -1          # n = argc - 1
	mv s1, a1

	blez s0, .print_newline_only

	# arr
	slli a0, s0, 2
	call malloc
	mv s2, a0

	# result
	slli a0, s0, 2
	call malloc
	mv s3, a0

	# stack of indexes
	slli a0, s0, 2
	call malloc
	mv s4, a0

	# read args, iniialise result to -1
	li s6, 0
.parse_loop:
	bge s6, s0, .parse_done

	addi t0, s6, 1
	slli t0, t0, 3
	add t0, s1, t0
	ld a0, 0(t0)
	call atoi

	slli t1, s6, 2
	add t2, s2, t1
	sw a0, 0(t2)

	add t3, s3, t1
	li t4, -1
	sw t4, 0(t3)

	addi s6, s6, 1
	j .parse_loop

.parse_done:
	# stack stays decreasing
	li s5, -1                # top = -1
	addi s6, s0, -1          # i = n - 1

.outer_loop:
	bltz s6, .print_result

	slli t0, s6, 2
	add t0, s2, t0
	lw t1, 0(t0)             # arr[i]

.pop_loop:
	bltz s5, .after_pop

	slli t2, s5, 2
	add t2, s4, t2
	lw t3, 0(t2)             # top index

	slli t4, t3, 2
	add t4, s2, t4
	lw t5, 0(t4)             # value at top

	# Pop while top value <= current value; it can never be next-greater for i.
	ble t5, t1, .do_pop
	j .after_pop

.do_pop:
	addi s5, s5, -1
	j .pop_loop

.after_pop:
	bltz s5, .push_i

	slli t2, s5, 2
	add t2, s4, t2
	lw t3, 0(t2)             # answer for i

	slli t6, s6, 2
	add t6, s3, t6
	sw t3, 0(t6)

.push_i:
	# push i
	addi s5, s5, 1
	slli t2, s5, 2
	add t2, s4, t2
	sw s6, 0(t2)

	addi s6, s6, -1
	j .outer_loop

.print_result:
	li s6, 0
.print_loop:
	bge s6, s0, .cleanup

	slli t0, s6, 2
	add t0, s3, t0
	lw a1, 0(t0)
	la a0, fmt_int
	call printf

	# print spaces, newline at end
	addi t1, s0, -1
	beq s6, t1, .print_last_sep

	li a0, 32
	call putchar
	j .print_next

.print_last_sep:
	li a0, 10
	call putchar

.print_next:
	addi s6, s6, 1
	j .print_loop

.print_newline_only:
	# If no inputs are provided, print just a newline.
	li a0, 10
	call putchar
	j .cleanup

.cleanup:
	beqz s2, .skip_free_arr
	mv a0, s2
	call free
.skip_free_arr:

	beqz s3, .skip_free_res
	mv a0, s3
	call free
.skip_free_res:

	beqz s4, .skip_free_stk
	mv a0, s4
	call free
.skip_free_stk:

	li a0, 0
	ld s7, 24(sp)
	ld s6, 32(sp)
	ld s5, 40(sp)
	ld s4, 48(sp)
	ld s3, 56(sp)
	ld s2, 64(sp)
	ld s1, 72(sp)
	ld s0, 80(sp)
	ld ra, 88(sp)
	addi sp, sp, 96
	ret
