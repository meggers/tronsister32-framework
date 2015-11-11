.text

                        li $1,0x0001     # $1 = 0x00000001          //24200001  
                        li $2,0x0002     # $2 = 0x00000002          //24400002
                        li $3,0x0003     # $3 = 0x00000003          //24600003
                        li $4,0x0004     # $4 = 0x00000004          //24800004
                        li $5,0x0005     # $5 = 0x00000005          //24A00005
                        add $1,$1,$1     # $1 = 0x00000002          //80210800
                        sub $6,$2,$1     # $6 = 0x00000000          //88C20800
                        beq CONT         # 00000001
                        li $1,0xFFFF     # Shouldn't happen         //2420FFFF

CONT:                   call FUNC        # call to function         //1000000D
                        sub $9,$7,$5     # $9 = 0x00000000          //89272900
                        bne FAIL         # Shouldn't happen         //04000004
                        beq PASS         # Take this branch         //00000004

FUNC:                   addi $7,$1,3     # $7 = 0x00000005          //84E10003
                        li $8,0xAAAA     # $8 = 0x000000AA          //2500AAAA
                        ret              # return                   //14000000

FAIL:                   li $3,0xFFFF     # Shouldn't happen         //2460FFFF
PASS:                   li $10,0xAAAA    # $8 = 0x000000AA          //2540AAAA

game_tick_interrupt:    add $v0,$v0,$at
keyboard_interrupt:     add $v0,$v0,$at
stack_ov_interrupt:     add $v0,$v0,$at