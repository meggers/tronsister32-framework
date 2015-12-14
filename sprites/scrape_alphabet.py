from PIL import Image
import string, os, sys, getopt
from subprocess import call

alphabet = list(string.ascii_uppercase)
numbers = range(0, 10)

def main(game_directory):
    global alphabet, numbers

    for character in alphabet + numbers:# + symbols:
        os.system('convert -background "rgb(0,0,0)" -fill "rgb(255,0,0)" -font {0}assets/font/main.ttf -pointsize 8 label:"{1}" {0}assets/font/{1}.png'.format(game_directory, character))
        im = Image.open("{0}assets/font/{1}.png".format(game_directory, character))
        cropped = im.crop((0, 2, 8, 10))
        cropped.save("{0}assets/background/char_{1}.png".format(game_directory, character), "PNG")

# print standard usage msg & any addtl msgs, then exit
def usage(exit_code, *args):
    for arg in args:
        print arg

    print "scrape_alphabet.py -d <game_folder>"
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