#!/bin/bash

make clean
make

echo -e '\n'
echo -e "----------- OUTPUT ---------"
echo "NOTE: THIS IS $PWD"
./calc < /home/donald/Projects/Desk-Calc-2/input.txt

echo -e '\n'
echo -e "=========================="
echo -e "**MAKE SURE IN RIGHT DIRECTORY**"
