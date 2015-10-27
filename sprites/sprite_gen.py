import sys
from PIL import Image

# pixel indices
r = 0
b = 1
g = 2

colors = {
    (0, 0, 0, 255): 0b00,
    (255, 0, 0, 255): 0b01,
    (0, 255, 0, 255): 0b10,
    (0, 0, 255, 255): 0b11
}

im = Image.open("images/light_bike.png")
width, height = im.size

if (width % 8 != 0):
    print "width not divisible by 8, yo"

if (height % 8 != 0):
    print "height not divisible by 8, yo "

pixels = list(im.getdata())

# loop through all pixels
color_map = []
for y in range(height):
    for x in range(width):
        index = (y * width) + x

        if (pixels[index] not in colors):
            print "color not available"
            print "({0}, {1}) {2}".format(x, y, pixels[index])
            sys.exit(1)

        color_map.append(colors[pixels[index]])

print color_map
