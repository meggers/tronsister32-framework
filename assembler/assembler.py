#!/usr/bin/python
# 
#   Tronsistor-32 ISA
#   Assembler
#

import sys, os, getopt, math

sys.path.insert(0, os.getcwd() + '/common/')
from isa import *
from parse import *

opcodes = {}
data = DataWarehouse()
address_increment = 1
interrupt_count = 3

def read(program):
    global data, interrupt_count

    # initialize memory segments
    instructions    = []
    heap            = []
    interrupts      = []
    stack           = [Line() for _ in range(data.end_of_memory - data.stack_address + 1)]

    current_address = data.heap_address
    for line in program:
        try:
            # try parsing instruction
            instruction = Line(current_address, line)

            # if instructions would overflow into data, exit
            if current_address > data.instructions_end:
                print "Instruction Overflow. Please use fewer instructions or allocate more space for it."
                sys.exit(1)

            # if it has a label, add (label => address) to lookup table
            if hasattr(instruction, 'label'):
                data.lookup_table[instruction.label] = current_address

                # if this label is specifying an interrupt, add to interrupts
                if instruction.label in data.interrupts:
                    interrupts.append(Line(data.interrupts[instruction.label], 'b {0}'.format(instruction.label)))

            # add instruction to instructions list
            instructions.append(instruction)

            # increment address
            current_address += address_increment

        # We didn't get anything on this line, ignore
        except EmptyLine:
            continue

        # data directive found, allocate space in data
        except DataDirective as directive:
            # make sure we have space for this data
            byte_size = math.ceil(len(directive.value) / 2)
            allocated_end_address = current_address + byte_size
            if (allocated_end_address >= data.heap_end):
                print "Data Overflow. Please use less data or allocate more space for it."
                sys.exit(1)

            # add data to lookup table
            data.lookup_table[directive.label] = current_address

            current_value = ""
            for character in directive.value:
                current_value += character
                if len(current_value) == 8:
                    heap.append(Line(None, None, current_value))
                    current_address += address_increment
                    current_value = ""

            # set overflow value
            overflow_length = len(current_value)
            current_value = ("0" * (8 - overflow_length)) + current_value
            heap.append(Line(None, None, current_value))

        # instruction directive found, start writing in instruction section
        except StartInstructions:
            current_address = data.instructions_address

        # data directive found, start writing in heap
        except StartData:
            current_address = data.heap_address

    # check for required interrupts
    if len(interrupts) != interrupt_count:
        print "Assembler Error. Invalid number of interrupts."
        print "Found: {0} | Expected: {1}".format(len(interrupts), interrupt_count)
        print "Exiting..."
        sys.exit(1)

    # pad instruction section
    instructions_end = data.instructions_address + len(instructions)
    for _ in range(instructions_end, data.instructions_end + 1):
        instructions.append(Line())

    # pad data section
    heap_end = data.heap_address + len(heap)
    for _ in range(heap_end, data.heap_end + 1):
        heap.append(Line())

    # generate memory and check for correct length
    memory = instructions + interrupts + heap + stack
    if len(memory) != data.end_of_memory + 1:
        print "Assembler Error. Generated memory size mismatch."
        print "Generated: {0} | Expected: {1}".format(len(memory), data.end_of_memory + 1)
        print "Exiting..."
        sys.exit(1)
    else:
        return memory

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