.section .note.GNU-stack
.section .text
.global  _start
_start:
    pop %eax
    mov %esp, %ebx
    lea 4(%ebx,%eax,4),%ecx
    xor %ebp, %ebp
    and $-16, %esp
    sub $4, %esp
    push %ecx
    push %ebx
    push %eax
    call main
    mov %eax, %ebx
    movl $1, %eax
    int $0x80

