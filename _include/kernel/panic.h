#pragma once
#include <lib/stdbool.h>
#include <lib/stdint.h>

extern uint64 PANIC_MESSAGE_BUF_SIZE;
extern uint64 PANIC_FILE_BUF_SIZE;

extern uint8 *PANIC_MESSAGE_BUF_PTR;
extern uint8 *PANIC_FILE_BUF_PTR;

extern uint32 PANIC_LINE;
extern uint32 PANIC_COL;

typedef struct {
	char *file;
	uint32 line;
	uint32 col;
} PanicLocation;

typedef struct {
	char *message;
	PanicLocation location;
} PanicInfo;

void init_panic();

void set_panic(PanicInfo panic_info);
_Noreturn void set_and_throw_panic(PanicInfo panic_info);
_Noreturn void panic();

#define PANIC(panic_message)         \
	set_and_throw_panic((PanicInfo){ \
		.message = panic_message,    \
		.location =                  \
			(PanicLocation){         \
				.file = __FILE__,    \
				.line = __LINE__,    \
				.col = 0,            \
			},                       \
	})
