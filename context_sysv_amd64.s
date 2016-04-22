/* context.s - C coroutines for x86_64
 *
 * Copyright (c) 2016, Eric Chai <electromatter@gmail.com>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

	.text

	.p2align 4,,15
	.globl reset_context
	.type reset_context, @function
/* void reset_context(void *(*func)(void *arg), void *top, void **sp); */
reset_context:
	pushq %rbp
	movq %rsp, %rbp
	movq %rdx, -8(%rsp)
	movq %rsi, %rsp
	call .L1
	movq -8(%rbp), %rcx
	movq %rdx, (%rcx)
	leave
	ret
.L1:
	.cfi_startproc

	pushq %rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp,-16
	movq %rsp, %rbp
	.cfi_def_cfa_register rbp

	subq $8, %rsp
	pushq %rdi
.L2:
	leaq 32(%rsp), %rsi
	call leave_context
	movq %rax, %rdi
	movq (%rsp), %rcx
	callq *%rcx
	movq %rax, %rdi
	jmp .L2
	.cfi_endproc

	.p2align 4,,15
	.globl enter_context
	.type enter_context, @function
/* void *enter_context(void *arg, void *top, void **sp); */
enter_context:
	.cfi_startproc

	pushq %rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp,-16
	movq %rsp, %rbp
	.cfi_def_cfa_register rbp

	movq %rbx, -8(%rbp)
	.cfi_offset rbx,-24
	movq %r12, -16(%rbp)
	.cfi_offset r12,-32
	movq %r13, -24(%rbp)
	.cfi_offset r13,-40
	movq %r14, -32(%rbp)
	.cfi_offset r14,-48
	movq %r15, -40(%rbp)
	.cfi_offset r15,-56
	fstcw -48(%rbp)
	.cfi_offset fcw,-64
	stmxcsr -56(%rbp)
	.cfi_offset mxcsr,-72
	movq %rdx, -64(%rbp)

	movq %rdi, %rax
	movq %rsi, %rsp
	call .L3

	movq -64(%rbp), %rcx
	ldmxcsr -56(%rbp)
	.cfi_restore mxcsr
	fldcw -48(%rbp)
	.cfi_restore fcw
	movq -40(%rbp), %r15
	.cfi_restore r15
	movq -32(%rbp), %r14
	.cfi_restore r14
	movq -24(%rbp), %r13
	.cfi_restore r13
	movq -16(%rbp), %r12
	.cfi_restore r12
	movq -8(%rbp), %rbx
	.cfi_restore rbx

	movq %rdx, (%rcx)

	leave
	.cfi_def_cfa rsp, 8
	ret
	.cfi_endproc
.L3:
	pushq %rbp
	movq (%rdx), %rbp
	ldmxcsr -56(%rbp)
	fldcw -48(%rbp)
	movq -40(%rbp), %r15
	movq -32(%rbp), %r14
	movq -24(%rbp), %r13
	movq -16(%rbp), %r12
	movq -8(%rbp), %rbx
	leave
	ret

	.p2align 4,,15
	.globl leave_context
	.type leave_context, @function
/* void *leave_context(void *arg, void *top); */
leave_context:
	pushq %rbp
	movq %rbx, -8(%rsp)
	movq %r12, -16(%rsp)
	movq %r13, -24(%rsp)
	movq %r14, -32(%rsp)
	movq %r15, -40(%rsp)
	fstcw -48(%rsp)
	stmxcsr -56(%rsp)
	movq %rsp, %rdx
	movq %rdi, %rax
	leaq -16(%rsi), %rbp
	leave
	ret
