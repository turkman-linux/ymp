.section .text
.global  _start
_start:
    pop {%r0}
    mov %r1, %sp
    add %r2, %r1, %r0, lsl #2
    add %r2, %r2, $4
    and %r3, %r1, $-8
    mov %sp, %r3
    bl main
    movs r7, $1
    svc $0x00

