#!/usr/bin/python

colors = []
with open('common/palette-definitions.csv') as f:
    lines = f.readlines()
    for line in lines[1:]:
        parts = line.rstrip().split(',')
        for color in parts[1:]:
            colors.append(color[2:])

output = open('color_palette.coe', 'w')
output.truncate()
output.write("memory_initialization_radix=16;\nmemory_initialization_vector=\n")
output.write(",\n".join(colors))
output.write(";")
output.close()