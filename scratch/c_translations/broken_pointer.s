	.section	__TEXT,__text,regular,pure_instructions
	.globl	_f
	.align	4, 0x90
_f:                                     ## @f
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
	movl	$0, -4(%rbp)
	movl	-4(%rbp), %eax
	addl	-4(%rbp), %eax
	movl	%eax, -4(%rbp)
	popq	%rbp
	ret
	.cfi_endproc

	.globl	_set_X
	.align	4, 0x90

_set_X:                                 ## @set_X
	.cfi_startproc
## BB#0:
	pushq	%rbp
Ltmp7:
	.cfi_def_cfa_offset 16
Ltmp8:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp9:
	.cfi_def_cfa_register %rbp
	movq	_X@GOTPCREL(%rip), %rax
	leaq	-4(%rbp), %rcx
	movl	$5, -4(%rbp)
	movq	%rcx, (%rax)
	popq	%rbp
	ret
	.cfi_endproc

	.globl	_main
	.align	4, 0x90

_main:                                  ## @main
	.cfi_startproc
## BB#0:
	pushq	%rbp
Ltmp12:
	.cfi_def_cfa_offset 16
Ltmp13:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp14:
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	movl	%edi, -4(%rbp)
	movq	%rsi, -16(%rbp)
	callq	_set_X

	leaq	L_.str(%rip), %rdi
	movq	_X@GOTPCREL(%rip), %rsi
	movq	(%rsi), %rsi
	movl	(%rsi), %esi
	movb	$0, %al
	callq	_printf
	movl	$0, %esi
	movl	%eax, -20(%rbp)         ## 4-byte Spill
	movl	%esi, %eax
	addq	$32, %rsp
	popq	%rbp
	ret
	.cfi_endproc

	.comm	_X,8,3                  ## @X
	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"%d\n"


.subsections_via_symbols
