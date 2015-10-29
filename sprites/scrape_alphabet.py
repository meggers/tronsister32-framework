from PIL import Image
import string, os
from subprocess import call

alphabet = list(string.ascii_uppercase)

for letter in alphabet:
    os.system('convert -background none -fill black -font alphabet/alphabet.ttf -pointsize 8 label:"{0}" alphabet/{0}.png'.format(letter))
    im = Image.open("alphabet/{0}.png".format(letter))
    cropped = im.crop((0, 2, 8, 10))
    cropped.save("images/{0}.png".format(letter), "PNG")
