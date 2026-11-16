t1_known_rw:
	pushq	%r15
	.seh_pushreg	%r15
	pushq	%r14
	.seh_pushreg	%r14
	pushq	%r13
	.seh_pushreg	%r13
	pushq	%r12
	.seh_pushreg	%r12
	pushq	%rbp
	.seh_pushreg	%rbp
	pushq	%rdi
	.seh_pushreg	%rdi
	pushq	%rsi
	.seh_pushreg	%rsi
	pushq	%rbx
	.seh_pushreg	%rbx
	.seh_endprologue
	movq	56(%rcx), %r13
	testq	%r13, %r13
	movq	%rcx, %rbp
	je	.L11
	movq	16(%rcx), %rax
	xorl	%r12d, %r12d
	leaq	0(,%rax,4), %rsi
	testq	%rax, %rax
	je	.L29
	movq	8(%rcx), %r14
	xorl	%r8d, %r8d
	movq	(%rcx), %rdi
	movq	40(%rcx), %r9
	addq	%r14, %rsi
	.p2align 4,,10
	.p2align 3
.L16:
	movq	%r14, %rbx
	.p2align 4,,10
	.p2align 3
.L15:
	movl	(%rbx), %eax
	testq	%r9, %r9
	movq	(%rdi,%rax,8), %rax
	movq	20(%rax), %r10
	je	.L13
	movq	24(%rbp), %r11
	movl	$1, %eax
	.p2align 4,,10
	.p2align 3
.L14:
	movl	-4(%r11,%rax,4), %edx
	movq	(%r10,%rdx,8), %rcx
	movl	4(%rcx), %r15d
	movq	%r15, %rdx
	addq	%r15, %r8
	addl	%eax, %edx
	movl	%edx, 4(%rcx)
	movq	%rax, %rdx
	addq	$1, %rax
	cmpq	%rdx, %r9
	jne	.L14
.L13:
	addq	$4, %rbx
	cmpq	%rbx, %rsi
	jne	.L15
	addq	$1, %r12
	cmpq	%r12, %r13
	jne	.L16
.L10:
	movq	%r8, %rax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L29:
	addq	$1, %r12
	cmpq	%r12, %r13
	jne	.L29
.L11:
	xorl	%r8d, %r8d
	jmp	.L10
	.seh_endproc
