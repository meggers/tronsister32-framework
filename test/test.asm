##############################################
#                                            #
#   This is a test assembly program.         #
#   It is only meant to test the assembler   #
#   Do not run this program                  #
#   Please                                   #
#                                            #
##############################################
#                                            #
#   Data Section                             #
#                                            #
##############################################
                                             
test:       .byte 7
poop:       .word 86
another:    .space 10
omg:        .asciiz "pooperdooper"

##############################################
#                                            #
#   Start Instructions                       #
#                                            #
##############################################

.text

lookie:     add $v0,$v0,$at
            sub $a0,$at,$at

iam:        addi $at,$at,10

thatare:    andi $at,$at,0xFF

##############################################
#                                            #
#   Interrupts Section                       #
#                                            #
##############################################

# handle game tick interrupt
game_tick_interrupt:    add $v0,$v0,$at

# handle keyboard interrupt 
keyboard_interrupt:     add $v0,$v0,$at
                        add $v0,$v0,$at

# handle stack overflow interrupt
stack_ov_interrupt:     add $v0,$v0,$at

##############################################
#                                            #
#   End Instructions                         #
#                                            #
##############################################