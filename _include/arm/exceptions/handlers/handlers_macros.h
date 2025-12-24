#pragma once

#include <boot/panic.h>

/// Declares a non implemented EL2 exception handler, panics with the name of
/// the exception
#define DECLARE_EL2_EXCEPTION_HANDLER_PANIC(origin, stack, type) \
	void el2_##origin##_##stack##_##type##_handler(void)         \
	{                                                            \
		set_and_throw_panic((panic_info){                         \
			.message = "EL2 EXCEPTION! " #origin #stack #type,   \
			.location =                                          \
				(panic_location){                                 \
					.file = __FILE__,                            \
					.line = __LINE__,                            \
					.col = 0,                                    \
				},                                               \
			.panic_reason = PANIC_REASON_EXCEPTION,              \
		});                                                      \
	}

/// Declares a non implemented EL1 exception handler, panics with the name of
/// the exception
#define DECLARE_EL1_EXCEPTION_HANDLER_PANIC(origin, stack, type) \
	void el1_##origin##_##stack##_##type##_handler(void)         \
	{                                                            \
		set_and_throw_panic((panic_info){                         \
			.message = "EL1 EXCEPTION! " #origin #stack #type,   \
			.location =                                          \
				(panic_location){                                 \
					.file = __FILE__,                            \
					.line = __LINE__,                            \
					.col = 0,                                    \
				},                                               \
			.panic_reason = PANIC_REASON_EXCEPTION,              \
		});                                                      \
	}
