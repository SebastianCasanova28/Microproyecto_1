.text
.globl _main

_main:
    addi a0, x0, 12
    addi a1, x0, 3
    jal  ra, _funcion

fin:
    jal  x0, fin

_funcion:
    add  a0, a0, a1
    jalr x0, ra, 0
    