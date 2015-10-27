Welcome to the Tronsmipster-32 Assembler

Have Fun

Specifications:

    - 5 assembler directives: '.text', '.asciiz', '.byte', '.word', '.space'
    - It is assumed that all information is written to data until assember reaches '.text' directive
    - The '.text' directive must be on its own line
    - The rest of the directives are explained here: http://students.cs.tamu.edu/tanzir/csce350/reference/assembler_dir.html
    - All labels must end in colons (:)
    - Labels must be on the same line as their data and instruction
    - At least one space must seperate each directive, label, instruction, and argument section on each line
    - The arguments in the argument section must be deliminated only by commas (,)
    - All data following the pound sign (#) will be treated as a comment and not assembled
    - Immediate fields can be decimal or hexadecimal (123, 0xFF)
    - '.asciiz' string must be in quotations and be all on one line (instructions in general must not span multiple lines)

Example Code:

# this is a comment
# data section starts here

test:   .byte 0xFA
const:  .word 0x0000 # ? what is our word size? 16b? 32b?
text:   .asciiz "check out my sick text"
            
.text # instructions start here

label1:     add $at,$at,$at
            sub $a0,$at,$at

lab:        addi $at,$at,$at

labella:    move $at,$at,$at
            andi $at,$at,$at

            hlt