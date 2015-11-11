#!/usr/bin/python

from collections import defaultdict
import sys

class EmptyLine(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)   

class StartInstructions(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)
    def get(self):
        return self.value

class DataDirective(Exception):
    def __init__(self, label, value):
        self.label = label
        self.value = value
    def __str__(self):
        return repr(self.value)
    def get(self):
        return self.label, self.value 

class PsuedoInstruction(Exception):
    def __init__(self, instructions):
        self.instructions
    def __str__(self):
        return repr(self.instructions)
    def get(self):
        return self.instructions

def getBit(y, x):
    return str((x>>y)&1)

def tobin(x, count):
    shift = range(count-1, -1, -1)
    bits = map(lambda y: getBit(y, x), shift)
    return "".join(bits)

def singleton(cls):
    instances = {}
    def getinstance():
        if cls not in instances:
            instances[cls] = cls()
        return instances[cls]
    return getinstance

@singleton
class DataWarehouse(object):

    reg_file = "common/reg-definitions.csv"
    isa_file = "common/isa-definitions.csv"
    fmt_file = "common/format-definitions.csv"
    spr_file = "common/sprite-definitions.csv"

    instructions_address = int('0x000', 16)
    instructions_end     = int('0x3FC', 16)

    game_tick_address    = int('0x3FD', 16)
    keyboard_address     = int('0x3FE', 16)
    stack_ov_address     = int('0x3FF', 16)

    heap_address         = int('0x400', 16)
    heap_end             = int('0xBFF', 16)
    
    stack_address        = int('0xC00', 16)
    end_of_memory        = int('0xFFF', 16)

    interrupts = ['game_tick_interrupt', 'keyboard_interrupt', 'stack_ov_interrupt']
    lookup_table = {}
    instruction_set = {}
    instruction_formats = defaultdict(list)

    def __init__(self):
        with open(self.reg_file) as f:
            lines = f.readlines()
            for line in lines[1:]:
                register_parts = line.rstrip().split(',')
                self.lookup_table[register_parts[0]] = register_parts[1]

        with open(self.isa_file) as f:
            lines = f.readlines()
            for line in lines[1:]:
                instruction_parts = line.rstrip().split(',')
                self.instruction_set[instruction_parts[0]] = {
                    "opcode": instruction_parts[1],
                    "relative": instruction_parts[2] == "1",
                    "format": instruction_parts[3],
                }

        with open(self.fmt_file) as f:
            lines = f.readlines()
            for line in lines[1:]:
                format_parts = line.rstrip().split(',')
                self.instruction_formats[format_parts[0]].append({
                    "order": int(format_parts[1]),
                    "type": format_parts[2],
                    "width": int(format_parts[3])
                })

        with open(self.spr_file) as f:
            lines = f.readlines()
            for line in lines[1:]:
                sprite_parts = line.rstrip().split(',')
                self.lookup_table[sprite_parts[0] + "_index"]  = sprite_parts[1]
                self.lookup_table[sprite_parts[0] + "_height"] = sprite_parts[2]
                self.lookup_table[sprite_parts[0] + "_width"]  = sprite_parts[3]

class Line(object):

    def _asciiz(data):
        return data[1:-1].encode('hex') + "00" # null terminated braaaah

    def _byte(data):
        if "0x" in data:
            value = "{0:0{1}x}".format(int(data[2:], 16), 2)
        else:
            value = "{0:0{1}x}".format(int(data), 2)

        return value

    def _word(data):
        if "0x" in data:
            value = "{0:0{1}x}".format(int(data[2:], 16), 8)
        else:
            value = "{0:0{1}x}".format(int(data), 8)

        return value

    def _space(data):
        return "00" * int(data)

    structure_directives = ['.text']
    data_directives = {
        '.asciiz': _asciiz, 
        '.byte': _byte, 
        '.word': _word, 
        '.space': _space
    }

    data = DataWarehouse()

    # if empty initialize line to noop
    def __init__(self, address = None, line = "nop $zero,$zero,$zero", value = None):

        if value is not None:
            self.value = value
            return

        # remove comments
        clean_line = line.split("#")[0]

        # split on spaces
        raw_fields = clean_line.split()

        # check if this field contains information
        if (len(raw_fields) == 0):
            raise EmptyLine('No information on this line, ignore it.')

        # check if this is a structural directive
        if (raw_fields[0] in self.structure_directives):
            raise StartInstructions(raw_fields)

        # check if this is a data directive
        try:
            if (raw_fields[1] in self.data_directives):
                raise DataDirective(raw_fields[0], self.data_directives[raw_fields[1]](raw_fields[2]))
        except IndexError:
            self.arguments = []

        # set address
        self.address = address

        # check if this is line has a label
        if (raw_fields[0][-1] == ':'):
            self.label = raw_fields[0][:-1]
            self.operation = raw_fields[1]
            try:
                self.arguments = raw_fields[2].split(',')
            except IndexError:
                self.arguments = []
        else:
            self.operation = raw_fields[0]
            try:
                self.arguments = raw_fields[1].split(',')
            except:
                self.arguments = []

    def assemble(self):
        if hasattr(self, 'value'):
            return self.value

        try: 
            instruction_info = self.data.instruction_set[self.operation]
            instruction_opcode = instruction_info["opcode"]
            instruction_format = instruction_info["format"]
        except KeyError:
            print "Invalid operation '{0}' found in program. Exiting...".format(self.operation)
            sys.exit(1)

        binary_instruction = instruction_opcode
        argument_position = 0
        for index, field in enumerate(sorted(self.data.instruction_formats[instruction_format], key=lambda x: x["order"])):
            length = field['width']

            try:
                argument = self.arguments[argument_position]
            except IndexError:
                binary_instruction += '0' * length
                continue

            if field["type"] == "register":
                if argument in self.data.lookup_table:
                    value = self.data.lookup_table[argument]
                    value = bin(int(value))[2:].zfill(length)
                    binary_instruction += value
                    argument_position += 1
                else:
                    binary_instruction += '0' * length

            elif field["type"] == "immediate":
                if argument in self.data.lookup_table:
                    value = self.data.lookup_table[argument]
                    value = int(value) - (self.address + 1) if instruction_info["relative"] else int(value)
                    value = tobin(value, length)
                else:
                    value = argument
                    if "0x" in value:
                        value = int(value[2:], 16) - (self.address + 1) if instruction_info["relative"] else int(value[2:], 16)
                        value = tobin(value, length)
                    else:
                        value = int(value) - (self.address + 1) if instruction_info["relative"] else int(value)
                        value = tobin(value, length)

                binary_instruction += value
                argument_position += 1

            elif field["type"] == "not_used":
                binary_instruction += '0' * length

        return format(int(binary_instruction, 2), '08x')