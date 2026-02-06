#pragma once
#include <lib/stdint.h>

static inline size_t align_up(size_t x, size_t a)
{
    return (x + a - 1) & ~(a - 1);
}

// https://en.wikipedia.org/wiki/Offsetof
#define offsetof(st, m) __builtin_offsetof(st, m)