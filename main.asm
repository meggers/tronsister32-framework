.text
li $1,0x0001       
li $2,0x0002       
li $3,0x0003
li $4,0x0004       
li $5,0x0002       
li $6,0x0003   
li $7,0x0001       
li $8,0x0002       
li $9,0x0003       
li $10,0x0001      
li $11,0x0002      
li $12,0x0003      
li $13,0x0001      
li $14,0x0002      
li $15,0x0003
li $16,0x0001      
li $17,0x0002      
li $18,0x0003
li $19,0x0004      
li $20,0x0002      
li $21,0x0003  
li $22,0x0001      
li $23,0x0002      
li $24,0x0003      
li $25,0x0001      
li $26,0x0002
li $8,$zero
nop 
andi $24,$1,-3
add $5,$6,$24
sw $15,$12,5
sw $14,$19,-3
sub $6,$11,$19        
addi $22,$5,4
bne 4
nop 
and $23,$2,$28
andi $18,$23,2
push $6


# handle game tick interrupt
game_tick_interrupt: nop
   jr $epc

# handle keyboard interrupt
keyboard_interrupt: nop
   jr $epc
                       
# handle stack overflow interrupt
stack_ov_interrupt: nop
   jr $epc