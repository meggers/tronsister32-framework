import sys
import numpy as np
from utils import *
from PIL import Image
from os import listdir
from os.path import isfile, join

image_folder = "images/"
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
    (  0, 255): (0,1)
}

image_files = [ f for f in listdir(image_folder) if isfile(join(image_folder,f)) ]

sprites = []
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
            pixels = np.array(im.getdata(), dtype=('int, int'))

    # unflatted array into image size
    pixels.shape = (pixel_height, pixel_width)

    # block pixels into sprites
    sprites = sprites + blockshaped(pixels, sprite_size, sprite_size).tolist()

sprite_memory = []
for sprite in sprites:
    for line in sprite:

        decomposed_bytes = ["",""]
        for pixel in [tuple(p) for p in line]:
            if pixel not in colors:
                print "Invalid color found"
                sys.exit(1)

            decomposed_bytes[0] += str(colors[pixel][1])
            decomposed_bytes[1] += str(colors[pixel][0])

        sprite_memory.append("".join(decomposed_bytes))

output = open("sprite_memory.coe", 'w')
output.truncate()
output.write("memory_initialization_radix=2;\nmemory_initialization_vector=\n")
output.write(",\n".join(sprite_memory))
output.write(";")
output.close