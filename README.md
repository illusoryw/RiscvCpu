# RiscvCpu

Coursework for *Computer System Integrated Design, 2022 Summer*

Supported instructions:

- add, sub, and, or, xor, sll, srl, sra, slt, sltu
- addi, andi, ori, xori, slli, srli, srai, slti, sltiu
- lb, lbu, lh, lhu, lw
- sb, sh, sw
- beq, bne, blt, bltu, bge, bgeu
- jal, jalr

## Run simulation

1. Install `iverilog` and `vvp`
2. (Optional) Install `gtkwave` to view the VCD dump file
3. Copy any test case in ./test to ./build, then rename it to `cputest.in`
4. Run ./run.bat