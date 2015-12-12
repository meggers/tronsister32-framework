.data 
    poop: .word 0xDEADBEEF

.text
    li $1,0x0001    
    li $2,0x0002    
    li $3,0x0003        
    li $4,0x0004
    li $5,0x0005
    li $6,0x0006
    push $1
    push $2
    push $3 
    push $4
    push $5
    push $6 
    call FUNC       
    pop $3          
    pop $2
    pop $1  
    b END                              
FUNC:   pop $6
    pop $5
    pop $4
    li $1,0xBEEF       
    li $2,0xCAFE       
    li $3,0xF00D   
    push $1
    push $2
    push $6
    ret                         
END: li $4,0xAAAA
# handle game tick interrupt
game_tick_interrupt: nop
    jr $epc
# handle keyboard interrupt 
keyboard_interrupt: nop
    jr $epc
                        
# handle stack overflow interrupt
stack_ov_interrupt: nop
    jr $epc