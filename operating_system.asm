 #######################################################################################################################
# _____                   _     _                  _____  _____  ______                                           _     #
#|_   _|                 (_)   | |                |____ |/ __  \ |  ___|                                         | |    #
#  | |_ __ ___  _ __  ___ _ ___| |_ ___ _ __ ______   / /`' / /' | |_ _ __ __ _ _ __ ___   _____      _____  _ __| | __ #
#  | | '__/ _ \| '_ \/ __| / __| __/ _ \ '__|______|  \ \  / /   |  _| '__/ _` | '_ ` _ \ / _ \ \ /\ / / _ \| '__| |/ / #
#  | | | | (_) | | | \__ \ \__ \ ||  __/ |        .___/ /./ /___ | | | | | (_| | | | | | |  __/\ V  V / (_) | |  |   <  #
#  \_/_|  \___/|_| |_|___/_|___/\__\___|_|        \____/ \_____/ \_| |_|  \__,_|_| |_| |_|\___| \_/\_/ \___/|_|  |_|\_\ #
#                                                                                                                       #
#########################################################################################################################
#                                                                                                                       #
# Description:                                                                                                          #
#   Core functions and data for Tronsister-32 games. Sorry.                                                             #
#                                                                                                                       #
#########################################################################################################################
#                                                                                                                       #
# Info:                                                                                                                 #
#   ascii art @ http://patorjk.com/software/taag/ "Doom"                                                                #
#                                                                                                                       #
#########################################################################################################################

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

#########################################################################################################################
#  _____            _ _        ______           _     _                                                                 #
# /  ___|          (_) |       | ___ \         (_)   | |                                                                #
# \ `--. _ __  _ __ _| |_ ___  | |_/ /___  __ _ _ ___| |_ ___ _ __                                                      #
#  `--. \ '_ \| '__| | __/ _ \ |    // _ \/ _` | / __| __/ _ \ '__|                                                     #
# /\__/ / |_) | |  | | ||  __/ | |\ \  __/ (_| | \__ \ ||  __/ |                                                        #
# \____/| .__/|_|  |_|\__\___| \_| \_\___|\__, |_|___/\__\___|_|                                                        #
#       | |                                __/ |                                                                        #
#       |_|                               |___/                                                                         #
#  _____      _   _                                  _   _____      _   _                                               #
# |  __ \    | | | |                                | | /  ___|    | | | |                                              #
# | |  \/ ___| |_| |_ ___ _ __ ___    __ _ _ __   __| | \ `--.  ___| |_| |_ ___ _ __ ___                                #
# | | __ / _ \ __| __/ _ \ '__/ __|  / _` | '_ \ / _` |  `--. \/ _ \ __| __/ _ \ '__/ __|                               #
# | |_\ \  __/ |_| ||  __/ |  \__ \ | (_| | | | | (_| | /\__/ /  __/ |_| ||  __/ |  \__ \                               #
#  \____/\___|\__|\__\___|_|  |___/  \__,_|_| |_|\__,_| \____/ \___|\__|\__\___|_|  |___/                               #
#                                                                                                                       #
#########################################################################################################################

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
    lw $v0,x_mask
    and $v0,$a0,$v0
    srl $v0,$v0,24
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

get_tile_no:
    lw $t0,sprite_index_mask
set_tile_no:
    lw $t0,sprite_index_mask

get_v_flip:
    lw $t0,vertical_flip_mask
set_v_flip:
    lw $t0,vertical_flip_mask

get_h_flip:
    lw $t0,horiz_flip_mask
set_h_flip:
    lw $t0,horiz_flip_mask

get_color_palette:
    lw $t0,color_palette_mask
set_color_palette:
    lw $t0,color_palette_mask

#########################################################################################################################
# _____                 _   _                 _ _                                                                       #
#|_   _|               | | | |               | | |                                                                      #
#  | |_ __ __ _ _ __   | |_| | __ _ _ __   __| | | ___ _ __ ___                                                         #
#  | | '__/ _` | '_ \  |  _  |/ _` | '_ \ / _` | |/ _ \ '__/ __|                                                        #
#  | | | | (_| | |_) | | | | | (_| | | | | (_| | |  __/ |  \__ \                                                        #
#  \_/_|  \__,_| .__/  \_| |_/\__,_|_| |_|\__,_|_|\___|_|  |___/                                                        #
#              | |                                                                                                      #
#              |_|                                                                                                      #
#                                                                                                                       #
#########################################################################################################################

# handle game tick interrupt
game_tick_interrupt:    nop $zero,$zero,$zero

# handle keyboard interrupt 
keyboard_interrupt:     nop $zero,$zero,$zero
                        
# handle stack overflow interrupt
stack_ov_interrupt:     nop $zero,$zero,$zero

#########################################################################################################################
# _____ _            _____          _                                                                                   #
#|_   _| |          |  ___|        | |                                                                                  #
#  | | | |__   ___  | |__ _ __   __| |                                                                                  #
#  | | | '_ \ / _ \ |  __| '_ \ / _` |                                                                                  #
#  | | | | | |  __/ | |__| | | | (_| |_                                                                                 #
#  \_/ |_| |_|\___| \____/_| |_|\__,_(_)                                                                                #               
#                                                                                                                       #
#                                                                                                                       #
 #######################################################################################################################