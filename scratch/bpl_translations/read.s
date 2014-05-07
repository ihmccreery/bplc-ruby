	.section	__TEXT,__text,regular,pure_instructions 
	.globl	_main 
	.align	4,0x90 

_main:
	pushq	%rbp # push old fp onto stack
	pushq	%rbx # push old rbx onto stack
	movq	%rsp, %rbp # setup new fp
	addq	$-8, %rsp # allocate local variables

	# read into rax
	movq	%rsp, %rbx # store rsp in rbx
	pushq	$0 # push an empty byte on the stack to allocate space for the old stack pointer
	andq	$-16, %rsp # align the stack to 16 bytes
	movq	%rbx, (%rsp) # move rbx (the old stack pointer,) into allocated space on the stack

	subq	$16, %rsp # allocate two quadwords for scanf, (to keep alignment)
	leaq	(%rsp), %rsi # put scanf storage location into rsi
	leaq	.ReadString(%rip), %rdi # load int formatting string into rdi

	callq	_scanf # call scanf

	popq	%rax # pop storage location into rax
	addq	$8, %rsp # deallocate the extra space we pushed onto the stack

	popq	%rsp # pop old stack pointer as it was before the stack alignment
	# end read into rax

	movq	%rax, -8(%rbp) # x = rax

	movq	-8(%rbp), %rax # move x into rax
	movq	%rax, %rsi # load rax into rsi
	leaq	.WriteIntString(%rip), %rdi # load int formatting string into rdi

	movq	%rsp, %rbx # store rsp in rbx
	pushq	$0 # push an empty byte on the stack to allocate space for the old stack pointer
	andq	$-16, %rsp # align the stack to 16 bytes
	movq	%rbx, (%rsp) # move rbx (the old stack pointer,) into allocated space on the stack
	callq	_printf # call printf
	popq	%rsp # pop old stack pointer as it was before the stack alignment

.return_main:
	subq	$-8, %rsp # deallocate local variables
	popq	%rbx # restore old rbx from stack
	popq	%rbp # restore old fp from stack
	ret	 

	.section	__TEXT,__cstring,cstring_literals 
.ReadString:
	.asciz	"%d" 
.WriteIntString:
	.asciz	"%lld " 
.WriteStringString:
	.asciz	"%s " 
.WritelnString:
	.asciz	"\n" 
