# HACK: jump-lw-stall

addi x5, x0, 1
sw x5, 0(x0)
jal x0, lbb
lw x5, 0(x0)
add x6, x0, x5
addi x0, x0, 0
addi x0, x0, 0
addi x5, x5, 1
lbb:
addi x5, x5, 1