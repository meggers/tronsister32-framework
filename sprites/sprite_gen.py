import sys
import numpy as np
from utils import *
from PIL import Image

sprite_size = 8
colors = {
    (  0,   0,   0, 255): (0,0),
    (255,   0,   0, 255): (0,1),
    (  0, 255,   0, 255): (1,0),
    (  0,   0, 255, 255): (1,1)
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
pixels = np.array(im.getdata(), dtype=('int, int, int, int'))

# unflatted array into image size
pixels.shape = (pixel_height, pixel_width)

# block pixels into sprites
sprites = blockshaped(pixels, sprite_size, sprite_size)

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

print sprite_memory