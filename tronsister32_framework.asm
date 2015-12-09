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
#   0(sf): sprite index             #
#   1(sf): sprite height            #
#   2(sf): sprite width             #
#   3(sf): left x (8 lsb)           #
#   4(sf): top y (8 lsb)            #
#   5(sf): starting oam slot        #
#                                   #
#####################################
load_sprite_img:                    #
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
    add $t9,$t9,t5                  # increment mem oam index to starting index
                                    #
    li $t10,0                       # initialize sprite register data to 0
                                    #
    load_sprite_oloop:              #
        sub $zero,$t1,$t6           #
        beq load_sprite_return      #
                                    #
        load_sprite_iloop:          #
            sub $zero,$t2,$t7       #
            beq rst_sprite_iloop    #
                                    #
            add $a0,$zero,$10       # set current sprite data into first argument
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
            add $10,$zero,$v0       # get chained results from above functions
            sld $t5,$t10            # load the sprite data to oam
            lw $10,$t9              # load the sprite data to mem oam
                                    #
            addi $t5,1              # increment current oam slot
            addi $t9,1              # increment current mem oam slot
            addi $t8,1              # increment current sprite index
            addi $t7,1              # increment inner loop index
            b load_sprite_iloop     #
                                    #
        rst_sprite_iloop:           #
            li $t7,0                # reset inner loop index
            addi $t6,1              # increment outer loop index
            b load_sprite_oloop     # 
                                    #
    load_sprite_return:             #
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
get_x:
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
set_x:
    lw $t0,x_mask
    nand $t0,$t0,$t0
    and $v0,$a0,$t0
    sll $a1,$a1,24
    xor $v0,$v0,$a1
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
get_y:
    lw $v0,y_mask
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
set_y:
    lw $t0,y_mask
    and $t1,$t0,$a1
    nand $t0,$t0,$t0
    and $v0,$a0,$t0
    xor $v0,$v0,$t1
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
get_tile_no:
    lw $t0,sprite_index_mask
    and $v0,$a0,$t0
    srl $v0,$v0,16
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
set_tile_no:
    lw $t0,sprite_index_mask
    nand $t0,$t0,$t0
    and $v0,$t0,$a0
    sll $a1,$a1,16
    xor $v0,$v0,$a1
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
get_v_flip:
    lw $t0,vertical_flip_mask
    and $v0,$a0,$t0
    srl $v0,$v0,15
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
set_v_flip:
    lw $t0,vertical_flip_mask
    nand $t0,$t0,$t0
    and $v0,$a0,$t0
    sll $a1,$a1,15
    xor $v0,$v0,$a1
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
get_h_flip:
    lw $t0,horiz_flip_mask
    and $v0,$a0,$t0
    srl $v0,$v0,14
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
set_h_flip:
    lw $t0,horiz_flip_mask
    nand $t0,$t0,$t0
    and $v0,$a0,$t0
    sll $a1,$a1,14
    xor $v0,$v0,$a1
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
get_color_palette:
    lw $t0,color_palette_mask
    and $v0,$a0,$t0
    srl $v0,$v0,8
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
set_color_palette:
    lw $t0,color_palette_mask
    nand $t0,$t0,$t0
    and $v0,$a0,$t0
    sll $a1,$a1,8
    xor $v0,$v0,$a1
    ret

##########################################################################################################################
#  _____                 _   _                 _ _                                                                       #
# |_   _|               | | | |               | | |                                                                      #
#   | |_ __ __ _ _ __   | |_| | __ _ _ __   __| | | ___ _ __ ___                                                         #
#   | | '__/ _` | '_ \  |  _  |/ _` | '_ \ / _` | |/ _ \ '__/ __|                                                        #
#   | | | | (_| | |_) | | | | | (_| | | | | (_| | |  __/ |  \__ \                                                        #
#   \_/_|  \__,_| .__/  \_| |_/\__,_|_| |_|\__,_|_|\___|_|  |___/                                                        #
#               | |                                                                                                      #
#               |_|                                                                                                      #
#                                                                                                                        #
##########################################################################################################################

# handle game tick interrupt
game_tick_interrupt:    
    nop $zero,$zero,$zero
    j $epc

# handle keyboard interrupt 
keyboard_interrupt:     
    nop $zero,$zero,$zero
    j $epc
                        
# handle stack overflow interrupt
stack_ov_interrupt:
    nop $zero,$zero,$zero
    j $epc

##########################################################################################################################
#  _____ _            _____          _                                                                                   #
# |_   _| |          |  ___|        | |                                                                                  #
#   | | | |__   ___  | |__ _ __   __| |                                                                                  #
#   | | | '_ \ / _ \ |  __| '_ \ / _` |                                                                                  #
#   | | | | | |  __/ | |__| | | | (_| |_                                                                                 #
#   \_/ |_| |_|\___| \____/_| |_|\__,_(_)                                                                                #
#                                                                                                                        #
#                                                                                                                        #
 ########################################################################################################################