.text
    li $1,0x0001    
    li $2,0x0002    
    li $3,0x0003        
    li $4,0x0004
    li $5,0x0005
    li $6,0x0006
    li $7,0x0007
    li $8,0x0008
    li $9,0x0009
    add $2,$5,$5
    sub $5,$4,$1
    call FUCK
    addi $9,$2,3          # increment current oam slot
FUCK: nop
    push $2
    push $5
    push $3
    li $1,0xBEEF       
    li $2,0xCAFE
    pop $16
    pop $15
    pop $14
    ret
    
# handle game tick interrupt
game_tick_interrupt: nop
    jr $epc

# handle keyboard interrupt 
keyboard_interrupt: nop
    jr $epc
                        
# handle stack overflow interrupt
stack_ov_interrupt: nop
    jr $epc