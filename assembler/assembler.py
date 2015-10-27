#!/usr/bin/python
# 
#   Tronsistor-32 ISA
#   Assembler
#

import sys, getopt, math
from parse import *

opcodes = {}
data = DataWarehouse()
BYTE_ADDRESS = 4

def read(program):
    global data

    instructions = []
    current_address = data.data_address

    for line in program:
        try:
            instruction = Line(current_address, line)
            instructions.append(instruction)
            if (hasattr(instruction, 'label')):
                data.lookup_table[instruction.label] = current_address

            current_address += BYTE_ADDRESS

        # We didn't get anything on this line, ignore
        except EmptyLine:
            continue

        # data directive found, allocate space in data
        except DataDirective as directive:
            # make sure we have space for this data
            byte_size = math.ceil(len(directive.value) / 2)
            allocated_end_address = current_address + byte_size
            if (allocated_end_address >= data.instructions_address):
                print "Data Overflow. Please use less data or allocate more space for it"
                sys.exit(1)

            # add data to lookup table
            data.lookup_table[directive.label] = current_address

            current_value = ""
            for character in directive.value:
                current_value += character
                if len(current_value) == 8:
                    instructions.append(Line(current_address, None, current_value))
                    current_address += BYTE_ADDRESS
                    current_value = ""

            # set overflow value
            overflow_length = len(current_value)
            current_value = ("0" * (8 - overflow_length)) + current_value
            instructions.append(Line(current_address, None, current_value))

        # instruction directive found, start writing in instruction section
        except StartInstructions:

            # pad rest of data section
            for address in range(current_address, data.instructions_address):
                instructions.append(Line(address))

            current_address = data.instructions_address

    return instructions

def assemble(instructions):
    return [instruction.assemble() for instruction in instructions]

def dump(assembly, filename):
    global data

    output = open(filename, 'w')
    output.truncate()
    output.write("memory_initialization_radix=16;\nmemory_initialization_vector=\n")
    output.write(",\n".join(assembly))
    output.write(";")
    output.close

def main((input_filename, output_filename)):
    with open(input_filename) as f:
        program = f.readlines()
        instructions = read(program)
        assembly = assemble(instructions)
        dump(assembly, output_filename)

# print standard usage msg & any addtl msgs, then exit
def usage(exit_code, *args):
    for arg in args:
        print arg

    print "assembler.py -i <input_filename> -o <output_filename>"
    sys.exit(exit_code)

# parse our command line arguments
def parse_args(argv):
    input_filename = ""
    output_filename = ""

    try:
        opts, args = getopt.getopt(argv, "hi:o:", ["help","input=","output="])
    except getopt.GetoptError as error:
        usage(2, str(error))

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage(0)
        elif opt in ("-i", "--input"):
            input_filename = arg
        elif opt in ("-o", "--output"):
            output_filename = arg

    if input_filename in [None, ""]:
        usage(2, 'You must specify an input filename.')
    elif output_filename in [None, ""]:
        usage(2, 'You must specify an output filename.')

    return input_filename, output_filename    

if __name__ == "__main__": 
    main(parse_args(sys.argv[1:]))