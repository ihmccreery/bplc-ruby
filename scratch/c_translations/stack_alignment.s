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
	movl	%edi, -4(%rbp)
	movl	-4(%rbp), %edi
	imull	-4(%rbp), %edi
	movl	%edi, %eax
	popq	%rbp
	ret
	.cfi_endproc

	.globl	_main
	.align	4, 0x90
_main:                                  ## @main
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
	subq	$32, %rsp
	movl	$2, %eax
	movl	$0, -4(%rbp)
	movl	%edi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movl	%eax, %edi
	callq	_f
	movl	$3, %edi
	movl	%eax, -24(%rbp)         ## 4-byte Spill
	callq	_f
	movl	$4, %edi
	movl	-24(%rbp), %ecx         ## 4-byte Reload
	addl	%eax, %ecx
	movl	%ecx, -28(%rbp)         ## 4-byte Spill
	callq	_f
	leaq	L_.str(%rip), %rdi
	movl	-28(%rbp), %ecx         ## 4-byte Reload
	imull	%eax, %ecx
	movl	%ecx, -20(%rbp)
	movl	-20(%rbp), %esi
	movb	$0, %al
	callq	_printf
	movl	$0, %ecx
	movl	%eax, -32(%rbp)         ## 4-byte Spill
	movl	%ecx, %eax
	addq	$32, %rsp
	popq	%rbp
	ret
	.cfi_endproc

	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"%d\n"


.subsections_via_symbols
