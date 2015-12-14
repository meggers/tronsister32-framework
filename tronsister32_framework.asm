 ########################################################################################################################
#  _____                   _     _            _____  _____       ______                                           _      #
# |_   _|                 (_)   | |          |____ |/ __  \      |  ___|                                         | |     #
#   | |_ __ ___  _ __  ___ _ ___| |_ ___  _ __   / /`' / /'______| |_ _ __ __ _ _ __ ___   _____      _____  _ __| | __  #
#   | | '__/ _ \| '_ \/ __| / __| __/ _ \| '__|  \ \  / / |______|  _| '__/ _` | '_ ` _ \ / _ \ \ /\ / / _ \| '__| |/ /  #
#   | | | | (_) | | | \__ \ \__ \ || (_) | | .___/ /./ /___      | | | | | (_| | | | | | |  __/\ V  V / (_) | |  |   <   #
#   \_/_|  \___/|_| |_|___/_|___/\__\___/|_| \____/ \_____/      \_| |_|  \__,_|_| |_| |_|\___| \_/\_/ \___/|_|  |_|\_\  #
#                                                                                                                        #
##########################################################################################################################
#                                                                                                                        #
# Description:                                                                                                           #
#   Core functions and data for Tronsister-32 games. Sorry. You're not gonna have fun with this.                         #
#                                                                                                                        #
##########################################################################################################################
#                                                                                                                        #
# Info:                                                                                                                  #
#   ascii art @ http://patorjk.com/software/taag/ "Doom"                                                                 #
#                                                                                                                        #
##########################################################################################################################

.data

x_mask:             .word 0xFF000000
sprite_index_mask:  .word 0x0000FF00
vertical_flip_mask: .word 0x00800000
horiz_flip_mask:    .word 0x00400000
color_palette_mask: .word 0x00030000
y_mask:             .word 0x000000FF
clear_sprite:       .word 0xFFFFFFFF

TRUE:               .word 0xFFFFFFFF
FALSE:              .word 0x00000000

oam_copy: .space 64

.text

nop # for graham
b game_instructions

#####################################
#                                   #
# Function: draw_number             #
#                                   #
# Arguments: draw_number            #
#   $a0: number to draw             #
#   $a1: background position        #
#                                   #
# Return:                           #
#   N/A                             #
#                                   #
#####################################
draw_number: nop                    #
    push $t0                        #
                                    #
    addi $0,$a0,0                   #
    beq dn_0                        #
                                    #
    addi $0,$a0,-1                  #
    beq dn_1                        #
                                    #
    addi $0,$a0,-2                  #
    beq dn_2                        #
                                    #
    addi $0,$a0,-3                  #
    beq dn_3                        #
                                    #
    addi $0,$a0,-4                  #
    beq dn_4                        #
                                    #
    addi $0,$a0,-5                  #
    beq dn_5                        #
                                    #
    addi $0,$a0,-6                  #
    beq dn_6                        #
                                    #
    addi $0,$a0,-7                  #
    beq dn_7                        #
                                    #
    addi $0,$a0,-8                  #
    beq dn_8                        #
                                    #
    addi $0,$a0,-9                  #
    beq dn_9                        #
                                    #
    dn_0: nop                       #
        li $t0,char_0_index         #
        b draw_number_return        #
    dn_1: nop                       #
        li $t0,char_1_index         #
        b draw_number_return        #
    dn_2: nop                       #
        li $t0,char_2_index         #
        b draw_number_return        #
    dn_3: nop                       #
        li $t0,char_3_index         #
        b draw_number_return        #
    dn_4: nop                       #
        li $t0,char_4_index         #
        b draw_number_return        #
    dn_5: nop                       #
        li $t0,char_5_index         #
        b draw_number_return        #
    dn_6: nop                       #
        li $t0,char_6_index         #
        b draw_number_return        #
    dn_7: nop                       #
        li $t0,char_7_index         #
        b draw_number_return        #
    dn_8: nop                       #
        li $t0,char_8_index         #
        b draw_number_return        #
    dn_9: nop                       #
        li $t0,char_9_index         #
        b draw_number_return        #
                                    #
    draw_number_return: nop         #
        sbt $a1,$t0                 #
        pop $t0                     #
        ret                         #
#####################################

