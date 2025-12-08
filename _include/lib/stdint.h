#pragma once

#ifdef _STD_TYPES_T
#error "Used c stdlib stdint implementation instead of baremetal custom stdint"
#else
#define _STD_TYPES_T
#endif

typedef enum {
	STDINT_INT8,
	STDINT_UINT8,
	STDINT_INT16,
	STDINT_UINT16,
	STDINT_INT32,
	STDINT_UINT32,
	STDINT_INT64,
	STDINT_UINT64,
} STDINT_TYPES;

typedef enum {
	STDINT_REPR_DEC = 10,
	STDINT_REPR_HEX = 16,
	STDINT_REPR_BIN = 2,
	STDINT_REPR_OCT = 8,
} STDINT_REPR;

typedef signed char int8;
typedef unsigned char uint8;

typedef signed short int16;
typedef unsigned short uint16;

typedef signed int int32;
typedef unsigned int uint32;

typedef signed long long int64;
typedef unsigned long long uint64;

#pragma once

#if __SIZEOF_POINTER__ == 4
typedef int intptr;
typedef unsigned int uintptr;

#elif __SIZEOF_POINTER__ == 8
#if __SIZEOF_LONG__ == 8
typedef long intptr;
typedef unsigned long uintptr;
#else
typedef long long intptr;
typedef unsigned long long uintptr;
#endif

#else
#error "Unsupported pointer size"
#endif

#define INT8_MIN (-128)
#define INT8_MAX 127
#define UINT8_MAX 255U

#define INT16_MIN (-32768)
#define INT16_MAX 32767
#define UINT16_MAX 65535U

#define INT32_MIN (-2147483647 - 1)
#define INT32_MAX 2147483647
#define UINT32_MAX 4294967295U

#define INT64_MIN (-9223372036854775807LL - 1LL)
#define INT64_MAX 9223372036854775807LL
#define UINT64_MAX 18446744073709551615ULL

#define INT_LEAST8_MIN INT8_MIN
#define INT_LEAST8_MAX INT8_MAX
#define UINT_LEAST8_MAX UINT8_MAX

#define INT_LEAST16_MIN INT16_MIN
#define INT_LEAST16_MAX INT16_MAX
#define UINT_LEAST16_MAX UINT16_MAX

#define INT_LEAST32_MIN INT32_MIN
#define INT_LEAST32_MAX INT32_MAX
#define UINT_LEAST32_MAX UINT32_MAX

#define INT_LEAST64_MIN INT64_MIN
#define INT_LEAST64_MAX INT64_MAX
#define UINT_LEAST64_MAX UINT64_MAX

#define INT_FAST8_MIN INT32_MIN
#define INT_FAST8_MAX INT32_MAX
#define UINT_FAST8_MAX UINT32_MAX

#define INT_FAST16_MIN INT32_MIN
#define INT_FAST16_MAX INT32_MAX
#define UINT_FAST16_MAX UINT32_MAX

#define INT_FAST32_MIN INT32_MIN
#define INT_FAST32_MAX INT32_MAX
#define UINT_FAST32_MAX UINT32_MAX

#define INT_FAST64_MIN INT64_MIN
#define INT_FAST64_MAX INT64_MAX
#define UINT_FAST64_MAX UINT64_MAX

// TODO: acabar estos
#define INTPTR_MIN LONG_MIN
#define INTPTR_MAX LONG_MAX
#define UINTPTR_MAX ULONG_MAX

#define INTMAX_MIN INT64_MIN
#define INTMAX_MAX INT64_MAX
#define UINTMAX_MAX UINT64_MAX

typedef union {
	int8 int8;
	uint8 uint8;

	int16 int16;
	uint16 uint16;

	int32 int32;
	uint32 uint32;

	int64 int64;
	uint64 uint64;
} STDINT_UNION;
