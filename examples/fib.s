    .section .bss
buf:    .space 64

    .section .text
    .globl _start

_start:
    # read stdin
    li      x17, 63          # syscall: read
    li      x10, 0           # stdin
    la      x11, buf
    li      x12, 64
    ecall

    mv      x3, x10          # x3 = bytes read

    # parse decimal number
    li      x2, 0            # n = 0
    la      x4, buf          # ptr
    li      x5, 0            # index

parse_loop:
    beq     x5, x3, parse_done

    lb      x6, 0(x4)
    li      x7, 10           # '\n'
    beq     x6, x7, parse_done

    addi    x6, x6, -48      # digit
    li      x8, 10
    mul     x2, x2, x8
    add     x2, x2, x6

    addi    x4, x4, 1
    addi    x5, x5, 1
    j       parse_loop

parse_done:
    li      x5, 0            # a = 0
    li      x6, 1            # b = 1

fib_loop:
    beqz    x2, fib_done
    add     x7, x5, x6
    mv      x5, x6
    mv      x6, x7
    addi    x2, x2, -1
    j       fib_loop

fib_done:
    mv      x10, x5          # result

    la      x11, buf
    mv      x12, x11
    li      x7, 10

conv_loop:
    remu    x13, x10, x7
    addi    x13, x13, 48
    sb      x13, 0(x12)
    addi    x12, x12, 1
    divu    x10, x10, x7
    bnez    x10, conv_loop

    addi    x12, x12, -1
rev_loop:
    blt     x12, x11, rev_done
    lb      x13, 0(x11)
    lb      x14, 0(x12)
    sb      x14, 0(x11)
    sb      x13, 0(x12)
    addi    x11, x11, 1
    addi    x12, x12, -1
    j       rev_loop

rev_done:
    # newline
    la      x11, buf
    add     x12, x12, x11
    addi    x12, x12, 2
    li      x13, 10
    sb      x13, 0(x12)

    # write
    li      x17, 64
    li      x10, 1
    la      x11, buf
    sub     x12, x12, x11
    addi    x12, x12, 1
    ecall

exit:
    li      x17, 93
    li      x10, 0
    ecall