#####################################
#                                   #
# Function: display_2digit_decimal  #
#                                   #
# Arguments:                        #
#   $a0: number to display          #
#   $a1: bg position to display at  #
#                                   #
# Return:                           #
#   N/A                             #
#                                   #
#####################################
display_2digit_decimal: nop         #
                                    #
    li $t0,0                        # t0 = tens digit (init 0)
    li $t1,10                       # t1 = down counter (10)
                                    #
    d2dd_loop: nop                  #
        sub $0,$a0,$t1              # if remainder is < 10, breadk from loop
        blt d2dd_return             #
                                    #
        sub $a0,$a0,$t1             # remainder = remainder - down counter
        addi $t0,$t0,1              # increment tens digit
        b d2dd_loop                 #
                                    #
    d2dd_return: nop                #
        add $t1,$0,$a0              # grab remainder
                                    #
        add $a0,$0,$t0              # pass tens digit
        call draw_number            #
                                    #
        add $a0,$0,$t1              # pass ones digit
        addi $a1,$a1,1              # increment bg position
        call draw_number            #
                                    #
        nop                         # avoid hazard
                                    #
        ret                         #
#####################################

#####################################
#                                   #
# Function: check_oob               #
#                                   #
# Arguments:                        #
#   0(sf): left sprite x pos        #
#   1(sf): top sprite y pos         #
#   2(sf): sprite width             #
#   3(sf): sprite height            #
#                                   #
# Return:                           #
#   $v0: 0000 if not oob            #
#        0001 if top                #
#        0010 if right              #
#        0100 if bottom             #
#        1000 if left               #
#        0011 if top right          #
#        1001 if top left           #
#        0110 if bottom right       #
#        1100 if bottom left        #
#                                   #
#####################################
check_oob: nop                      #
    pop $ra                         #
    pop $t0                         # t0 = sprite height
    pop $t1                         # t1 = sprite width
    pop $t2                         # t2 = top sprite y pos
    pop $t3                         # t3 = left sprite x pos
                                    #
    li $v0,0                        # zero out return value
    sll $t0,$t0,3                   # sprite height -> pixel height
    sll $t1,$t1,3                   # sprite width -> pixel width
                                    #
    oob_check_top: nop              # check if sprite extends over top
        li $t5,6                    #
        sub $0,$t5,$t2              # 
        blt oob_check_bottom        #
                                    #
        li $t4,1                    #
        xor $v0,$v0,$t4             #
                                    #
    oob_check_bottom: nop           # check if sprite extends over bottom
        add $t4,$t2,$t0             #
        li $t5,250                  #
        sub $0,$t4,$t5              #
        blt oob_check_left          #
                                    #
        li $t4,4                    #
        xor $v0,$v0,$t4             #
                                    #
    oob_check_left: nop             # check if sprite extends over left
        li $t5,6                    #
        sub $0,$t5,$t3              #
        blt oob_check_right         #
                                    #
        li $t4,8                    #
        xor $v0,$v0,$t4             #
                                    #
    oob_check_right: nop            # check if sprite extends over right
        add $t4,$t3,$t1             #
        li $t5,250                  #
        sub $0,$t4,$t5              #
        blt check_oob_return        #
                                    #
        li $t4,2                    #
        xor $v0,$v0,$t4             #
                                    #
    check_oob_return: nop           #
        push $ra                    #
        ret                         #
#####################################

#####################################
#                                   #
# Function: negate                  #
#                                   #
# Arguments:                        #
#   $a0: number to negate           #
#                                   #
# Return:                           #
#   $v0: negates number             #
#                                   #
#####################################
negate: nop                         #
    nand $a0,$a0,$a0                #
    addi $v0,$a0,1                   #
    ret                             #
#####################################

#####################################
#                                   #
# Function: check_collision         #
#                                   #
# Arguments:                        #
#   0(sf): sprite a start oam data  #
#   1(sf): sprite b start oam data  #
#   2(sf): height a                 #
#   3(sf): height b                 #
#   4(sf): width a                  #
#   5(sf): width b                  #
#                                   #
# Return:                           #
#   $v0: TRUE if collision          #
#        FALSE if no collision      #
#                                   #
#####################################
check_collision: nop                #
    pop $ra                         #
    pop $t0                         # $t0 = sprite a start oam data
    pop $t1                         # $t1 = sprite b start oam data
    pop $t2                         # $t2 = height a
    pop $t3                         # $t3 = height b
    pop $t4                         # $t4 = width a
    pop $t5                         # $t5 = width b
                                    #
    sll $t2,$t2,3                   # turn sprite sizes to pixel sizes
    sll $t3,$t3,3                   #
    sll $t4,$t4,3                   #
    sll $t5,$t5,3                   #
                                    #
    add $a0,$0,$t0                  #
    call get_x                      #
    add $t6,$0,$v0                  # $t6 = left of sprite a
                                    #
    add $a0,$0,$t0                  #
    call get_y                      #
    add $t7,$0,$v0                  # $t7 = top of sprite a
                                    #
    add $a0,$0,$t1                  #
    call get_x                      #
    add $t8,$0,$v0                  # $t8 = left of sprite b
                                    #
    add $a0,$0,$t1                  #
    call get_y                      #
    add $t9,$0,$v0                  # $t9 = top of sprite b
                                    #
    add $t0,$t6,$t4                 # if ax + aw < bx then no intersection       
    sub $0,$t0,$t8                  #
    blt cc_return_false             #
                                    #
    add $t0,$t8,$t5                 # if bx + bw < ax then no intersection
    sub $0,$t0,$t6                  #
    blt cc_return_false             #
                                    #
    add $t0,$t7,$t2                 # if ay + ah < by then no intersection
    sub $0,$t0,$t9                  #
    blt cc_return_false             #
                                    #
    add $t0,$t9,$t3                 # if by + bh < ay then no intersection
    sub $0,$t0,$t7                  #
    blt cc_return_false             #
                                    #
    cc_return_true: nop             # otherwise, intersection
        lw $v0,$0,TRUE              #
        b cc_return                 #
                                    #
    cc_return_false: nop            #
        lw $v0,$0,FALSE             #
        b cc_return                 #
                                    #
    cc_return: nop                  #
        push $ra                    #
        ret                         #
