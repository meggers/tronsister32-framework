	
.text

	li $1,0x01        # $1 = 0x00000001            //24200001    
	li $2,0x02        # $2 = 0x00000002            //24400002
	li $3,0x03        # $3 = 0x00000003            //24600003
	li $4,0x04        # $4 = 0x00000004            //24800004
	li $5,0x05        # $5 = 0x00000005            //24A00005

	sw $2,$0,0x400    # M[0x400] = 0x00000002
	add $2,$5,$5        # $2 = 0x0000000A    
	lw $2,$0,0x400    # $2 = 0x00000002
	sub $6,$5,$2        # $6 = 0x00000003
	sub $7,$6,$3        # $7 = 0x00000000
	beq PASS

FAIL:    li $10,0xFFFF
PASS:    li $10,0xAAAA

# handle game tick interrupt
game_tick_interrupt:    add $v0,$v0,$at

# handle keyboard interrupt 
keyboard_interrupt:     add $v0,$v0,$at

# handle stack overflow interrupt
stack_ov_interrupt:     add $v0,$v0,$at
