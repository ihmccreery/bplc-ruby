	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## BB#0:
	pushq	%rbp
Ltmp2:
	.cfi_def_cfa_offset 16
Ltmp3:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp4:
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	leaq	L_.str(%rip), %rax
	movq	_X@GOTPCREL(%rip), %rcx
	movq	_Y@GOTPCREL(%rip), %rdx
	movl	$0, -4(%rbp)
	movl	%edi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movl	$100, (%rcx)
	movl	$200, (%rdx)
	movl	(%rdx), %esi
	movl	(%rcx), %edx
	movq	%rax, %rdi
	movb	$0, %al
	callq	_printf
	movl	$0, %edx
	movl	%eax, -20(%rbp)         ## 4-byte Spill
	movl	%edx, %eax
	addq	$32, %rsp
	popq	%rbp
	ret
	.cfi_endproc

	.comm	_X,4,2                  ## @X
	.comm	_Y,40,4                 ## @Y
	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"%d %d\n"


.subsections_via_symbols
