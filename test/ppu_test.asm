.data

x_mask: .word 0xFF000000
y_mask: .word 0x000000FF

oam_copy: .space 64

.text

li $a0,middle_finger_index
li $a1,middle_finger_height
li $a2,middle_finger_width
li $a3,0
call load_sprite

#####################################
#                                   #
# FUNCTION: load_sprite             #
#                                   #
# DEFN: load sprite into oam        #
#                                   #
# ARGUMENTS:                        #
#   $a0: sprite index               #
#   $a1: sprite height              #
#   $a2: sprite width               #
#   $a3: start oam index            #
#                                   #
#####################################
load_sprite:                        #
    li $t0,0                        # $t0 = 0 ; outer loop index (height)
    li $t1,0                        # $t1 = 0 ; inner loop index (width)
    li $t3,0                        # cur_sprite = 0
                                    #
    load_sprite_oloop:              #
        sub $zero,$t0,$a1           #
        beq load_sprite_return      #
                                    #
        load_sprite_iloop:          #
            sub $zero,$t1,$a2       #
            beq rst_sprite_iloop    #
                                    #            
            add $t2,$a0,$t3         # $t2 = sprite index + loop index
            sft $a3,$t2             # set sprite index in oam
            addi $t3,1              # $t0 += 1 ; Increment loop index
            addi $a3,1              # $a3 += 1 ; Increment oam index
                                    #
            addi $t1,1              # increment inner loop index
            b load_sprite_iloop     #
                                    #
        rst_sprite_iloop:           #
            li $t1,0                # reset inner loop index
            addi $t0,1              # increment outer loop index
            b load_sprite_oloop     # 
                                    #
    load_sprite_return:             #
        ret                         #
#####################################

# handle game tick interrupt
game_tick_interrupt:    add $v0,$v0,$at

# handle keyboard interrupt 
keyboard_interrupt:     add $v0,$v0,$at
                        
# handle stack overflow interrupt
stack_ov_interrupt:     add $v0,$v0,$at