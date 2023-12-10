#!/bin/bash

# Navigate to the script's directory
cd "$(dirname "$0")"

# Clean and build
make clean
make

echo -e '\n'
echo -e "----------- OUTPUT ---------"

# Run the calculator with the input file in the same directory
./calc < input.txt

echo -e '\n'
echo -e "=========================="
echo -e "**RUNNING FROM $PWD**"

