.section .text
.weak  _start
_start:
    pop %rdi
    mov %rsp, %rsi
    lea 8(%rsi,%rdi,8),%rdx
    xor %ebp, %ebp
    and $-16, %rsp
    call main
    mov %eax, %edi
    mov $60, %eax
    syscall

