import sys
import numpy as np
from utils import *
from PIL import Image

sprite_size = 8
colors = {
    (  0,   0,   0, 255): 0b00,
    (255,   0,   0, 255): 0b01,
    (  0, 255,   0, 255): 0b10,
    (  0,   0, 255, 255): 0b11
}

im = Image.open("images/light_bike.png")
pixel_width, pixel_height = im.size

if (pixel_width % sprite_size != 0):
    print "width not divisible by 8, yo"
    sys.exit(1)

if (pixel_height % sprite_size != 0):
    print "height not divisible by 8, yo"
    sys.exit(1)

# read pixels into array
pixels = np.array(im.getdata(), dtype=('i2, i2, i2, i2'))

# unflatted array into image size
pixels.shape = (pixel_height, pixel_width)

# block pixels into sprites
sprites = blockshaped(pixels, sprite_size, sprite_size)

print sprites

#sprite_memory = []
#for sprite_x in range(sprite_idx):
#    for sprite_y in range(sprite_y):
#        start_index = 2 * sprite_y * sprite_idx * sprite_size
#        end_index = start_index + (sprite_size ** 2)
#        sprite_memory.append(pixels[start_index:end_index])

# loop through all pixels
#color_map = []
#for y in range(height):
#    for x in range(width):
#        index = (y * width) + x

#        if (pixels[index] not in colors):
#            print "color not available"
#            print "({0}, {1}) {2}".format(x, y, pixels[index])
#            sys.exit(1)
#
#        color_map.append(colors[pixels[index]])

#print color_map

#def parse_sprite(pixels):
#    print "poop"