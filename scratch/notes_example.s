.section .rodata
#.WriteIntString: .string "%d "
#.WritelnString: .string "\n"
#.text
#.globl main
#f:
#	movq %rsp, %rbx
#	movq 16(%rbx), %rax
#	imul $2, %eax
#	ret
#main:
#	movq %rsp, %rbx
#	sub $8, %rsp
#	movl $0, %eax
#	movl %eax, -8(%rbx)
#.L0:
#	cmpl $10, -8(%rbx)
#	jge .L1
#	movl -8(%rbx), %esi
#	movq $.WriteIntString, %rdi
#	movl $0, %eax
#	call printf
#	push -8(%rbx)
#	push %rbx
#	call f
#	pop %rbx
#	add $8, %rsp
#	movl %eax, %esi
#	movq $.WriteIntString, %rdi
#	movl $0, %eax
#	call printf
#	movl -8(%rbx), %eax
#	addl $1, %eax
#	movl %eax, -8(%rbx)
#	jmp .L0
#.L1:
#	add $8, %rsp
#	ret
