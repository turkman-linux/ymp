.global _start
.section .note.GNU-stack
.section .text
_start:
	popq	%rdi
	movq	%rsp, %rsi
	movq	8(%rsp, %rdi, 8), %rdx
	call	_libc_start

