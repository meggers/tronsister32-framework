#!/usr/bin/python
import os, sys, getopt
from shutil import copyfile

def main(game_directory):
    colors = []
    with open(game_directory + 'assets/color_palette.csv') as f:
        lines = f.readlines()
        for line in lines[1:]:
            parts = line.rstrip().split(',')
            for color in parts[1:]:
                colors.append(color[2:])

    output = open(game_directory + 'build/color_palette.coe', 'w')
    output.truncate()
    output.write("memory_initialization_radix=16;\nmemory_initialization_vector=\n")
    output.write(",\n".join(colors))
    output.write(";")
    output.close()

    copyfile(game_directory + 'assets/color_palette.csv', 'common/palette-definitions.csv')

# print standard usage msg & any addtl msgs, then exit
def usage(exit_code, *args):
    for arg in args:
        print arg

    print "palette_gen.py -d <game_folder>"
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