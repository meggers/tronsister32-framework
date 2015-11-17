.text

li $1, 0xDEAD
li $2, 0xBEEF

game_tick_interrupt:    add $v0,$v0,$at
                        ret

keyboard_interrupt:     add $v0,$v0,$at
                        ret

stack_ov_interrupt:     add $v0,$v0,$at
                        ret