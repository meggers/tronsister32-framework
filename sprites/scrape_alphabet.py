from PIL import Image
import string, os
from subprocess import call

alphabet = list(string.ascii_uppercase)
numbers = range(0, 10)
#symbols = list("!?#.,'")

for character in alphabet + numbers:# + symbols:
    os.system('convert -background none -fill black -font sprites/alphabet/alphabet.ttf -pointsize 8 label:"{0}" sprites/alphabet/{0}.png'.format(character))
    im = Image.open("sprites/alphabet/{0}.png".format(character))
    cropped = im.crop((0, 2, 8, 10))
    cropped.save("sprites/images/background/{0}.png".format(character), "PNG")
