.data 

sprite_at_topleft: .word 0x01000001

.text

li $t0,1
li $t1,2
li $t2,0xA3
lw $t3,$0,sprite_at_topleft
li $t4,0x0202

sld $0,$3
ssl $0,$t4
sft $0,$t0
sfa $0,$t2
srm $0

sbt $0,$t0
sba $0,$t2

main_loop: nop
    b main_loop
    
# handle game tick interrupt
game_tick_interrupt: nop
    jr $epc

# handle keyboard interrupt 
keyboard_interrupt: nop
    jr $epc
                        
# handle stack overflow interrupt
stack_ov_interrupt: nop
    jr $epc