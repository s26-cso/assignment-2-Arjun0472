.section .rodata
input_path:
	.asciz "input.txt"
read_mode:
	.asciz "r"
yes_str:
	.asciz "Yes"
no_str:
	.asciz "No"

.text
.globl main
main:
	# Save the registers we keep across libc calls.
	addi sp, sp, -96
	sd ra, 88(sp)
	sd s0, 80(sp)
	sd s1, 72(sp)
	sd s2, 64(sp)
	sd s3, 56(sp)

	# Open input.txt for reading.
	la a0, input_path
	la a1, read_mode
	call fopen
	mv s0, a0
	beqz s0, .print_no

	# Jump to the end so ftell gives us the file length.
	mv a0, s0
	li a1, 0
	li a2, 2
	call fseek

	mv a0, s0
	call ftell
	mv s1, a0

	# Go back to the start before we begin comparing characters.
	mv a0, s0
	li a1, 0
	li a2, 0
	call fseek

	# Only need to compare the first half against the mirrored half.
	srli s3, s1, 1
	li s2, 0

.loop:
	bge s2, s3, .print_yes

	# Read the character at position i.
	mv a0, s0
	mv a1, s2
	li a2, 0
	call fseek
	mv a0, s0
	call fgetc
	mv t0, a0

	# Read the matching character from the other end.
	addi t1, s1, -1
	sub t1, t1, s2
	mv a0, s0
	mv a1, t1
	li a2, 0
	call fseek
	mv a0, s0
	call fgetc
	mv t2, a0

	# One mismatch is enough to stop.
	bne t0, t2, .print_no

	addi s2, s2, 1
	j .loop

.print_yes:
	la a0, yes_str
	call puts
	j .cleanup

.print_no:
	la a0, no_str
	call puts

.cleanup:
	beqz s0, .done
	mv a0, s0
	call fclose

.done:
	ld s3, 56(sp)
	ld s2, 64(sp)
	ld s1, 72(sp)
	ld s0, 80(sp)
	ld ra, 88(sp)
	addi sp, sp, 96
	li a0, 0
	ret
