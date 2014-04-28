# a translation of Bob's example using .asciz, RIP, and callq instructions

	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.align	4, 0x90
f:
	movq %rsp, %rbx
	movq 16(%rbx), %rax
	imul $2, %eax
	ret
_main:
	movq %rsp, %rbx
	sub $8, %rsp
	movl $0, %eax
	movl %eax, -8(%rbx)
.L0:
	cmpl $10, -8(%rbx)
	jge .L1
	movl -8(%rbx), %esi
	leaq .WriteIntString(%rip), %rdi
	movl $0, %eax
	callq _printf
	push -8(%rbx)
	push %rbx
	call f
	pop %rbx
	add $8, %rsp
	movl %eax, %esi
	leaq .WriteIntString(%rip), %rdi
	movl $0, %eax
	callq _printf
	movl -8(%rbx), %eax
	addl $1, %eax
	movl %eax, -8(%rbx)
	jmp .L0
.L1:
	add $8, %rsp
	ret

	.section	__TEXT,__cstring,cstring_literals
.WriteIntString:
	.asciz "%d "
.WritelnString:
	.asciz	"\n"
