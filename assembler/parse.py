#!/usr/bin/python

import sys, os

sys.path.insert(0, os.getcwd() + '/common/')
from isa import *

class EmptyLine(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class StartData(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)
    def get(self):
        return self.value

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
        return "00000000" * int(data)

    structure_directives = ['.text', '.data']
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

        # remove spaces/new lines
        clean_line = clean_line.rstrip()

        # split on spaces
        raw_fields = clean_line.split()

        # check if this field contains information
        if len(raw_fields) == 0:
            raise EmptyLine('No information on this line, ignore it.')

        # check if this is a structural directive
        if raw_fields[0] in self.structure_directives:
            if raw_fields[0] == '.text':
                raise StartInstructions(raw_fields)
            else:
                raise StartData(raw_fields)

        # check if this is a data directive
        try:
            if raw_fields[1] in self.data_directives:
                raise DataDirective(raw_fields[0][:-1], self.data_directives[raw_fields[1]](raw_fields[2]))
        except IndexError:
            self.arguments = []

        # set address
        self.address = address

        # check if this is line has a label
        if raw_fields[0][-1] == ':':
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
                if argument in self.data.registers:
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