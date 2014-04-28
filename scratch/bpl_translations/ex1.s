	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.align	4, 0x90
_main:
	pushq	%rbp				# push old fp onto the stack
	movq	%rsp, %rbp			# set the new fp
	sub $0, %rsp				# allocate 0 local variables
	leaq	.str0(%rip), %rsi		# load argument into rsi
	leaq	.WriteStringString(%rip), %rdi	# load formatting string into rdi
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
.str0:
	.asciz	"Hi, Bob!"
