.section .note.GNU-stack
.section .text
.global  _start
_start:
    ldr x0, [sp]
    add x1, sp, 8
    lsl x2, x0, 3
    add x2, x2, 8
    add x2, x2, x1
    and sp, x1, -16
    bl main
    mov x8, 93
    svc #0

