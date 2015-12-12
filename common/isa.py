#!/usr/bin/python

from collections import defaultdict

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
    clr_file = "common/palette-definitions.csv"

    instructions_address = int('0x000', 16)
    instructions_end     = int('0x3FC', 16)

    game_tick_address    = int('0x3FD', 16)
    keyboard_address     = int('0x3FE', 16)
    stack_ov_address     = int('0x3FF', 16)

    heap_address         = int('0x400', 16)
    heap_end             = int('0xBFF', 16)
    
    stack_address        = int('0xC00', 16)
    end_of_memory        = int('0xFFF', 16)

    interrupts = {
        'game_tick_interrupt': game_tick_address, 
        'keyboard_interrupt': keyboard_address, 
        'stack_ov_interrupt': stack_ov_address
    }

    lookup_table = {}
    registers = {}
    instruction_set = {}
    instruction_formats = defaultdict(list)

    def __init__(self):
        with open(self.reg_file) as f:
            lines = f.readlines()
            for line in lines[1:]:
                register_parts = line.rstrip().split(',')
                self.lookup_table[register_parts[0]] = register_parts[1]
                self.registers[register_parts[0]] = register_parts[1]

        with open(self.isa_file) as f:
            lines = f.readlines()
            for line in lines[1:]:
                instruction_parts = line.rstrip().split(',')
                self.instruction_set[instruction_parts[0]] = {
                    "opcode": instruction_parts[1],
                    "relative": instruction_parts[2] == "1",
                    "format": instruction_parts[3],
                    "num_fields": int(instruction_parts[4])
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
                self.lookup_table[sprite_parts[0] + "_size"]   = sprite_parts[4]

        with open(self.clr_file) as f:
            lines = f.readlines()
            for i, line in enumerate(lines[1:]):
                palette_parts = line.rstrip().split(',')
                self.lookup_table[palette_parts[0]] = i