#####################################

#####################################
#                                   #
# Function: move_sprite_img         #
#                                   #
# Defn: move sprite by specified    #
#   number of pixels.               #
#                                   #
# Arguments:                        #
#   0(sf): starting oam slot        #
#   1(sf): sprite_size              #
#   2(sf): x delta                  #
#   3(sf): y delta                  #
#                                   #
# Returns:                          #
#   0(sf) - top                     #
#   1(sf) - bottom                  #
#   2(sf) - left                    #
#   3(sf) - right                   #
#                                   #
#####################################
move_sprite_img: nop                #
    pop $ra                         #
    pop $t0                         # t0 = starting oam slot
    pop $t4                         # t4 = sprite size
    pop $t1                         # t1 = delta x
    pop $t2                         # t2 = delta y
                                    #
    li $t3,oam_copy                 # t3 = oam mem_copy start location in memory
    add $t3,$t3,$t0                 # t3 = mem_oam start + oam offset
    lw $t6,$t3,0                    # t6 = data at t3
                                    #
    add $t5,$0,$0                   # initialize loop var to 0
                                    #
    move_sprite_img_loop: nop       #
        sub $0,$t4,$t5              #
        beq move_sprite_img_ret     #
        blt move_sprite_img_ret     #
                                    #
        add $a0,$0,$t6              # pass sprite data as argument
        call get_x                  # grab x
                                    #
        add $a0,$0,$t6              # pass sprite data as argument
        add $a1,$t1,$v0             # pass x + delta_x as offset
        call set_x                  # 
        add $t6,$0,$v0              #
                                    #
        add $a0,$0,$v0              # pass sprite data as argument
        call get_y                  # grab y
                                    #
        add $a0,$0,$t6              # pass sprite data as argument
        add $a1,$t2,$v0             # pass y + delta_y as offset
        call set_y                  # get resulting sprite data
                                    #
        sld $t0,$v0                 # store data in oam
        sw $v0,$t3,0                # store data in memory
                                    #
        addi $t3,$t3,1              # increment oam index 
        addi $t0,$t0,1              # increment mem_oam index
                                    #
        addi $0,$t3,-64             # check if we overflow oam
        beq move_sprite_img_ret     # if we do jump to end
                                    #
        lw $t6,$t3,0                # if we don't then get sprite data
                                    #
        addi $t5,$t5,1              # increment sprite index
        b move_sprite_img_loop      # 
                                    #
    move_sprite_img_ret: nop        #
        push $ra                    #
        ret                         #
#####################################

