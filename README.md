# Pipelined RISC-V
A five-stage pipelined RISC-V CPU core written in Verilog. This core has support for the RV32I integer instruction set. This core has been rigorously tested for correctness on all implemented instructions using real hardware by deploying and running programs on the PYNQ-Z1 FPGA.

## Highlights
- Implements the RV32I instruction set
- Handles hazards, stalls, and bypasses at each stage
- Each implemented instruction has passed rigorous testing for correctness
- Successfully executes C programs compiled for the RV32I instruction set
- Has been tested on real hardware using the PYNQ-Z1 FPGA

## List of Implemented Instructions
- lui
- auipc
- jal
- jalr
- beq
- bne
- blt
- bge
- bltu
- bgeu
- lb
- lh
- lw
- lbu
- lhu
- sb
- sh
- sw
- addi
- slti
- sltiu
- xori
- ori
- andi
- slli
- srli
- srai
- add
- sub
- sll
- slt
- sltu
- xor
- srl
- sra
- or
- and
- ecall