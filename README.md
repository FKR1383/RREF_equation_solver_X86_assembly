
# RREF equation solver

My Project is RREF equation solver using X68 assembly. This is my school project.


## Tools
- X86 assembly and NASM


## Implementation Details

I use X86 assembly to create this program.
by RREF algorithm, it can solve equations or figure out that the solution does not exist.

## How to Run

Just compile and run using run.sh file. you must first install the reqirements (that shown after running run.sh, if you don't have them.)
run command:
./run.sh [assembly filename without extension]
for example:
./run.sh X86-RREF

## How to Use

sample input1:
3
1 2 3 0
2 2 2 2
2 0 2 3

sample output1:
1.75 -0.5 -0.25

details:
1x + 2y + 3z = 0
2x + 2y + 2z = 2
2x + 0y + 2z = 3
solve --->
x = 1.75, y = -0.5, z = -0.25

sample input2:
2
1 1 3
1 1 0

sample output2:
Impossible

## Authors
- [Farzam Koohi Ronaghi](https://github.com/FKR1383)

