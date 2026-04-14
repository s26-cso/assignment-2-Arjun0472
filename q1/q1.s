.text

# val at +0 (4 bytes for int), left at +8, right at +16, total 24 bytes.

.globl make_node
make_node:
	# Save ra because we call malloc; save val since a0 is reused.
	addi sp, sp, -16
	sd ra, 8(sp)
	sw a0, 0(sp)

	# Allocate one Node.
	li a0, 24
	call malloc

	# Initialize fields: val, left=NULL, right=NULL.
	lw t0, 0(sp)
	sw t0, 0(a0)
	sd zero, 8(a0)
	sd zero, 16(a0)

.done:
	# Return pointer in a0
	ld ra, 8(sp)
	addi sp, sp, 16
	ret

.globl insert
insert:
	# Save s0/s1 because they hold root and key across nested calls.
	addi sp, sp, -32
	sd ra, 24(sp)
	sd s0, 16(sp)
	sd s1, 8(sp)

	mv s0, a0
	mv s1, a1

	# Base case: empty subtree, allocate node here.
	beqz s0, .new_root

	# BST rule decides which subtree can contain the key.
	lw t0, 0(s0)
	blt s1, t0, .go_left
	blt t0, s1, .go_right

	# Equal key case: tree unchanged.
	mv a0, s0
	j .end

.go_left:
	# Rebuild left link from recursive return, then return original root.
	ld a0, 8(s0)
	mv a1, s1
	call insert
	sd a0, 8(s0)
	mv a0, s0
	j .end

.go_right:
	# Symmetric right-subtree case.
	ld a0, 16(s0)
	mv a1, s1
	call insert
	sd a0, 16(s0)
	mv a0, s0
	j .end

.new_root:
	# First node at this position.
	mv a0, s1
	call make_node

.end:
	ld s1, 8(sp)
	ld s0, 16(sp)
	ld ra, 24(sp)
	addi sp, sp, 32
	ret

.globl get
get:
	# Save ra because this function can call itself.
	addi sp, sp, -16
	sd ra, 8(sp)

	# Base case: null subtree.
	beqz a0, .get_not_found

	lw t0, 0(a0)
	blt a1, t0, .get_left
	blt t0, a1, .get_right
	j .get_done

.get_left:
	ld a0, 8(a0)
	call get
	j .get_done

.get_right:
	ld a0, 16(a0)
	call get
	j .get_done

.get_not_found:
	mv a0, zero

.get_done:
	ld ra, 8(sp)
	addi sp, sp, 16
	ret

.globl getAtMost
getAtMost:
	# -1 means no valid candidate has been seen yet.
	addi sp, sp, -16
	sd ra, 8(sp)
	li a2, -1
	call .gatm_rec
	ld ra, 8(sp)
	addi sp, sp, 16
	ret

# a0 = target, a1 = node, a2 = best candidate so far
# returns best candidate in a0
.gatm_rec:
	addi sp, sp, -16
	sd ra, 8(sp)

	beqz a1, .gatm_base

	lw t0, 0(a1)
	blt a0, t0, .gatm_left

	# Current value is valid; try right for a larger valid value.
	mv a2, t0
	ld a1, 16(a1)
	call .gatm_rec
	j .gatm_done

.gatm_left:
	ld a1, 8(a1)
	call .gatm_rec
	j .gatm_done

.gatm_base:
	mv a0, a2

.gatm_done:
	ld ra, 8(sp)
	addi sp, sp, 16
	ret
