.data

tron: .asciiz "TRON"

.text

b end_game_instructions

# handle game tick interrupt
game_tick_interrupt: nop
    jr $epc

# handle keyboard interrupt 
keyboard_interrupt: nop
    jr $epc
                        
# handle stack overflow interrupt
stack_ov_interrupt: nop
    jr $epc

end_game_instructions: nop