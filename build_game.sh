#!/usr/bin/env bash

# stop build script if any step fails
set -e

# start virtualenv
echo "Starting virtual environment"
source venv/bin/activate

# install all python dependencies
echo "Checking dependencies..."
pip install -r requirements.txt

# get character sprites out of ttf
echo "Parsing font files..."
python sprites/scrape_alphabet.py

# generate foreground and background coe files
echo "Generating sprites init files..."
python sprites/sprite_gen.py

# assemble program
echo "Assembling program..."
python assembler/assembler.py -i $1 -o $2

echo "Game build successfully. Exiting..."