#pragma once

#include <kernel/panic.h>

/// Declares a non implemented EL2 exception handler, panics with the name of
/// the exception
#define DECLARE_EL2_EXCEPTION_HANDLER_PANIC(origin, stack, type) \
	void el2_##origin##_##stack##_##type##_handler(void)         \
	{                                                            \
		PANIC("EL2 EXCEPTION! " #origin "_" #stack "_" #type);   \
	}

/// Declares a non implemented EL1 exception handler, panics with the name of
/// the exception
#define DECLARE_EL1_EXCEPTION_HANDLER_PANIC(origin, stack, type) \
	void el1_##origin##_##stack##_##type##_handler(void)         \
	{                                                            \
		PANIC("EL1 EXCEPTION! " #origin #stack #type);           \
	}