#####################################
#                                   #
# Function: load_sprite_img         #
#                                   #
# Defn: load sprite into oam        #
#                                   #
# Arguments:                        #
#   0(sf): sprite index             #
#   1(sf): sprite height            #
#   2(sf): sprite width             #
#   3(sf): left x (8 lsb)           #
#   4(sf): top y (8 lsb)            #
#   5(sf): starting oam slot        #
#                                   #
# Returns:                          #
#   $v0 - next free oam slot        #
#                                   #
#####################################
load_sprite_img: nop                #
    pop $ra                         #
    pop $t0                         # t0 = sprite index
    pop $t1                         # t1 = sprite height
    pop $t2                         # t2 = sprite width
    pop $t3                         # t3 = left coordinate (x)
    pop $t4                         # t4 = top coordinate (y)
    pop $t5                         # t5 = starting oam slot
                                    #
    li $t6,0                        # t6 = 0 ; outer loop index (height)
    li $t7,0                        # t7 = 0 ; inner loop index (width)
    add $t8,$zero,$t0               # t8 = t0 ; current sprite index
                                    #
    li $t9,oam_copy                 # get oam mem_copy start location in memory
    add $t9,$t9,$t5                 # increment mem oam index to starting index
                                    #
    lw $t10,$0,clear_sprite         # initialize sprite register data to all Fs
                                    #
    load_sprite_oloop: nop          #
        sub $zero,$t1,$t6           #
        beq load_sprite_return      #
                                    #
        load_sprite_iloop: nop      #
            sub $zero,$t2,$t7       #
            beq rst_sprite_iloop    #
                                    #
            add $a0,$zero,$t10      # set current sprite data into first argument
            add $a1,$zero,$t8       # set current sprite index number into second argument
            call set_tile_no        #
                                    #
            add $a0,$zero,$v0       # set current sprite data into first argument
            add $a1,$zero,$t7       # get current inner loop (width) index
            sll $a1,$a1,3           # multiple index by 8 to get x offset
            add $a1,$a1,$t3         # add x offset to initial left coordinate as second argument
            call set_x              #
                                    #
            add $a0,$zero,$v0       # set current sprite data into first argument
            add $a1,$zero,$t6       # get current outer loop (height) index
            sll $a1,$a1,3           # multiply index by 8 to get y offset
            add $a1,$a1,$t4         # add y offset to initial top coordinate as second argument
            call set_y              #
                                    #
            add $t10,$zero,$v0      # get chained results from above functions
            sld $t5,$t10            # load the sprite data to oam
            sw $t10,$t9,0           # load the sprite data to mem oam
                                    #
            addi $t5,$t5,1          # increment current oam slot
            addi $t9,$t9,1          # increment current mem oam slot
            addi $t8,$t8,1          # increment current sprite index
            addi $t7,$t7,1          # increment inner loop index
            b load_sprite_iloop     #
                                    #
        rst_sprite_iloop: nop       #
            li $t7,0                # reset inner loop index
            addi $t6,$t6,1          # increment outer loop index
            b load_sprite_oloop     # 
                                    #
    load_sprite_return: nop         #
        add $v0,$0,$t5              #
        push $ra                    #
        ret                         #
#####################################

##########################################################################################################################
#   _____            _ _        ______           _     _                                                                 #
#  /  ___|          (_) |       | ___ \         (_)   | |                                                                #
#  \ `--. _ __  _ __ _| |_ ___  | |_/ /___  __ _ _ ___| |_ ___ _ __                                                      #
#   `--. \ '_ \| '__| | __/ _ \ |    // _ \/ _` | / __| __/ _ \ '__|                                                     #
#  /\__/ / |_) | |  | | ||  __/ | |\ \  __/ (_| | \__ \ ||  __/ |                                                        #
#  \____/| .__/|_|  |_|\__\___| \_| \_\___|\__, |_|___/\__\___|_|                                                        #
#        | |                                __/ |                                                                        #
#        |_|                               |___/                                                                         #
#   _____      _   _                                  _   _____      _   _                                               #
#  |  __ \    | | | |                                | | /  ___|    | | | |                                              #
#  | |  \/ ___| |_| |_ ___ _ __ ___    __ _ _ __   __| | \ `--.  ___| |_| |_ ___ _ __ ___                                #
#  | | __ / _ \ __| __/ _ \ '__/ __|  / _` | '_ \ / _` |  `--. \/ _ \ __| __/ _ \ '__/ __|                               #
#  | |_\ \  __/ |_| ||  __/ |  \__ \ | (_| | | | | (_| | /\__/ /  __/ |_| ||  __/ |  \__ \                               #
#   \____/\___|\__|\__\___|_|  |___/  \__,_|_| |_|\__,_| \____/ \___|\__|\__\___|_|  |___/                               #
#                                                                                                                        #
##########################################################################################################################

#######################################################
# get_x: Gets X value from sprite register layout data
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#
# Returns:
#   $v0 - x value
#
#######################################################
get_x: nop
    srl $v0,$a0,24
    ret

#####################################################
# set_x: Sets x value in sprite register layout data
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#   $a1 - x data to set (lsb 8 bits)
#
# Returns:
#   $v0 - SRL data with new x
#
#####################################################
set_x: nop
    push $t0
    lw $t0,$0,x_mask
    nand $t0,$t0,$t0
    and $v0,$a0,$t0
    sll $a1,$a1,24
    xor $v0,$v0,$a1
    pop $t0
    ret

