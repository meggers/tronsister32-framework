# CALLER SAVE PUSH AND POP

.text

            li $1,0x0001        # $1 = 0x00000001            //24200001
            li $2,0x0200        # $2 = 0x00000200            //24400200
            li $3,0x0000        # $3 = 0x00000000            //24600000
Repeat:     add $3,$3,$1        # $3 = $3 + 1                //80630800
            sub $2,$2,$1        # $2 = $2 - 1                //88420800
            bne Repeat          #                  //07FFFFFD

            push $3             # Top of Stack = $3
            call FUNC           # call to func    
            pop $3              # $3 = Top of Stack            
            sub $5,$3,$4        # $5 = $3 - $4                
            beq PASS            # Take this branch            
            bne FAIL            # Shouldn't happen            

FUNC:       li $3,0xBEEF        # $3 = 0x0000BEEF        
            li $4,0x0200        # $4 = 0x00000200            
            ret                 # return from func                
            
FAIL:       li $10,0xFFFF       # $10 = 0x0000FFFF            //2540FFFF
PASS:       li $10,0xAAAA       # $10 = 0x0000AAAA            //2540AAAA

# handle game tick interrupt
game_tick_interrupt:    add $v0,$v0,$at

# handle keyboard interrupt 
keyboard_interrupt:     add $v0,$v0,$at
                        add $v0,$v0,$at

# handle stack overflow interrupt
stack_ov_interrupt:     add $v0,$v0,$at