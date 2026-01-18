#pragma once

#include <lib/stdint.h>

// phys address uintptr
typedef uintptr p_uintptr;
// virt address uintptr
typedef uintptr v_uintptr;


#define uintptr_p_to_ptr(type, uintptr_phys) ((type*)(uintptr_phys))
#define PTR_TO_UINTPTR_P(ptr) ((p_uintptr)(ptr))

#define UINTPTR_V_TO_PTR(type, uintptr_virt) ((type*)(uintptr_virt))
#define PTR_TO_UINTPTR_V(ptr) ((v_uintptr)(ptr))