#######################################################
# get_y: Gets Y value from sprite register layout data
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#
# Returns:
#   $v0 - y value
#
#######################################################
get_y: nop
    lw $v0,$0,y_mask
    and $v0,$a0,$v0
    ret

#####################################################
# set_x: Sets y value in sprite register layout data
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#   $a1 - y data to set (lsb 8 bits)
#
# Returns:
#   $v0 - SRL data with new y
#
#####################################################
set_y: nop
    push $t0
    push $t1
    lw $t0,$0,y_mask
    and $t1,$t0,$a1
    nand $t0,$t0,$t0
    and $v0,$a0,$t0
    xor $v0,$v0,$t1
    pop $t1
    pop $t0
    ret

#######################################################
# get_tile_no: Gets tile number from sprite register layout data
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#
# Returns:
#   $v0 - tile number
#
#######################################################
get_tile_no: nop
    push $t0
    lw $t0,$0,sprite_index_mask
    and $v0,$a0,$t0
    srl $v0,$v0,8
    pop $t0
    ret

#######################################################
# set_tile_no: Sets tile number in sprite register layout data
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#   $a1 - Tile number to set (lsb 8 bits)
#
# Returns:
#   $v0 - S.R.L. data with new tile number
#
#######################################################
set_tile_no: nop
    push $t0
    lw $t0,$0,sprite_index_mask
    nand $t0,$t0,$t0
    and $v0,$t0,$a0
    sll $a1,$a1,8
    xor $v0,$v0,$a1
    pop $t0
    ret

#######################################################
# get_v_flip: Gets vertical flip from s.r.l.d.
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#
# Returns:
#   $v0 - vertical flip
#
#######################################################
get_v_flip: nop
    push $t0
    lw $t0,$0,vertical_flip_mask
    and $v0,$a0,$t0
    srl $v0,$v0,23
    pop $t0
    ret

#######################################################
# set_v_flip: Sets vertical flip in sprite register layout data
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#   $a1 - Vertical flip bit to set (lsb 1 bit)
#
# Returns:
#   $v0 - S.R.L. data with vertical flip
#
#######################################################
set_v_flip: nop
    push $t0
    lw $t0,$0,vertical_flip_mask
    nand $t0,$t0,$t0
    and $v0,$a0,$t0
    sll $a1,$a1,23
    xor $v0,$v0,$a1
    pop $t0
    ret

#######################################################
# get_h_flip: Gets horizontal flip from s.r.l.d.
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#
# Returns:
#   $v0 - horizontal flip
#
#######################################################
get_h_flip: nop
    push $t0
    lw $t0,$0,horiz_flip_mask
    and $v0,$a0,$t0
    srl $v0,$v0,22
    pop $t0
    ret

#######################################################
# set_h_flip: Sets horizontal flip in sprite register layout data
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#   $a1 - Horizontal flip bit to set (lsb 1 bit)
#
# Returns:
#   $v0 - S.R.L. data with horizontal flip
#
#######################################################
set_h_flip: nop
    push $t0
    lw $t0,$0,horiz_flip_mask
    nand $t0,$t0,$t0
    and $v0,$a0,$t0
    sll $a1,$a1,22
    xor $v0,$v0,$a1
    pop $t0
    ret

#######################################################
# get_color_palette: Gets color palette from s.r.l.d.
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#
# Returns:
#   $v0 - color palette
#
#######################################################
get_color_palette: nop
    push $t0
    lw $t0,$0,color_palette_mask
    and $v0,$a0,$t0
    srl $v0,$v0,16
    pop $t0
    ret

#######################################################
# get_color_palette: Gets color palette from s.r.l.d.
#
# Arguments:
#   $a0 - Sprite Register Layout formatted data
#   $a1 - Color Palette bits
#
# Returns:
#   $v0 - S.R.L. data with new color palette
#
#######################################################
set_color_palette: nop
    push $t0
    lw $t0,$0,color_palette_mask
    nand $t0,$t0,$t0
    and $v0,$a0,$t0
    sll $a1,$a1,16
    xor $v0,$v0,$a1
    pop $t0
    ret

game_instructions: nop

##########################################################################################################################
#  _____ _            _____          _                                                                                   #
# |_   _| |          |  ___|        | |                                                                                  #
#   | | | |__   ___  | |__ _ __   __| |                                                                                  #
#   | | | '_ \ / _ \ |  __| '_ \ / _` |                                                                                  #
#   | | | | | |  __/ | |__| | | | (_| |_                                                                                 #
#   \_/ |_| |_|\___| \____/_| |_|\__,_(_)                                                                                #
#                                                                                                                        #
 ########################################################################################################################