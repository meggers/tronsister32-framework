#!/usr/bin/python

import sys, os, getopt, random

sys.path.insert(0, os.getcwd() + '/common/')
from isa import *

isa = DataWarehouse()

def main(instruction_count):
    global isa

    instructions = isa.instruction_set
    formats = isa.instruction_formats
    registers = isa.registers

    generated_lines = []
    for _ in range(instruction_count):
        instruction = random.choice(instructions.keys())
        instruction_info = instructions[instruction]

        fields = []
        arguments = formats[instruction_info['format']]
        for i in range(instruction_info["num_fields"]):
            argument_type = arguments[i]["type"]
            if argument_type == "immediate":
                immediate = random.randint(-5, 5)
                fields.append(str(immediate))
            elif argument_type == "register":
                register = random.choice(registers.keys())
                fields.append(register)

        generated_lines.append("{0} {1}".format(instruction, ",".join(fields)))

    output = open('generated_program.asm', 'w')
    output.truncate()
    output.write(".text\n")
    output.write("\n".join(generated_lines))
    output.write("\n")
    output.close()

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