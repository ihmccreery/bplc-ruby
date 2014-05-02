	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.align	4, 0x90

_main:
	pushq	%rbp				# push old fp onto the stack
	movq	%rsp, %rbp			# set the new fp
	addq	$-32, %rsp			# allocate 3 local variables

	movq	$5, %rax			# eval 5
	movq	%rax, -8(%rbp)			# x = 5
	movq	$5, -8(%rbp)			# eval 5

	movq	$7, %rax			# eval 7
	movq	%rax, -16(%rbp)			# x = 7

	movq	-8(%rbp), %rax			# eval x
	pushq	%rax				# push x onto stack
	movq	-16(%rbp), %rax			# eval y
	addq	(%rsp), %rax			# add x to y
	addq	$8, %rsp			# pop x off of stack
	movq	%rax, -24(%rbp)			# z = rax

	movq	-8(%rbp), %rax			# load x into rax
	movq	%rax, %rsi			# load argument into rsi
	leaq	.WriteIntString(%rip), %rdi	# load formatting string into rdi
	callq	_printf				# call printf

	movq	-16(%rbp), %rax			# load y into rax
	movq	%rax, %rsi			# load argument into rsi
	leaq	.WriteIntString(%rip), %rdi	# load formatting string into rdi
	callq	_printf				# call printf

	movq	-24(%rbp), %rax			# load z into rax
	movq	%rax, %rsi			# load argument into rsi
	leaq	.WriteIntString(%rip), %rdi	# load formatting string into rdi
	callq	_printf				# call printf

	leaq	.WritelnString(%rip), %rdi	# load formatting string into rdi
	callq	_printf				# call printf

	subq	$-32, %rsp			# allocate 3 local variables
	popq	%rbp				# restore old fp
	ret

	.section	__TEXT,__cstring,cstring_literals
.WriteIntString:
	.asciz "%d "
.WriteStringString:
	.asciz	"%s "
.WritelnString:
	.asciz	"\n"
