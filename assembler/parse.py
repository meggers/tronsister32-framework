#!/usr/bin/python

from collections import defaultdict

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

def singleton(cls):
    instances = {}
    def getinstance():
        if cls not in instances:
            instances[cls] = cls()
        return instances[cls]
    return getinstance

@singleton
class DataWarehouse(object):

    reg_file = "../common/reg-definitions.csv"
    isa_file = "../common/isa-definitions.csv"
    fmt_file = "../common/format-definitions.csv"

    data_address = int('0x000', 16)
    instructions_address = int('0x800', 16)

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
                    "format": instruction_parts[2]
                }

        with open(self.fmt_file) as f:
            lines = f.readlines()
            for line in lines[1:]:
                format_parts = line.rstrip().split(',')
                self.instruction_formats[format_parts[0]].append({
                    "order": format_parts[1],
                    "type": format_parts[2],
                    "width": format_parts[3]
                })

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
    def __init__(self, address, line = "add $zero,$zero,$zero", value = None):
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
        if (raw_fields[1] in self.data_directives):
            raise DataDirective(raw_fields[0], self.data_directives[raw_fields[1]](raw_fields[2]))

        # check if this is a labelled address and set address
        self.address = address
        if (raw_fields[0][-1] == ':'):
            self.label = raw_fields[0][:-1]
            self.operation = raw_fields[1]
            try:
                self.arguments = raw_fields[2].split(',')
            except IndexError:
                self.arguments = None
        else:
            self.operation = raw_fields[0]
            self.arguments = raw_fields[1].split(',')

    def assemble(self):
        if hasattr(self, 'value'):
            return self.value

        instruction_format = self.data.instruction_set[self.operation]
        instruction_opcode = instruction_format["opcode"]
        instruction_format = instruction_format["format"]

        binary_instruction = instruction_opcode
        for index, field in enumerate(sorted(self.data.instruction_formats[instruction_format], key=lambda x: x["order"])):
            length = int(field['width'])
            try:
                if field["type"] == "register":
                    value = self.data.lookup_table[self.arguments[index]]
                    value = bin(int(value))[2:].zfill(length)
                    binary_instruction += value

                elif field["type"] == "immediate":
                    if hasattr(self.data.lookup_table, self.arguments[index]):
                        value = self.data.lookup_table[self.arguments[index]]
                        value = bin(int(value))[2:].zfill(length)
                    else:
                        value = self.arguments[index]
                        if "0x" in value:
                            value = bin(int(value[2:], 16))[2:].zfill(length)
                        else:
                            value = bin(int(value))[2:].zfill(length)

                    binary_instruction += value

                elif field["type"] == "not_used":
                    binary_instruction += '0' * length

            except IndexError:
                break

        return format(int(binary_instruction, 2), '08x')