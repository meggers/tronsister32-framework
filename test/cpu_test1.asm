
	#.data starts at 0x400
alla: .word 0xAAAAAAAA
allb: .word 0xBBBBBBBB
allc: .word 0xCCCCCCCC
alld: .word 0xDDDDDDDD
alle: .word 0xEEEEEEEE
allf: .word 0xFFFFFFFF
all5: .word 0x55555555


.text
	# Test the basic ALU ops
test1: 	li $t0,1
		li $t1,2
		# "andi" and "and"
		addi $t0,$zero,0x7777
		addi $t1,$zero,0x0888
		add  $t2,$t1,$t0
		# t2 should contain 0x7FFF

	
		# clear #t0-3
		and $t0,$t0,$zero
		and $t1,$t1,$zero
		and $t2,$t2,$zero

		# "nand"
		addi $t0,$zero,0xAA
		addi $t1,$zero,0xCC
		nand  $t2,$t1,$t0
		# $t2 should contain 0x777

		# "sub" and "sll"
		and $t0,$t0,$zero
		and $t1,$t1,$zero
		addi $t0,$t0,1
		sll $t1,$t0,30
		sub $t2,$t1,$t0

		
		# "push" and "pop" (and "lw")
		# store all As in $t1. Beautiful and hacky
		addi $t0,$zero,0x400
		lw $t1,$t0
		push $t1
	
		# store all Bs in $t2
		addi $t0,$t0,4
		lw $t2,$t0
		push $t2
		
		# store all Cs in $t3
		addi $t0,$t0,4
		lw $t3,$t0
		push $t3
		
		# store all Ds in $t4
		addi $t0,$t0,4
		lw $t4,$t0
		push $t4
		
		# store all Es in $t5
		addi $t0,$t0,4
		lw $t5,$t0
		push $t5	
		
		# store all Fs in $t6
		addi $t0,$t0,4
		lw $t6,$t0
		push $t6
	
		# Reverse the order of the contents of the registers
		pop $t1
		pop $t2
		pop $t3
		pop $t4
		pop $t5
		pop $t6
		
		# clear registers
		and $t0,$t0,$zero
		and $t1,$t1,$zero
		and $t2,$t2,$zero
		and $t3,$t3,$zero
		and $t4,$t4,$zero
		and $t5,$t5,$zero
		and $t6,$t6,$zero
	
		addi $t1,$zero,1
beq_t:	addi $t2,$t2,1
		beq $t1,$t2,beq_t

		addi $t2,$t2,2
bne_t:	sub $t2,$t2,$t1
		bne $t1,$t2,bne_t
	
		addi $t2,$t2,2
blt_t:	sub $t2,$t2,$t1
		blt $t1,$t2,blt_t

end:	addi $t0,$zero,0x414
		lw $a0,$t0
		addi $t2,$zero,0x420
		sw $a0,$t2
		add $t2,$t2,4
		sw $a0,$t2
		add $t2,$t2,4
		sw $a0,$t2

game_tick_interrupt:    add $v0,$v0,$at
keyboard_interrupt:     add $v0,$v0,$at
stack_ov_interrupt:     add $v0,$v0,$at