.section .data
msg: .ascii "Hello\n"

.section .text
.global _start

_start:
    li a7, 64        # syscall: write
    li a0, 1         # fd = 1 (stdout)
    la a1, msg       # buffer address
    li a2, 6         # length
    ecall

    li a7, 93        # exit
    li a0, 0
    ecall
