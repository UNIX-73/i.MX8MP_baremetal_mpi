#pragma once
#include <lib/stdint.h>

#include "kernel/panic.h"

static inline size_t align_up(size_t x, size_t a)
{
    DEBUG_ASSERT((a & (a - 1)) == 0, "can only align powers of 2");
    return (x + a - 1) & ~(a - 1);
}

static inline size_t align_down(size_t x, size_t a)
{
    DEBUG_ASSERT((a & (a - 1)) == 0, "can only align powers of 2");
    return x & ~(a - 1);
}

// https://en.wikipedia.org/wiki/Offsetof
#define offsetof(st, m) __builtin_offsetof(st, m)