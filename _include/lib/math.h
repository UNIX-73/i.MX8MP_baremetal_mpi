#pragma once

#include <lib/stdint.h>


static inline uint64 u64log2_floor(uint64 x)
{
    uint64 r = 0;
    while (x >>= 1)
        r++;
    return r;
}


static inline uint32 u32log2_floor(uint32 x)
{
    uint32 r = 0;
    while (x >>= 1)
        r++;
    return r;
}


static inline uint64 max(uint64 a, uint64 b)
{
    return a > b ? a : b;
}


static inline uint64 min(uint64 a, uint64 b)
{
    return a < b ? a : b;
}
