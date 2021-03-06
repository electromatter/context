/* context.h - C(++) coroutines
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
 *
 * sysv_amd64:
 *  - Stacks on should be aligned to 16-bytes on x86_64.
 *  - The initial stack uses 32 bytes before calling func
 *  - Calls to leave_context use an additional 64 bytes (saved %rip and %rbp)
 *      within the context
 *  - A red zone of 128 bytes past the maximum push depth must be usable
 *  - Stack should also be large enough to handle signals or one should
 *      use sigaltstack to set the signal handler stack
 *
 * A context is defined as a stack together with a saved stack pointer.
 *
 * A context is active if it is part of the current stack, that is
 * if the program has called enter_context, and there is no corresponding
 * leave_context call.
 *
 * The first call to enter_context to a freshly reset context will
 * call func with arg with the stack of the context.
 *
 * The type of values passed via enter_context may need to be volatile to
 * prevent the optimizer from reordering accesses across leave_context calls.
 * This includes the argument to func.
 *
 * The return value of func is passed back to the parent context as
 * if leave_context(<return value>, top) were called. The context is
 * left in the reset state.
 *
 * It is safe to reset a context that has a non-empty stack, so long
 * as it is not active, but it may cause resource leaks if there are
 * any non trivial values that exist on the context's stack.
 *
 * One way to force the stack to unwind in C++ is to use call_context with a
 * stub function that throws an uncaught exceptions and catch the exception
 * outside of call_context.
 *
 * It is safe to chain contexts, so long as one does not create loops.
 *
 * It is also safe to use leave_context from within the function called
 * by call_context.
 *
 * Uncaught C++ exceptions from within an active context are passed
 * to the parent context. The originating context's stack will be
 * properly unwound, however it will be left in an inconsistent state.
 * One must use reset_context to bring the context into a known state again.
 */

#ifndef CONTEXT_H
#define CONTEXT_H

#ifdef __cplusplus
extern "C" {
#endif

/* (Re-)initialize a context for use */
void reset_context(void *(*func)(void *arg), void *top, void **sp);
/* Returns arg from the previous leave_context */
void *enter_context(void *arg, void *top, void **sp);
/* Returns func(arg) from the previous leave_context */
void *call_context(void *arg, void *top, void **sp, void *(*func)(void *arg));

/* Returns arg from the parent enter_context */
void *leave_context(void *arg, void *top);

#ifdef __cplusplus
}
#endif

#endif
