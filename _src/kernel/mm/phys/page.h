#pragma once
#include <lib/stdint.h>


typedef struct
{
    uint32 test;
} mm_page;


#define UNINIT_PAGE \
    (mm_page)       \
    {               \
        .test = 0,  \
    }