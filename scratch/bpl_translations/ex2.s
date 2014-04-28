	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.align	4, 0x90
_f:
	pushq	%rbp				# push old fp onto the stack
	movq	%rsp, %rbp			# set the new fp
	subq	$0, %rsp			# allocate 0 local variables

	movq	$0, %rax			# evaluate 0
	pushq	%rax				# push 0 onto stack
	movq	16(%rbp), %rax			# load n into rax
	cmpq	(%rsp), %rax			# compare rax with top of stack
	je	.L2.if
.L1.else:
	movq	$1, %rax			# evaluate 1
	pushq	%rax				# push 1 onto stack
	movq	16(%rbp), %rax			# load n into rax
	subq	(%rsp), %rax			# subtrack top of stack from rax
	addq	$8, %rsp			# pop 1 off of stack
	pushq	%rax				# push arg n-1 onto stack
	callq	_f				# call f
	addq	$8, %rsp			# pop 1 arg off of stack
	pushq	%rax				# push f(n-1) onto stack
	movq	16(%rbp), %rax			# load n into rax
	imulq	(%rsp), %rax			# multiply top of stack into rax
	addq	$8, %rsp			# pop f(n-1)
	jmp	.L3.follow
.L2.if:
	movq	$1, %rax			# load 1 into rax for return
.L3.follow:
	# TODO how do we deal with nested returns like this?
	addq	$8, %rsp			# pop 0 off of stack
	popq	%rbp				# restore old fp
	ret

_main:
	pushq	%rbp				# push old fp onto the stack
	movq	%rsp, %rbp			# set the new fp
	subq	$0, %rsp			# allocate 0 local variables

	movq	$5, %rax			# evaluate 5
	pushq 	%rax				# push arg 1 onto stack
	callq	_f				# call f
	addq	$8, %rsp			# pop 1 arg off of stack
	movq	%rax, %rsi			# load argument into rsi
	leaq	.WriteIntString(%rip), %rdi	# load formatting string into rdi
	callq	_printf				# call printf

	popq	%rbp				# restore old fp
	ret

	.section	__TEXT,__cstring,cstring_literals
.WriteIntString:
	.asciz "%d "
.WriteStringString:
	.asciz	"%s "
.WritelnString:
	.asciz	"\n"
