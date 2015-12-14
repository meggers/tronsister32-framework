import sys, os, getopt
import numpy as np
from utils import *
from PIL import Image
from os import listdir
from os.path import isfile, join

memory_size = 2048
image_folders = ["foreground/", "background/"]
sprite_size = 8
colors = {
    (  0,   0,   0, 255): (0,0),
    (255,   0,   0, 255): (0,1),
    (  0, 255,   0, 255): (1,0),
    (  0,   0, 255, 255): (1,1),
    (  0,   0,   0): (0,0),
    (255,   0,   0): (0,1),
    (  0, 255,   0): (1,0),
    (  0,   0, 255): (1,1),
    (  0,   0): (0,0),
    (  0, 255): (0,1),
       0: (0, 0),
       1: (0, 1)
}

def main(game_directory):
    global memory_size, image_folders, sprite_size, colors

    image_path = game_directory + 'assets/'

    sprite_parts = [ "clear,0,1,1,1" ]
    for i, image_folder in enumerate([image_path + folder for folder in image_folders]):
        image_files = [ f for f in listdir(image_folder) if isfile(join(image_folder,f)) ]

        sprites = []
        sprite_index = 1 if "background" in image_folder else 0
        for image_file in image_files:
            im = Image.open(image_folder + image_file)
            pixel_width, pixel_height = im.size

            if (pixel_width % sprite_size != 0):
                print "width not divisible by 8, yo"
                sys.exit(1)

            if (pixel_height % sprite_size != 0):
                print "height not divisible by 8, yo"
                sys.exit(1)

            # read pixels into array
            try:
                pixels = np.array(im.getdata(), dtype=('int, int, int, int'))
            except:
                try:
                    pixels = np.array(im.getdata(), dtype=('int, int, int'))
                except:
                    try:
                        pixels = np.array(im.getdata(), dtype=('int, int'))
                    except:
                        pixels = np.array(im.getdata(), dtype=('int'))

            # unflatted array into image size
            pixels.shape = (pixel_height, pixel_width)

            # block pixels into sprites
            sprites = sprites + blockshaped(pixels, sprite_size, sprite_size).tolist()

            # save off sprite names for csv dump used by assembler
            spr_height = pixel_height / sprite_size
            spr_width = pixel_width / sprite_size
            spr_size = spr_height * spr_width
            sprite_parts.append("{0},{1},{2},{3},{4}".format(image_file.split('.')[0], sprite_index, spr_height, spr_width, spr_size))
            sprite_index += (pixel_height / sprite_size) * (pixel_width / sprite_size)

        sprite_memory = [ "0000000000000000" for x in range(8) ]
        for sprite in sprites:
            for line in sprite:

                decomposed_bytes = ["",""]
                for pixel in line:
                    if pixel not in colors:
                        print "Invalid color found"
                        sys.exit(1)

                    decomposed_bytes[0] += str(colors[pixel][1])
                    decomposed_bytes[1] += str(colors[pixel][0])

                sprite_memory.append("".join(decomposed_bytes))

        if len(sprite_memory) > memory_size:
            print "Too many sprites!"
            print "You have {0} {1} sprites, but the max is {2}".format(len(sprite_memory) / sprite_size, image_folders[i][:-1], memory_size / sprite_size)
            print "Aborting..."
            sys.exit(1)
        else:
            print "Generating {0} {1} sprites of a maximum {2}".format(len(sprite_memory) / sprite_size, image_folders[i][:-1], memory_size / sprite_size)
            for _ in range(memory_size - len(sprite_memory)):
                sprite_memory.append("0000000000000000")

        output = open(game_directory + 'build/' + image_folders[i][:-1] + "_memory.coe", 'w')
        output.truncate()
        output.write("memory_initialization_radix=2;\nmemory_initialization_vector=\n")
        output.write(",\n".join(sprite_memory))
        output.write(";")
        output.close()

    output = open("common/sprite-definitions.csv", 'w')
    output.truncate()
    output.write("name,index,height,width,size\n")
    output.write("\n".join(sprite_parts))
    output.close()

# print standard usage msg & any addtl msgs, then exit
def usage(exit_code, *args):
    for arg in args:
        print arg

    print "sprite_gen.py -d <game_folder>"
    sys.exit(exit_code)

# parse our command line arguments
def parse_args(argv):
    game_directory = ""
    framework = False

    try:
        opts, args = getopt.getopt(argv, "hd:", ["help","game_directory="])
    except getopt.GetoptError as error:
        usage(2, str(error))

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage(0)
        elif opt in ("-d", "--game_directory"):
            game_directory = arg

    if game_directory in [None, ""]:
        usage(2, 'You must specify a game directory.')

    return game_directory

if __name__ == "__main__": 
    main(parse_args(sys.argv[1:]))