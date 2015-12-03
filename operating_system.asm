.data

x_mask: .word 0xFF000000
y_mask: .word 0x000000FF
sprite_index_mask: .word 0x00FF0000

oam_copy: .space 64

.text

#####################################
#                                   #
# FUNCTION: load_sprite_img         #
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
load_sprite_img:                    #
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

#####################################
#
# 
#
#####################################
load_single_sprite:                 #
    pop $t0                         # pop oam index
    pop $t1                         # pop sprite index
                                    #
    sft $t0,$t1                     # store in real oam
                                    #
    lw $t3,$zero,sprite_index_mask  # load sprite index mask
    sll $t1,$t1,24                  # shift index to correct spot
    and $t1,$t1,$t3                 # mask off index
    sw $t1,$at,0                    # store index at spot in memory
    addi $at,$at,1                  # increment free oam spot in memory
    ret                             #
                                    #
#####################################

# handle game tick interrupt
game_tick_interrupt:    add $v0,$v0,$at

# handle keyboard interrupt 
keyboard_interrupt:     add $v0,$v0,$at
                        
# handle stack overflow interrupt
stack_ov_interrupt:     add $v0,$v0,$at