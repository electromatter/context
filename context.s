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
	movq %rdx, -16(%rbp)
	movq %rsi, %rsp
	call .L1
	movq -16(%rbp), %rcx
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
	movq %rdi, %rax
	movq %rdx, -16(%rbp)
	movq %rsi, %rsp
	call .L3
	movq -16(%rbp), %rcx
	movq %rdx, (%rcx)
	leave
	ret
.L3:
	pushq %rbp
	movq (%rdx), %rbp
	leave
	ret

/* void *leave_context(void *arg, void *top); */
leave_context:
	pushq %rbp
	movq %rdi, %rax
	movq %rsp, %rdx
	leaq -16(%rsi), %rbp
	leave
	ret
