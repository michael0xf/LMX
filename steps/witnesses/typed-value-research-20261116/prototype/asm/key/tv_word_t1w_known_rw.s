t1w_known_rw:
	pushq	%rdi
	.seh_pushreg	%rdi
	pushq	%rsi
	.seh_pushreg	%rsi
	pushq	%rbx
	.seh_pushreg	%rbx
	.seh_endprologue
	movq	56(%rcx), %r8
	testq	%r8, %r8
	je	.L30
	movsd	.LC0(%rip), %xmm2
	xorl	%esi, %esi
	xorl	%r8d, %r8d
	movabsq	$-9223372036854775808, %rbx
	.p2align 4,,10
	.p2align 3
.L31:
	xorl	%r11d, %r11d
	cmpq	$0, 16(%rcx)
	je	.L42
	.p2align 4,,10
	.p2align 3
.L41:
	movq	8(%rcx), %rax
	cmpq	$0, 40(%rcx)
	movl	(%rax,%r11,4), %edx
	movq	(%rcx), %rax
	movq	(%rax,%rdx,8), %rax
	movq	20(%rax), %r10
	je	.L33
	xorl	%eax, %eax
	jmp	.L38
	.p2align 4,,10
	.p2align 3
.L49:
	cvttsd2siq	%xmm1, %r9
	addq	%r9, %r8
	addq	$1, %rax
	js	.L36
.L50:
	pxor	%xmm0, %xmm0
	cvtsi2sdq	%rax, %xmm0
	addsd	%xmm1, %xmm0
	movsd	%xmm0, 4(%rdx)
	cmpq	40(%rcx), %rax
	jnb	.L33
.L38:
	movq	24(%rcx), %rdx
	movl	(%rdx,%rax,4), %edx
	movq	(%r10,%rdx,8), %rdx
	movsd	4(%rdx), %xmm1
	comisd	%xmm2, %xmm1
	jb	.L49
	movapd	%xmm1, %xmm0
	subsd	%xmm2, %xmm0
	cvttsd2siq	%xmm0, %r9
	xorq	%rbx, %r9
	addq	%r9, %r8
	addq	$1, %rax
	jns	.L50
.L36:
	movq	%rax, %r9
	movq	%rax, %rdi
	pxor	%xmm0, %xmm0
	shrq	%r9
	andl	$1, %edi
	orq	%rdi, %r9
	cvtsi2sdq	%r9, %xmm0
	addsd	%xmm0, %xmm0
	addsd	%xmm1, %xmm0
	movsd	%xmm0, 4(%rdx)
	cmpq	40(%rcx), %rax
	jb	.L38
.L33:
	cmpq	$0, 48(%rcx)
	je	.L39
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L40:
	movq	32(%rcx), %rdx
	movl	(%rdx,%rax,4), %edx
	addq	$1, %rax
	movq	(%r10,%rdx,8), %r9
	movq	4(%r9), %rdx
	addq	%rdx, %r8
	addq	%rax, %rdx
	movq	%rdx, 4(%r9)
	cmpq	48(%rcx), %rax
	jb	.L40
.L39:
	addq	$1, %r11
	cmpq	16(%rcx), %r11
	jb	.L41
.L42:
	addq	$1, %rsi
	cmpq	56(%rcx), %rsi
	jb	.L31
.L30:
	movq	%r8, %rax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.seh_endproc
