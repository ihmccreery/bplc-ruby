# print "hello", then print "hello again 2", to make use of printf arguments

	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.align	4, 0x90
_main:
	pushq	%rbp			# push old fp onto the stack
	movq	%rsp, %rbp		# set the new fp
	leaq	L_.str0(%rip), %rdi	# load string to be printed into rax
	callq	_printf			# call printf
	leaq	L_.str1(%rip), %rdi	# load string to be printed into rax
	movq	$2, %rsi		# load argument of 2 to be printed
	callq	_printf			# call printf
	popq	%rbp			# restore old fp
	ret

	.section	__TEXT,__cstring,cstring_literals
L_.str0:
	.asciz	"hello\n"
L_.str1:
	.asciz	"hello again %d\n"
