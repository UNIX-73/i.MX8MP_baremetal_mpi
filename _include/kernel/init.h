#pragma once

typedef void (*kernel_initcall_t)(void);

#define KERNEL_INITCALL(fn)                  \
	static kernel_initcall_t __initcall_##fn \
		__attribute__((section(".kernel_init"), used)) = fn;

void kernel_init(void);