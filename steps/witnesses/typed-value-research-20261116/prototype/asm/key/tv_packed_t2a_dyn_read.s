t2a_dyn_read:
	pushq	%rbp
	.seh_pushreg	%rbp
	pushq	%rdi
	.seh_pushreg	%rdi
	pushq	%rsi
	.seh_pushreg	%rsi
	pushq	%rbx
	.seh_pushreg	%rbx
	.seh_endprologue
	movq	48(%rcx), %rbp
	testq	%rbp, %rbp
	je	.L213
	movq	40(%rcx), %r10
	testq	%r10, %r10
	je	.L213
	movq	8(%rcx), %rsi
	leaq	.L204(%rip), %r9
	xorl	%edi, %edi
	xorl	%r8d, %r8d
	movq	16(%rcx), %rbx
	movq	24(%rcx), %r11
	.p2align 4,,10
	.p2align 3
.L211:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L210:
	movl	(%rbx,%rax,4), %edx
	movl	(%r11,%rax,4), %ecx
	movq	(%rsi,%rdx,8), %rdx
	movq	20(%rdx), %rdx
	movq	(%rdx,%rcx,8), %rcx
	movzbl	(%rcx), %edx
	cmpl	$8, %edx
	ja	.L214
	movslq	(%r9,%rdx,4), %rdx
	addq	%r9, %rdx
	jmp	*%rdx
	.section .rdata,"dr"
	.align 4
.L204:
	.long	.L214-.L204
	.long	.L209-.L204
	.long	.L208-.L204
	.long	.L207-.L204
	.long	.L206-.L204
	.long	.L205-.L204
	.long	.L214-.L204
	.long	.L214-.L204
	.long	.L203-.L204
	.text
	.p2align 4,,10
	.p2align 3
.L203:
	movl	8(%rcx), %edx
	addq	$7, %rdx
	.p2align 4,,10
	.p2align 3
.L202:
	addq	$1, %rax
	addq	%rdx, %r8
	cmpq	%rax, %r10
	jne	.L210
	addq	$1, %rdi
	cmpq	%rdi, %rbp
	jne	.L211
	movq	%r8, %rax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L205:
	movq	20(%rcx), %rdx
	movq	12(%rcx), %rcx
	movq	(%rdx), %rdx
	leaq	(%rcx,%rcx,4), %rcx
	movl	4(%rdx), %edx
	addq	%rcx, %rdx
	jmp	.L202
	.p2align 4,,10
	.p2align 3
.L206:
	movq	4(%rcx), %rcx
	movl	$3, %edx
	cmpb	$1, (%rcx)
	jne	.L202
	movl	4(%rcx), %edx
	addq	$11, %rdx
	jmp	.L202
	.p2align 4,,10
	.p2align 3
.L207:
	movq	4(%rcx), %rdx
	jmp	.L202
	.p2align 4,,10
	.p2align 3
.L208:
	cvttsd2siq	4(%rcx), %rdx
	jmp	.L202
	.p2align 4,,10
	.p2align 3
.L209:
	movl	4(%rcx), %edx
	jmp	.L202
	.p2align 4,,10
	.p2align 3
.L214:
	movl	$2989, %edx
	jmp	.L202
.L213:
	xorl	%r8d, %r8d
	movq	%r8, %rax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	ret
	.seh_endproc
