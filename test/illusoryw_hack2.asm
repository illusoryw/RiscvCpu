# HACK: fake rs

lw x5, 0(x0)
lui x6, 0x00028  # lw.rd == lui.rs1
lw x5, 0(x0)
addi x6, x0, 5  # lw.rd == addi.rs2