.text

li $1,0x01	  # $1 = 0x00000001			//24200001	
li $2,0x02	  # $2 = 0x00000002			//24400002
li $3,0x03	  # $3 = 0x00000003			//24600003
li $4,0x04	  # $4 = 0x00000004			//24800004
li $5,0x05	  # $5 = 0x00000005			//24A00005
add $6,$1,$2	  # $6 = 0x00000003			//80C11000
addi $7,$5,0x04	  # $7 = 0x00000009			//84E50004
and $8,$2,$3	  # $8 = 0x00000002			//91021800
andi $9,$8,0xFFFF # $9 = 0x00000002 (hazard detect)	//9528FFFF
nand $10,$6,$7	  # $10 = 0xFFFFFFFE			//8D463800
xor $11,$6,$7	  # $11 = 0x0000000A			//A1663800
sll $12,$11,3	  # $12 = 0x00000050 (hazard detect)	//9D8B00C0
srl $13,$11,2	  # $13 = 0x00000002			//99AB0080
sw $10,$1,0x01	  # M[0x00000002] = 0xFFFFFFFE		//31410001
lw $14,$1,0x01	  # $14 = 0xFFFFFFFE			//21C10001

game_tick_interrupt:    add $v0,$v0,$at
keyboard_interrupt:     add $v0,$v0,$at
stack_ov_interrupt:     add $v0,$v0,$at
