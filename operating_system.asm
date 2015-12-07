.data

x_mask:             .word 0xFF000000
sprite_index_mask:  .word 0x00FF0000
vertical_flip_mask: .word 0x00008000
horiz_flip_mask:    .word 0x00004000
color_palette_mask: .word 0x00000300
y_mask:             .word 0x000000FF

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
#   $a3: Starting Attr              #
#    (in Sprite Register Layout)    #
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

# get_x: Gets X value from sprite register layout data
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#
# Returns:
#   $v0 - x value
#
get_x:
    lw $v0,x_mask
    and $v0,$a0,$v0
    srl $v0,$v0,24
    ret

# set_x: Sets x value in sprite register layout data
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#   $a1 - x data to set (lsb 8 bits)
#
# Returns:
#   $v0 - SRL data with new x
#
set_x:
    lw $t0,x_mask
    nand $t0,$t0,$t0
    and $v0,$a0,$t0
    sll $a1,$a1,24
    xor $v0,$v0,$a1
    ret

###############################################


# handle game tick interrupt
game_tick_interrupt:    add $v0,$v0,$at

# handle keyboard interrupt 
keyboard_interrupt:     add $v0,$v0,$at
                        
# handle stack overflow interrupt
stack_ov_interrupt:     add $v0,$v0,$at