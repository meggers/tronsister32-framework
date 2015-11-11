# CALLER SAVE PUSH AND POP

.text
        li $1,0x0001        # $1 = 0x00000001          //24200001
        li $2,0x0200        # $2 = 0x00000200          //24400200
        li $3,0x0000        # $3 = 0x00000000          //24600000
Repeat: add $3,$3,$1        # $3 = $3 + 1              //80630800
        sub $2,$2,$1        # $2 = $2 - 1              //88420800
        bne Repeat          #                          //07FFFFFD

#----------------------------------------------------------------------------------

        push $3             # Push $3 to stack         //38600000
        call FUNC           # call to function         //1000000C
        pop $3              # Pop top of stack into $4 //28600000
        sub $5,$3,$4        # $6 = $4 - $5             //88A32000
        beq PASS            # Take this branch         //00000005
        bne FAIL            # Shouldn't happen         //04000003

FUNC:   addi $3,$0,0xBEEF   # $7 = 0x00000005          //8460BEEF
        li $4,0x0200        # $5 = 0x00000200          //24804000
        ret                 # return from function     //14000008

FAIL:   li $10,0xFFFF       # Shouldn't happen         //2540FFFF
PASS:   li $10,0xAAAA       # $8 = 0x0000AAAA          //2540AAAA

game_tick_interrupt:    add $v0,$v0,$at
keyboard_interrupt:     add $v0,$v0,$at
stack_ov_interrupt:     add $v0,$v0,$at