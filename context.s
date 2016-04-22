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

	.globl reset_context
	.globl enter_context
	.globl leave_context

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
	pushq %rbp
	movq %rsp, %rbp
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

/* void *enter_context(void *arg, void *top, void **sp); */
enter_context:
	pushq %rbp
	movq %rsp, %rbp
	movq %rbx, -8(%rsp)
	movq %r12, -16(%rsp)
	movq %r13, -24(%rsp)
	movq %r14, -32(%rsp)
	movq %r15, -40(%rsp)
	movq %rdx, -48(%rsp)
	movq %rdi, %rax
	movq %rsi, %rsp
	call .L4
	movq -48(%rbp), %rcx
	movq -40(%rbp), %r15
	movq -32(%rbp), %r14
	movq -24(%rbp), %r13
	movq -16(%rbp), %r12
	movq -8(%rbp), %rbx
	movq %rdx, (%rcx)
	leave
	ret
.L4:
	pushq %rbp
	movq (%rdx), %rbp
	movq -40(%rbp), %r15
	movq -32(%rbp), %r14
	movq -24(%rbp), %r13
	movq -16(%rbp), %r12
	movq -8(%rbp), %rbx
	leave
	ret

/* void *leave_context(void *arg, void *top); */
leave_context:
	pushq %rbp
	movq %rbx, -8(%rsp)
	movq %r12, -16(%rsp)
	movq %r13, -24(%rsp)
	movq %r14, -32(%rsp)
	movq %r15, -40(%rsp)
	movq %rsp, %rdx
	movq %rdi, %rax
	leaq -16(%rsi), %rsp
	leave
	ret
