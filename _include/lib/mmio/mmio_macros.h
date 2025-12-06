#pragma once

#include <lib/mmio/mmio_regs.h>
#include <lib/stdint.h>

#define MMIO_DECLARE_REG32_VALUE_STRUCT(RegValueStructName) \
	typedef struct {                                        \
		uint32 val;                                         \
	} RegValueStructName;

// Register getters

#define MMIO_DECLARE_REG32_GETTER(periph_name, reg_name, RegValueStruct, addr) \
	static inline RegValueStruct periph_name##_##reg_name##_read()             \
	{                                                                          \
		return (RegValueStruct){.val = *((reg32_ptr)(addr))};                  \
	}

#define MMIO_DECLARE_REG32_GETTER_WITH_BASE(periph_name, reg_name,           \
											RegValueStruct, offset)          \
	static inline RegValueStruct periph_name##_##reg_name##_read(            \
		uintptr periph_base)                                                 \
	{                                                                        \
		return (RegValueStruct){.val =                                       \
									*((reg32_ptr)(periph_base + (offset)))}; \
	}

// Register setters

#define MMIO_DECLARE_REG32_SETTER(periph_name, reg_name, RegValueStruct, addr) \
	static inline void periph_name##_##reg_name##_write(RegValueStruct v)      \
	{                                                                          \
		*((reg32_ptr)(addr)) = v.val;                                          \
	}

#define MMIO_DECLARE_REG32_SETTER_WITH_BASE(periph_name, reg_name,           \
											RegValueStruct, offset)          \
	static inline void periph_name##_##reg_name##_write(uintptr periph_base, \
														RegValueStruct v)    \
	{                                                                        \
		*((reg32_ptr)(periph_base + (offset))) = v.val;                      \
	}

// Bit field getters

#define MMIO_DECLARE_BIT_FIELD_GETTER(periph_name, reg_name, bf_name, \
									  RegValueStruct, T, SHIFT, MASK) \
	static inline T periph_name##_##reg_name##_BF_get_##bf_name(      \
		const RegValueStruct r)                                       \
	{                                                                 \
		_Static_assert((MASK >> SHIFT) << SHIFT == MASK,              \
					   "MASK/SHIFT mismatch");                        \
		return (T)((r.val & MASK) >> SHIFT);                          \
	}

#define MMIO_DECLARE_BIT_FIELD_SETTER(periph_name, reg_name, bf_name, \
									  RegValueStruct, T, SHIFT, MASK) \
	static inline void periph_name##_##reg_name##_BF_set_##bf_name(   \
		RegValueStruct *r, T v)                                       \
	{                                                                 \
		_Static_assert((MASK >> SHIFT) << SHIFT == MASK,              \
					   "MASK/SHIFT mismatch");                        \
		r->val = (r->val & ~MASK) | (((uint32)v << SHIFT) & MASK);    \
	}
