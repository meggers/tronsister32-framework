#!/usr/bin/python

import sys, os, getopt, random

sys.path.insert(0, os.getcwd() + '/common/')
from isa import *

isa = DataWarehouse()

def main(instruction_count):
    global isa

    instructions = isa.instruction_set

    for i in range(instruction_count):
        instruction = random.choice(instructions.keys())
        print instruction

# print standard usage msg & any addtl msgs, then exit
def usage(exit_code, *args):
    for arg in args:
        print arg

    print "generate.py -i <# of instructions>"
    sys.exit(exit_code)

# parse our command line arguments
def parse_args(argv):
    instruction_count = 0

    try:
        opts, args = getopt.getopt(argv, "hi:", ["help","instructions="])
    except getopt.GetoptError as error:
        usage(2, str(error))

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage(0)
        elif opt in ("-i", "--instructions"):
            instruction_count = int(arg)

    if instruction_count in [None, ""]:
        usage(2, 'You must specify how many instructions you want to generate.')

    return instruction_count   

if __name__ == "__main__": 
    main(parse_args(sys.argv[1:]))