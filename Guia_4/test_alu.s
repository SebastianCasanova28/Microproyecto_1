.text
.globl _start

_start:

    # Valores iniciales
    addi x1, x0, 8
    addi x2, x0, 2
    addi x7, x0, -16

    # Desplazamiento a la izquierda
    sll  x3, x1, x2      # x3 = 8 << 2 = 32
    slli x4, x1, 1       # x4 = 8 << 1 = 16

    # Desplazamiento lógico a la derecha
    srl  x5, x7, x2      # x5 = 0x3FFFFFFC
    srli x6, x7, 1       # x6 = 0x7FFFFFF8

    # Desplazamiento aritmético a la derecha
    sra  x8, x7, x2      # x8 = -4
    srai x9, x7, 1       # x9 = -8

    # Comparaciones con signo
    slt  x10, x7, x1     # -16 < 8  → x10 = 1
    slti x11, x1, 10     # 8 < 10   → x11 = 1

    # Comparaciones sin signo
    sltu  x12, x7, x1    # unsigned(-16) < 8 → x12 = 0
    sltiu x13, x1, 10    # 8 < 10 → x13 = 1

    # Instrucciones tipo U
    lui   x14, 0x12345    # x14 = 0x12345000
    auipc x15, 0x1        # x15 = PC + 0x00001000
    