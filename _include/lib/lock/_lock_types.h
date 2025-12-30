#pragma once

#include <lib/stdbool.h>
#include <lib/stdint.h>

typedef struct {
	// 0 free / 1 locked
	volatile uint32 slock;
} spinlock_t;

typedef struct {
	uint64 flags;
} irqlock_t;
