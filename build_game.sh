#!/usr/bin/env bash

# stop build script if any step fails
set -e

# start virtualenv
echo "Starting virtual environment..."
source venv/bin/activate

# install all python dependencies
echo "Checking dependencies..."
pip install -r requirements.txt

# get character sprites out of ttf
echo "Parsing font files..."
python sprites/scrape_alphabet.py -d $1

# generate foreground and background coe files
echo "Generating sprites init files..."
python sprites/sprite_gen.py -d $1

# generate color palette
echo "Generating color palettes...."
python colors/palette_gen.py -d $1

# assemble program
echo "Assembling program..."
python assembler/assembler.py -d $1 $2

echo "Game build successful."
echo "Deactivating virtual environment"
deactivate

echo "Exiting."