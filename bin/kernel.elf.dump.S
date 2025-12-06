
bin/kernel.elf:     file format elf64-littleaarch64


Disassembly of section .text:

0000000040000000 <_start>:
.section .text.boot
.global _start

_start:
    nop
    40000000:	d503201f 	nop
    // disable irq
    msr daifset, #0xf
    40000004:	d5034fdf 	msr	daifset, #0xf

    // Init EL2 stack
    ldr x0, =__stack_el2_top
    40000008:	580001c0 	ldr	x0, 40000040 <hang+0x8>
    mov sp, x0
    4000000c:	9100001f 	mov	sp, x0
    
    // Init El1 stack
    ldr x0, =__stack_el1_top
    40000010:	580001c0 	ldr	x0, 40000048 <hang+0x10>
    msr SP_EL1, x0
    40000014:	d51c4100 	msr	sp_el1, x0

    // Clean bss
    ldr x1, =_bss_start
    40000018:	580001c1 	ldr	x1, 40000050 <hang+0x18>
    ldr x2, =_bss_end
    4000001c:	580001e2 	ldr	x2, 40000058 <hang+0x20>
1:
    cmp x1, x2
    40000020:	eb02003f 	cmp	x1, x2
    b.eq 2f
    40000024:	54000060 	b.eq	40000030 <_start+0x30>  // b.none
    str xzr, [x1], #8
    40000028:	f800843f 	str	xzr, [x1], #8
    b 1b
    4000002c:	17fffffd 	b	40000020 <_start+0x20>
2:  nop
    40000030:	d503201f 	nop


    bl kernel_entry
    40000034:	9400000e 	bl	4000006c <kernel_entry>

0000000040000038 <hang>:

hang:
    wfe
    40000038:	d503205f 	wfe
    4000003c:	17ffffff 	b	40000038 <hang>
    40000040:	40f01000 	.inst	0x40f01000 ; undefined
    40000044:	00000000 	udf	#0
    40000048:	40a01000 	.inst	0x40a01000 ; undefined
    4000004c:	00000000 	udf	#0
    40000050:	40000930 	.inst	0x40000930 ; undefined
    40000054:	00000000 	udf	#0
    40000058:	40000930 	.inst	0x40000930 ; undefined
    4000005c:	00000000 	udf	#0

0000000040000060 <_currentEL>:
.global _currentEL
.type   _currentEL, %function


_currentEL:
    mrs x0, CurrentEL
    40000060:	d5384240 	mrs	x0, currentel
    lsr x0, x0, #2
    40000064:	d342fc00 	lsr	x0, x0, #2
    ret
    40000068:	d65f03c0 	ret

000000004000006c <kernel_entry>:
#include "lib/stdint.h"

extern uint64 rust_add(uint64 a, uint64 b);

void kernel_entry()
{
    4000006c:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    40000070:	910003fd 	mov	x29, sp
	UART_putc(UART_ID_2, (uint8)(_currentEL() + 48));
    40000074:	97fffffb 	bl	40000060 <_currentEL>
    40000078:	12001c00 	and	w0, w0, #0xff
    4000007c:	1100c000 	add	w0, w0, #0x30
    40000080:	12001c00 	and	w0, w0, #0xff
    40000084:	2a0003e1 	mov	w1, w0
    40000088:	52800020 	mov	w0, #0x1                   	// #1
    4000008c:	9400016a 	bl	40000634 <UART_putc>

	UART_puts(UART_ID_2, "Hello world\n\r");
    40000090:	90000000 	adrp	x0, 40000000 <_start>
    40000094:	91240001 	add	x1, x0, #0x900
    40000098:	52800020 	mov	w0, #0x1                   	// #1
    4000009c:	94000180 	bl	4000069c <UART_puts>

	// UART_reset(UART_ID_2);

	UART_init(UART_ID_2);
    400000a0:	52800020 	mov	w0, #0x1                   	// #1
    400000a4:	940001b8 	bl	40000784 <UART_init>

	//	UART_puts(UART_ID_2, "Hello world :)\n\r");

	FOREVER {}
    400000a8:	d503201f 	nop
    400000ac:	17ffffff 	b	400000a8 <kernel_entry+0x3c>

00000000400000b0 <UART_UBIR_write>:
MMIO_DECLARE_REG32_VALUE_STRUCT(UBIR_VALUE_STRUCT_NAME);

MMIO_DECLARE_REG32_GETTER_WITH_BASE(UART, UBIR, UBIR_VALUE_STRUCT_NAME,
									UART_UBIR_OFFSET);

MMIO_DECLARE_REG32_SETTER_WITH_BASE(UART, UBIR, UBIR_VALUE_STRUCT_NAME,
    400000b0:	d10043ff 	sub	sp, sp, #0x10
    400000b4:	f90007e0 	str	x0, [sp, #8]
    400000b8:	b90003e1 	str	w1, [sp]
    400000bc:	f94007e0 	ldr	x0, [sp, #8]
    400000c0:	91029000 	add	x0, x0, #0xa4
    400000c4:	b94003e1 	ldr	w1, [sp]
    400000c8:	b9000001 	str	w1, [x0]
    400000cc:	910043ff 	add	sp, sp, #0x10
    400000d0:	d65f03c0 	ret

00000000400000d4 <UART_UBIR_BF_set_INC>:
	UART_DECLARE_BIT_FIELD_SETTER(UBIR, bf_name, UBIR_VALUE_STRUCT_NAME, T, \
								  bf_name##_SHIFT, bf_name##_MASK);

#define INC_SHIFT 0
#define INC_MASK (0xFFFF << INC_SHIFT)
    400000d4:	d10043ff 	sub	sp, sp, #0x10
    400000d8:	f90007e0 	str	x0, [sp, #8]
    400000dc:	79000fe1 	strh	w1, [sp, #6]
    400000e0:	f94007e0 	ldr	x0, [sp, #8]
    400000e4:	b9400000 	ldr	w0, [x0]
    400000e8:	12103c01 	and	w1, w0, #0xffff0000
    400000ec:	79400fe0 	ldrh	w0, [sp, #6]
    400000f0:	2a000021 	orr	w1, w1, w0
    400000f4:	f94007e0 	ldr	x0, [sp, #8]
    400000f8:	b9000001 	str	w1, [x0]
    400000fc:	910043ff 	add	sp, sp, #0x10
    40000100:	d65f03c0 	ret

0000000040000104 <UART_UBMR_write>:
MMIO_DECLARE_REG32_VALUE_STRUCT(UBMR_VALUE_STRUCT_NAME);

MMIO_DECLARE_REG32_GETTER_WITH_BASE(UART, UBMR, UBMR_VALUE_STRUCT_NAME,
									UART_UBMR_OFFSET);

MMIO_DECLARE_REG32_SETTER_WITH_BASE(UART, UBMR, UBMR_VALUE_STRUCT_NAME,
    40000104:	d10043ff 	sub	sp, sp, #0x10
    40000108:	f90007e0 	str	x0, [sp, #8]
    4000010c:	b90003e1 	str	w1, [sp]
    40000110:	f94007e0 	ldr	x0, [sp, #8]
    40000114:	9102a000 	add	x0, x0, #0xa8
    40000118:	b94003e1 	ldr	w1, [sp]
    4000011c:	b9000001 	str	w1, [x0]
    40000120:	910043ff 	add	sp, sp, #0x10
    40000124:	d65f03c0 	ret

0000000040000128 <UART_UBMR_BF_set_MOD>:
	UART_DECLARE_BIT_FIELD_SETTER(UBMR, bf_name, UBMR_VALUE_STRUCT_NAME, T, \
								  bf_name##_SHIFT, bf_name##_MASK);

#define MOD_SHIFT 0
#define MOD_MASK (0xFFFF << MOD_SHIFT)
UBMR_DECLARE_BIT_FIELD_FNS(MOD, uint16);
    40000128:	d10043ff 	sub	sp, sp, #0x10
    4000012c:	f90007e0 	str	x0, [sp, #8]
    40000130:	79000fe1 	strh	w1, [sp, #6]
    40000134:	f94007e0 	ldr	x0, [sp, #8]
    40000138:	b9400000 	ldr	w0, [x0]
    4000013c:	12103c01 	and	w1, w0, #0xffff0000
    40000140:	79400fe0 	ldrh	w0, [sp, #6]
    40000144:	2a000021 	orr	w1, w1, w0
    40000148:	f94007e0 	ldr	x0, [sp, #8]
    4000014c:	b9000001 	str	w1, [x0]
    40000150:	910043ff 	add	sp, sp, #0x10
    40000154:	d65f03c0 	ret

0000000040000158 <UART_UCR1_write>:
MMIO_DECLARE_REG32_VALUE_STRUCT(UCR1_VALUE_STRUCT_NAME);

MMIO_DECLARE_REG32_GETTER_WITH_BASE(UART, UCR1, UCR1_VALUE_STRUCT_NAME,
									UART_UCR1_OFFSET);

MMIO_DECLARE_REG32_SETTER_WITH_BASE(UART, UCR1, UCR1_VALUE_STRUCT_NAME,
    40000158:	d10043ff 	sub	sp, sp, #0x10
    4000015c:	f90007e0 	str	x0, [sp, #8]
    40000160:	b90003e1 	str	w1, [sp]
    40000164:	f94007e0 	ldr	x0, [sp, #8]
    40000168:	91020000 	add	x0, x0, #0x80
    4000016c:	b94003e1 	ldr	w1, [sp]
    40000170:	b9000001 	str	w1, [x0]
    40000174:	910043ff 	add	sp, sp, #0x10
    40000178:	d65f03c0 	ret

000000004000017c <UART_UCR1_BF_set_UARTEN>:
								  bf_name##_SHIFT, bf_name##_MASK);

// UARTEN
#define UARTEN_SHIFT 0
#define UARTEN_MASK (0b1 << UARTEN_SHIFT)
UCR1_DECLARE_BIT_FIELD_FNS(UARTEN, bool);
    4000017c:	d10043ff 	sub	sp, sp, #0x10
    40000180:	f90007e0 	str	x0, [sp, #8]
    40000184:	39001fe1 	strb	w1, [sp, #7]
    40000188:	f94007e0 	ldr	x0, [sp, #8]
    4000018c:	b9400000 	ldr	w0, [x0]
    40000190:	121f7801 	and	w1, w0, #0xfffffffe
    40000194:	39401fe0 	ldrb	w0, [sp, #7]
    40000198:	2a000021 	orr	w1, w1, w0
    4000019c:	f94007e0 	ldr	x0, [sp, #8]
    400001a0:	b9000001 	str	w1, [x0]
    400001a4:	910043ff 	add	sp, sp, #0x10
    400001a8:	d65f03c0 	ret

00000000400001ac <UART_UCR2_read>:

#define UCR2_VALUE_STRUCT_NAME UartUcr2Value

MMIO_DECLARE_REG32_VALUE_STRUCT(UCR2_VALUE_STRUCT_NAME);

MMIO_DECLARE_REG32_GETTER_WITH_BASE(UART, UCR2, UCR2_VALUE_STRUCT_NAME,
    400001ac:	d10043ff 	sub	sp, sp, #0x10
    400001b0:	f90007e0 	str	x0, [sp, #8]
    400001b4:	f94007e0 	ldr	x0, [sp, #8]
    400001b8:	91021000 	add	x0, x0, #0x84
    400001bc:	b9400000 	ldr	w0, [x0]
    400001c0:	910043ff 	add	sp, sp, #0x10
    400001c4:	d65f03c0 	ret

00000000400001c8 <UART_UCR2_write>:
									UART_UCR2_OFFSET);

MMIO_DECLARE_REG32_SETTER_WITH_BASE(UART, UCR2, UCR2_VALUE_STRUCT_NAME,
    400001c8:	d10043ff 	sub	sp, sp, #0x10
    400001cc:	f90007e0 	str	x0, [sp, #8]
    400001d0:	b90003e1 	str	w1, [sp]
    400001d4:	f94007e0 	ldr	x0, [sp, #8]
    400001d8:	91021000 	add	x0, x0, #0x84
    400001dc:	b94003e1 	ldr	w1, [sp]
    400001e0:	b9000001 	str	w1, [x0]
    400001e4:	910043ff 	add	sp, sp, #0x10
    400001e8:	d65f03c0 	ret

00000000400001ec <UART_UCR2_BF_set_CTSC>:
UCR2_DECLARE_BIT_FIELD_FNS(IRTS, bool);

// CTSC
#define CTSC_SHIFT 13
#define CTSC_MASK (0b1 << CTSC_SHIFT)
UCR2_DECLARE_BIT_FIELD_FNS(CTSC, bool);
    400001ec:	d10043ff 	sub	sp, sp, #0x10
    400001f0:	f90007e0 	str	x0, [sp, #8]
    400001f4:	39001fe1 	strb	w1, [sp, #7]
    400001f8:	f94007e0 	ldr	x0, [sp, #8]
    400001fc:	b9400000 	ldr	w0, [x0]
    40000200:	12127801 	and	w1, w0, #0xffffdfff
    40000204:	39401fe0 	ldrb	w0, [sp, #7]
    40000208:	53134800 	lsl	w0, w0, #13
    4000020c:	12130000 	and	w0, w0, #0x2000
    40000210:	2a000021 	orr	w1, w1, w0
    40000214:	f94007e0 	ldr	x0, [sp, #8]
    40000218:	b9000001 	str	w1, [x0]
    4000021c:	910043ff 	add	sp, sp, #0x10
    40000220:	d65f03c0 	ret

0000000040000224 <UART_UCR2_BF_set_PREN>:
UCR2_DECLARE_BIT_FIELD_FNS(RTEC, UART_UCR2_RTEC);

// PREN
#define PREN_SHIFT 8
#define PREN_MASK (0b1 << PREN_SHIFT)
UCR2_DECLARE_BIT_FIELD_FNS(PREN, bool);
    40000224:	d10043ff 	sub	sp, sp, #0x10
    40000228:	f90007e0 	str	x0, [sp, #8]
    4000022c:	39001fe1 	strb	w1, [sp, #7]
    40000230:	f94007e0 	ldr	x0, [sp, #8]
    40000234:	b9400000 	ldr	w0, [x0]
    40000238:	12177801 	and	w1, w0, #0xfffffeff
    4000023c:	39401fe0 	ldrb	w0, [sp, #7]
    40000240:	53185c00 	lsl	w0, w0, #8
    40000244:	12180000 	and	w0, w0, #0x100
    40000248:	2a000021 	orr	w1, w1, w0
    4000024c:	f94007e0 	ldr	x0, [sp, #8]
    40000250:	b9000001 	str	w1, [x0]
    40000254:	910043ff 	add	sp, sp, #0x10
    40000258:	d65f03c0 	ret

000000004000025c <UART_UCR2_BF_set_WS>:
UCR2_DECLARE_BIT_FIELD_FNS(STPB, bool);

// WS
#define WS_SHIFT 5
#define WS_MASK (0b1 << WS_SHIFT)
UCR2_DECLARE_BIT_FIELD_FNS(WS, bool);
    4000025c:	d10043ff 	sub	sp, sp, #0x10
    40000260:	f90007e0 	str	x0, [sp, #8]
    40000264:	39001fe1 	strb	w1, [sp, #7]
    40000268:	f94007e0 	ldr	x0, [sp, #8]
    4000026c:	b9400000 	ldr	w0, [x0]
    40000270:	121a7801 	and	w1, w0, #0xffffffdf
    40000274:	39401fe0 	ldrb	w0, [sp, #7]
    40000278:	531b6800 	lsl	w0, w0, #5
    4000027c:	121b0000 	and	w0, w0, #0x20
    40000280:	2a000021 	orr	w1, w1, w0
    40000284:	f94007e0 	ldr	x0, [sp, #8]
    40000288:	b9000001 	str	w1, [x0]
    4000028c:	910043ff 	add	sp, sp, #0x10
    40000290:	d65f03c0 	ret

0000000040000294 <UART_UCR2_BF_set_TXEN>:
UCR2_DECLARE_BIT_FIELD_FNS(ATEN, bool);

// TXEN
#define TXEN_SHIFT 2
#define TXEN_MASK (0b1 << TXEN_SHIFT)
UCR2_DECLARE_BIT_FIELD_FNS(TXEN, bool);
    40000294:	d10043ff 	sub	sp, sp, #0x10
    40000298:	f90007e0 	str	x0, [sp, #8]
    4000029c:	39001fe1 	strb	w1, [sp, #7]
    400002a0:	f94007e0 	ldr	x0, [sp, #8]
    400002a4:	b9400000 	ldr	w0, [x0]
    400002a8:	121d7801 	and	w1, w0, #0xfffffffb
    400002ac:	39401fe0 	ldrb	w0, [sp, #7]
    400002b0:	531e7400 	lsl	w0, w0, #2
    400002b4:	121e0000 	and	w0, w0, #0x4
    400002b8:	2a000021 	orr	w1, w1, w0
    400002bc:	f94007e0 	ldr	x0, [sp, #8]
    400002c0:	b9000001 	str	w1, [x0]
    400002c4:	910043ff 	add	sp, sp, #0x10
    400002c8:	d65f03c0 	ret

00000000400002cc <UART_UCR2_BF_set_RXEN>:

// RXEN
#define RXEN_SHIFT 1
#define RXEN_MASK (0b1 << RXEN_SHIFT)
UCR2_DECLARE_BIT_FIELD_FNS(RXEN, bool);
    400002cc:	d10043ff 	sub	sp, sp, #0x10
    400002d0:	f90007e0 	str	x0, [sp, #8]
    400002d4:	39001fe1 	strb	w1, [sp, #7]
    400002d8:	f94007e0 	ldr	x0, [sp, #8]
    400002dc:	b9400000 	ldr	w0, [x0]
    400002e0:	121e7801 	and	w1, w0, #0xfffffffd
    400002e4:	39401fe0 	ldrb	w0, [sp, #7]
    400002e8:	531f7800 	lsl	w0, w0, #1
    400002ec:	121f0000 	and	w0, w0, #0x2
    400002f0:	2a000021 	orr	w1, w1, w0
    400002f4:	f94007e0 	ldr	x0, [sp, #8]
    400002f8:	b9000001 	str	w1, [x0]
    400002fc:	910043ff 	add	sp, sp, #0x10
    40000300:	d65f03c0 	ret

0000000040000304 <UART_UCR2_BF_set_SRST>:

// SRST
#define SRST_SHIFT 0
#define SRST_MASK (0b1 << SRST_SHIFT)
UCR2_DECLARE_BIT_FIELD_FNS(SRST, bool);
    40000304:	d10043ff 	sub	sp, sp, #0x10
    40000308:	f90007e0 	str	x0, [sp, #8]
    4000030c:	39001fe1 	strb	w1, [sp, #7]
    40000310:	f94007e0 	ldr	x0, [sp, #8]
    40000314:	b9400000 	ldr	w0, [x0]
    40000318:	121f7801 	and	w1, w0, #0xfffffffe
    4000031c:	39401fe0 	ldrb	w0, [sp, #7]
    40000320:	2a000021 	orr	w1, w1, w0
    40000324:	f94007e0 	ldr	x0, [sp, #8]
    40000328:	b9000001 	str	w1, [x0]
    4000032c:	910043ff 	add	sp, sp, #0x10
    40000330:	d65f03c0 	ret

0000000040000334 <UART_UCR3_write>:
MMIO_DECLARE_REG32_VALUE_STRUCT(UCR3_VALUE_STRUCT_NAME);

MMIO_DECLARE_REG32_GETTER_WITH_BASE(UART, UCR3, UCR3_VALUE_STRUCT_NAME,
									UART_UCR3_OFFSET);

MMIO_DECLARE_REG32_SETTER_WITH_BASE(UART, UCR3, UCR3_VALUE_STRUCT_NAME,
    40000334:	d10043ff 	sub	sp, sp, #0x10
    40000338:	f90007e0 	str	x0, [sp, #8]
    4000033c:	b90003e1 	str	w1, [sp]
    40000340:	f94007e0 	ldr	x0, [sp, #8]
    40000344:	91022000 	add	x0, x0, #0x88
    40000348:	b94003e1 	ldr	w1, [sp]
    4000034c:	b9000001 	str	w1, [x0]
    40000350:	910043ff 	add	sp, sp, #0x10
    40000354:	d65f03c0 	ret

0000000040000358 <UART_UCR3_BF_set_DSR>:
UCR3_DECLARE_BIT_FIELD_FNS(FRAERREN, bool);

// DSR (unused)
#define DSR_SHIFT 10
#define DSR_MASK (0b1 << DSR_SHIFT)
UCR3_DECLARE_BIT_FIELD_FNS(DSR, bool);
    40000358:	d10043ff 	sub	sp, sp, #0x10
    4000035c:	f90007e0 	str	x0, [sp, #8]
    40000360:	39001fe1 	strb	w1, [sp, #7]
    40000364:	f94007e0 	ldr	x0, [sp, #8]
    40000368:	b9400000 	ldr	w0, [x0]
    4000036c:	12157801 	and	w1, w0, #0xfffffbff
    40000370:	39401fe0 	ldrb	w0, [sp, #7]
    40000374:	53165400 	lsl	w0, w0, #10
    40000378:	12160000 	and	w0, w0, #0x400
    4000037c:	2a000021 	orr	w1, w1, w0
    40000380:	f94007e0 	ldr	x0, [sp, #8]
    40000384:	b9000001 	str	w1, [x0]
    40000388:	910043ff 	add	sp, sp, #0x10
    4000038c:	d65f03c0 	ret

0000000040000390 <UART_UCR3_BF_set_DCD>:

// DCD (unused)
#define DCD_SHIFT 9
#define DCD_MASK (0b1 << DCD_SHIFT)
UCR3_DECLARE_BIT_FIELD_FNS(DCD, bool);
    40000390:	d10043ff 	sub	sp, sp, #0x10
    40000394:	f90007e0 	str	x0, [sp, #8]
    40000398:	39001fe1 	strb	w1, [sp, #7]
    4000039c:	f94007e0 	ldr	x0, [sp, #8]
    400003a0:	b9400000 	ldr	w0, [x0]
    400003a4:	12167801 	and	w1, w0, #0xfffffdff
    400003a8:	39401fe0 	ldrb	w0, [sp, #7]
    400003ac:	53175800 	lsl	w0, w0, #9
    400003b0:	12170000 	and	w0, w0, #0x200
    400003b4:	2a000021 	orr	w1, w1, w0
    400003b8:	f94007e0 	ldr	x0, [sp, #8]
    400003bc:	b9000001 	str	w1, [x0]
    400003c0:	910043ff 	add	sp, sp, #0x10
    400003c4:	d65f03c0 	ret

00000000400003c8 <UART_UCR3_BF_set_RI>:

// RI (unused)
#define RI_SHIFT 8
#define RI_MASK (0b1 << RI_SHIFT)
UCR3_DECLARE_BIT_FIELD_FNS(RI, bool);
    400003c8:	d10043ff 	sub	sp, sp, #0x10
    400003cc:	f90007e0 	str	x0, [sp, #8]
    400003d0:	39001fe1 	strb	w1, [sp, #7]
    400003d4:	f94007e0 	ldr	x0, [sp, #8]
    400003d8:	b9400000 	ldr	w0, [x0]
    400003dc:	12177801 	and	w1, w0, #0xfffffeff
    400003e0:	39401fe0 	ldrb	w0, [sp, #7]
    400003e4:	53185c00 	lsl	w0, w0, #8
    400003e8:	12180000 	and	w0, w0, #0x100
    400003ec:	2a000021 	orr	w1, w1, w0
    400003f0:	f94007e0 	ldr	x0, [sp, #8]
    400003f4:	b9000001 	str	w1, [x0]
    400003f8:	910043ff 	add	sp, sp, #0x10
    400003fc:	d65f03c0 	ret

0000000040000400 <UART_UCR3_BF_set_RXDMUXSEL>:
UCR3_DECLARE_BIT_FIELD_FNS(DTRDEN, bool);

// RXDMUXSEL
#define RXDMUXSEL_SHIFT 2
#define RXDMUXSEL_MASK (0b1 << RXDMUXSEL_SHIFT)
UCR3_DECLARE_BIT_FIELD_FNS(RXDMUXSEL, bool);
    40000400:	d10043ff 	sub	sp, sp, #0x10
    40000404:	f90007e0 	str	x0, [sp, #8]
    40000408:	39001fe1 	strb	w1, [sp, #7]
    4000040c:	f94007e0 	ldr	x0, [sp, #8]
    40000410:	b9400000 	ldr	w0, [x0]
    40000414:	121d7801 	and	w1, w0, #0xfffffffb
    40000418:	39401fe0 	ldrb	w0, [sp, #7]
    4000041c:	531e7400 	lsl	w0, w0, #2
    40000420:	121e0000 	and	w0, w0, #0x4
    40000424:	2a000021 	orr	w1, w1, w0
    40000428:	f94007e0 	ldr	x0, [sp, #8]
    4000042c:	b9000001 	str	w1, [x0]
    40000430:	910043ff 	add	sp, sp, #0x10
    40000434:	d65f03c0 	ret

0000000040000438 <UART_UCR4_write>:
MMIO_DECLARE_REG32_VALUE_STRUCT(UCR4_VALUE_STRUCT_NAME);

MMIO_DECLARE_REG32_GETTER_WITH_BASE(UART, UCR4, UCR4_VALUE_STRUCT_NAME,
									UART_UCR4_OFFSET);

MMIO_DECLARE_REG32_SETTER_WITH_BASE(UART, UCR4, UCR4_VALUE_STRUCT_NAME,
    40000438:	d10043ff 	sub	sp, sp, #0x10
    4000043c:	f90007e0 	str	x0, [sp, #8]
    40000440:	b90003e1 	str	w1, [sp]
    40000444:	f94007e0 	ldr	x0, [sp, #8]
    40000448:	91023000 	add	x0, x0, #0x8c
    4000044c:	b94003e1 	ldr	w1, [sp]
    40000450:	b9000001 	str	w1, [x0]
    40000454:	910043ff 	add	sp, sp, #0x10
    40000458:	d65f03c0 	ret

000000004000045c <UART_UCR4_BF_set_CTSTL>:
								  bf_name##_SHIFT, bf_name##_MASK);

// CTSTL
#define CTSTL_SHIFT 10
#define CTSTL_MASK (0b111111 << CTSTL_SHIFT)
UCR4_DECLARE_BIT_FIELD_FNS(CTSTL, uint8);
    4000045c:	d10043ff 	sub	sp, sp, #0x10
    40000460:	f90007e0 	str	x0, [sp, #8]
    40000464:	39001fe1 	strb	w1, [sp, #7]
    40000468:	f94007e0 	ldr	x0, [sp, #8]
    4000046c:	b9400000 	ldr	w0, [x0]
    40000470:	12106401 	and	w1, w0, #0xffff03ff
    40000474:	39401fe0 	ldrb	w0, [sp, #7]
    40000478:	53165400 	lsl	w0, w0, #10
    4000047c:	12003c00 	and	w0, w0, #0xffff
    40000480:	2a000021 	orr	w1, w1, w0
    40000484:	f94007e0 	ldr	x0, [sp, #8]
    40000488:	b9000001 	str	w1, [x0]
    4000048c:	910043ff 	add	sp, sp, #0x10
    40000490:	d65f03c0 	ret

0000000040000494 <UART_UFCR_write>:
MMIO_DECLARE_REG32_VALUE_STRUCT(UFCR_VALUE_STRUCT_NAME);

MMIO_DECLARE_REG32_GETTER_WITH_BASE(UART, UFCR, UFCR_VALUE_STRUCT_NAME,
									UART_UFCR_OFFSET);

MMIO_DECLARE_REG32_SETTER_WITH_BASE(UART, UFCR, UFCR_VALUE_STRUCT_NAME,
    40000494:	d10043ff 	sub	sp, sp, #0x10
    40000498:	f90007e0 	str	x0, [sp, #8]
    4000049c:	b90003e1 	str	w1, [sp]
    400004a0:	f94007e0 	ldr	x0, [sp, #8]
    400004a4:	91024000 	add	x0, x0, #0x90
    400004a8:	b94003e1 	ldr	w1, [sp]
    400004ac:	b9000001 	str	w1, [x0]
    400004b0:	910043ff 	add	sp, sp, #0x10
    400004b4:	d65f03c0 	ret

00000000400004b8 <UART_UFCR_BF_set_TXTL>:
								  bf_name##_SHIFT, bf_name##_MASK);

// TXTL
#define TXTL_SHIFT 10
#define TXTL_MASK (0b111111 << TXTL_SHIFT)
UFCR_DECLARE_BIT_FIELD_FNS(TXTL, uint8);
    400004b8:	d10043ff 	sub	sp, sp, #0x10
    400004bc:	f90007e0 	str	x0, [sp, #8]
    400004c0:	39001fe1 	strb	w1, [sp, #7]
    400004c4:	f94007e0 	ldr	x0, [sp, #8]
    400004c8:	b9400000 	ldr	w0, [x0]
    400004cc:	12106401 	and	w1, w0, #0xffff03ff
    400004d0:	39401fe0 	ldrb	w0, [sp, #7]
    400004d4:	53165400 	lsl	w0, w0, #10
    400004d8:	12003c00 	and	w0, w0, #0xffff
    400004dc:	2a000021 	orr	w1, w1, w0
    400004e0:	f94007e0 	ldr	x0, [sp, #8]
    400004e4:	b9000001 	str	w1, [x0]
    400004e8:	910043ff 	add	sp, sp, #0x10
    400004ec:	d65f03c0 	ret

00000000400004f0 <UART_UFCR_BF_set_RFDIV>:
	UART_UFCR_RFDIV_DIV_BY_1 = 0b101,
	UART_UFCR_RFDIV_DIV_BY_7 = 0b110,
	// 111 is reserved
} UART_UFCR_RFDIV;

UFCR_DECLARE_BIT_FIELD_FNS(RFDIV, UART_UFCR_RFDIV);
    400004f0:	d10043ff 	sub	sp, sp, #0x10
    400004f4:	f90007e0 	str	x0, [sp, #8]
    400004f8:	b90007e1 	str	w1, [sp, #4]
    400004fc:	f94007e0 	ldr	x0, [sp, #8]
    40000500:	b9400000 	ldr	w0, [x0]
    40000504:	12167001 	and	w1, w0, #0xfffffc7f
    40000508:	b94007e0 	ldr	w0, [sp, #4]
    4000050c:	53196000 	lsl	w0, w0, #7
    40000510:	12190800 	and	w0, w0, #0x380
    40000514:	2a000021 	orr	w1, w1, w0
    40000518:	f94007e0 	ldr	x0, [sp, #8]
    4000051c:	b9000001 	str	w1, [x0]
    40000520:	910043ff 	add	sp, sp, #0x10
    40000524:	d65f03c0 	ret

0000000040000528 <UART_UFCR_BF_set_RXTL>:
UFCR_DECLARE_BIT_FIELD_FNS(DCEDTE, bool);

// RXTL
#define RXTL_SHIFT 0
#define RXTL_MASK (0b111111 << RXTL_SHIFT)
UFCR_DECLARE_BIT_FIELD_FNS(RXTL, uint8);
    40000528:	d10043ff 	sub	sp, sp, #0x10
    4000052c:	f90007e0 	str	x0, [sp, #8]
    40000530:	39001fe1 	strb	w1, [sp, #7]
    40000534:	f94007e0 	ldr	x0, [sp, #8]
    40000538:	b9400000 	ldr	w0, [x0]
    4000053c:	121a6401 	and	w1, w0, #0xffffffc0
    40000540:	39401fe0 	ldrb	w0, [sp, #7]
    40000544:	12001400 	and	w0, w0, #0x3f
    40000548:	2a000021 	orr	w1, w1, w0
    4000054c:	f94007e0 	ldr	x0, [sp, #8]
    40000550:	b9000001 	str	w1, [x0]
    40000554:	910043ff 	add	sp, sp, #0x10
    40000558:	d65f03c0 	ret

000000004000055c <UART_UMCR_write>:
MMIO_DECLARE_REG32_VALUE_STRUCT(UMCR_VALUE_STRUCT_NAME);

MMIO_DECLARE_REG32_GETTER_WITH_BASE(UART, UMCR, UMCR_VALUE_STRUCT_NAME,
									UART_UMCR_OFFSET);

MMIO_DECLARE_REG32_SETTER_WITH_BASE(UART, UMCR, UMCR_VALUE_STRUCT_NAME,
    4000055c:	d10043ff 	sub	sp, sp, #0x10
    40000560:	f90007e0 	str	x0, [sp, #8]
    40000564:	b90003e1 	str	w1, [sp]
    40000568:	f94007e0 	ldr	x0, [sp, #8]
    4000056c:	9102e000 	add	x0, x0, #0xb8
    40000570:	b94003e1 	ldr	w1, [sp]
    40000574:	b9000001 	str	w1, [x0]
    40000578:	910043ff 	add	sp, sp, #0x10
    4000057c:	d65f03c0 	ret

0000000040000580 <UART_UTS_read>:

#define UTS_VALUE_STRUCT_NAME UartUtsValue

MMIO_DECLARE_REG32_VALUE_STRUCT(UTS_VALUE_STRUCT_NAME);

MMIO_DECLARE_REG32_GETTER_WITH_BASE(UART, UTS, UTS_VALUE_STRUCT_NAME,
    40000580:	d10043ff 	sub	sp, sp, #0x10
    40000584:	f90007e0 	str	x0, [sp, #8]
    40000588:	f94007e0 	ldr	x0, [sp, #8]
    4000058c:	9102d000 	add	x0, x0, #0xb4
    40000590:	b9400000 	ldr	w0, [x0]
    40000594:	910043ff 	add	sp, sp, #0x10
    40000598:	d65f03c0 	ret

000000004000059c <UART_UTS_BF_get_TXFULL>:
UTS_DECLARE_BIT_FIELD_FNS(RXEMPTY, bool);

// TXFULL
#define TXFULL_SHIFT 4
#define TXFULL_MASK (0b1 << TXFULL_SHIFT)
UTS_DECLARE_BIT_FIELD_FNS(TXFULL, bool);
    4000059c:	d10043ff 	sub	sp, sp, #0x10
    400005a0:	b9000be0 	str	w0, [sp, #8]
    400005a4:	b9400be0 	ldr	w0, [sp, #8]
    400005a8:	121c0000 	and	w0, w0, #0x10
    400005ac:	7100001f 	cmp	w0, #0x0
    400005b0:	1a9f07e0 	cset	w0, ne	// ne = any
    400005b4:	12001c00 	and	w0, w0, #0xff
    400005b8:	910043ff 	add	sp, sp, #0x10
    400005bc:	d65f03c0 	ret

00000000400005c0 <UART_UTS_BF_get_SOFTRST>:
UTS_DECLARE_BIT_FIELD_FNS(RXFULL, bool);

// SOFTRST
#define SOFTRST_SHIFT 0
#define SOFTRST_MASK (0b1 << SOFTRST_SHIFT)
UTS_DECLARE_BIT_FIELD_FNS(SOFTRST, bool);
    400005c0:	d10043ff 	sub	sp, sp, #0x10
    400005c4:	b9000be0 	str	w0, [sp, #8]
    400005c8:	b9400be0 	ldr	w0, [sp, #8]
    400005cc:	12000000 	and	w0, w0, #0x1
    400005d0:	7100001f 	cmp	w0, #0x0
    400005d4:	1a9f07e0 	cset	w0, ne	// ne = any
    400005d8:	12001c00 	and	w0, w0, #0xff
    400005dc:	910043ff 	add	sp, sp, #0x10
    400005e0:	d65f03c0 	ret

00000000400005e4 <UART_UTXD_write>:

#define UTXD_VALUE_STRUCT_NAME UartUtxdValue

MMIO_DECLARE_REG32_VALUE_STRUCT(UTXD_VALUE_STRUCT_NAME);

MMIO_DECLARE_REG32_SETTER_WITH_BASE(UART, UTXD, UTXD_VALUE_STRUCT_NAME,
    400005e4:	d10043ff 	sub	sp, sp, #0x10
    400005e8:	f90007e0 	str	x0, [sp, #8]
    400005ec:	b90003e1 	str	w1, [sp]
    400005f0:	f94007e0 	ldr	x0, [sp, #8]
    400005f4:	91010000 	add	x0, x0, #0x40
    400005f8:	b94003e1 	ldr	w1, [sp]
    400005fc:	b9000001 	str	w1, [x0]
    40000600:	910043ff 	add	sp, sp, #0x10
    40000604:	d65f03c0 	ret

0000000040000608 <UART_tx_fifo_full>:
	UART4_BASE,
};

// Tx fifo full
static inline bool UART_tx_fifo_full(uintptr periph_base)
{
    40000608:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    4000060c:	910003fd 	mov	x29, sp
    40000610:	f9000fe0 	str	x0, [sp, #24]
	UartUtsValue uts = UART_UTS_read(periph_base);
    40000614:	f9400fe0 	ldr	x0, [sp, #24]
    40000618:	97ffffda 	bl	40000580 <UART_UTS_read>
    4000061c:	b9002be0 	str	w0, [sp, #40]
	return UART_UTS_BF_get_TXFULL(uts);
    40000620:	b9402be0 	ldr	w0, [sp, #40]
    40000624:	97ffffde 	bl	4000059c <UART_UTS_BF_get_TXFULL>
    40000628:	12001c00 	and	w0, w0, #0xff
}
    4000062c:	a8c37bfd 	ldp	x29, x30, [sp], #48
    40000630:	d65f03c0 	ret

0000000040000634 <UART_putc>:

void UART_putc(UART_ID id, uint8 c)
{
    40000634:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    40000638:	910003fd 	mov	x29, sp
    4000063c:	b9001fe0 	str	w0, [sp, #28]
    40000640:	39006fe1 	strb	w1, [sp, #27]
	UartUtxdValue utxd = {(uint32)c};
    40000644:	39406fe0 	ldrb	w0, [sp, #27]
    40000648:	b9002be0 	str	w0, [sp, #40]

	while (UART_tx_fifo_full(UART_N_BASE[id])) {
    4000064c:	14000002 	b	40000654 <UART_putc+0x20>
		asm volatile("nop");
    40000650:	d503201f 	nop
	while (UART_tx_fifo_full(UART_N_BASE[id])) {
    40000654:	90000000 	adrp	x0, 40000000 <_start>
    40000658:	91244000 	add	x0, x0, #0x910
    4000065c:	b9401fe1 	ldr	w1, [sp, #28]
    40000660:	f8617800 	ldr	x0, [x0, x1, lsl #3]
    40000664:	97ffffe9 	bl	40000608 <UART_tx_fifo_full>
    40000668:	12001c00 	and	w0, w0, #0xff
    4000066c:	12000000 	and	w0, w0, #0x1
    40000670:	7100001f 	cmp	w0, #0x0
    40000674:	54fffee1 	b.ne	40000650 <UART_putc+0x1c>  // b.any
	}

	UART_UTXD_write(UART_N_BASE[id], utxd);
    40000678:	90000000 	adrp	x0, 40000000 <_start>
    4000067c:	91244000 	add	x0, x0, #0x910
    40000680:	b9401fe1 	ldr	w1, [sp, #28]
    40000684:	f8617800 	ldr	x0, [x0, x1, lsl #3]
    40000688:	b9402be1 	ldr	w1, [sp, #40]
    4000068c:	97ffffd6 	bl	400005e4 <UART_UTXD_write>
}
    40000690:	d503201f 	nop
    40000694:	a8c37bfd 	ldp	x29, x30, [sp], #48
    40000698:	d65f03c0 	ret

000000004000069c <UART_puts>:

void UART_puts(const UART_ID id, const char *s)
{
    4000069c:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    400006a0:	910003fd 	mov	x29, sp
    400006a4:	b9001fe0 	str	w0, [sp, #28]
    400006a8:	f9000be1 	str	x1, [sp, #16]
	while (*s) UART_putc(id, *s++);
    400006ac:	14000008 	b	400006cc <UART_puts+0x30>
    400006b0:	f9400be0 	ldr	x0, [sp, #16]
    400006b4:	91000401 	add	x1, x0, #0x1
    400006b8:	f9000be1 	str	x1, [sp, #16]
    400006bc:	39400000 	ldrb	w0, [x0]
    400006c0:	2a0003e1 	mov	w1, w0
    400006c4:	b9401fe0 	ldr	w0, [sp, #28]
    400006c8:	97ffffdb 	bl	40000634 <UART_putc>
    400006cc:	f9400be0 	ldr	x0, [sp, #16]
    400006d0:	39400000 	ldrb	w0, [x0]
    400006d4:	7100001f 	cmp	w0, #0x0
    400006d8:	54fffec1 	b.ne	400006b0 <UART_puts+0x14>  // b.any
}
    400006dc:	d503201f 	nop
    400006e0:	d503201f 	nop
    400006e4:	a8c27bfd 	ldp	x29, x30, [sp], #32
    400006e8:	d65f03c0 	ret

00000000400006ec <UART_reset>:

void UART_reset(UART_ID id)
{
    400006ec:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
    400006f0:	910003fd 	mov	x29, sp
    400006f4:	b9001fe0 	str	w0, [sp, #28]
	uintptr periph_base = UART_N_BASE[id];
    400006f8:	90000000 	adrp	x0, 40000000 <_start>
    400006fc:	91244000 	add	x0, x0, #0x910
    40000700:	b9401fe1 	ldr	w1, [sp, #28]
    40000704:	f8617800 	ldr	x0, [x0, x1, lsl #3]
    40000708:	f9001be0 	str	x0, [sp, #48]
	UartUcr2Value ucr2 = UART_UCR2_read(periph_base);
    4000070c:	f9401be0 	ldr	x0, [sp, #48]
    40000710:	97fffea7 	bl	400001ac <UART_UCR2_read>
    40000714:	b9002be0 	str	w0, [sp, #40]
	UART_UCR2_BF_set_SRST(&ucr2, false);  // UART software reset 17.2.8.2
    40000718:	9100a3e0 	add	x0, sp, #0x28
    4000071c:	52800001 	mov	w1, #0x0                   	// #0
    40000720:	97fffef9 	bl	40000304 <UART_UCR2_BF_set_SRST>

	FOREVER
	{
		for (uint64 i = 0; i < 2000; i++) asm volatile("nop");
    40000724:	f9001fff 	str	xzr, [sp, #56]
    40000728:	14000005 	b	4000073c <UART_reset+0x50>
    4000072c:	d503201f 	nop
    40000730:	f9401fe0 	ldr	x0, [sp, #56]
    40000734:	91000400 	add	x0, x0, #0x1
    40000738:	f9001fe0 	str	x0, [sp, #56]
    4000073c:	f9401fe0 	ldr	x0, [sp, #56]
    40000740:	f11f3c1f 	cmp	x0, #0x7cf
    40000744:	54ffff49 	b.ls	4000072c <UART_reset+0x40>  // b.plast

		UartUtsValue uts = UART_UTS_read(periph_base);
    40000748:	f9401be0 	ldr	x0, [sp, #48]
    4000074c:	97ffff8d 	bl	40000580 <UART_UTS_read>
    40000750:	b90023e0 	str	w0, [sp, #32]
		if (UART_UTS_BF_get_SOFTRST(uts) == 0) {
    40000754:	b94023e0 	ldr	w0, [sp, #32]
    40000758:	97ffff9a 	bl	400005c0 <UART_UTS_BF_get_SOFTRST>
    4000075c:	12001c00 	and	w0, w0, #0xff
    40000760:	52000000 	eor	w0, w0, #0x1
    40000764:	12001c00 	and	w0, w0, #0xff
    40000768:	12000000 	and	w0, w0, #0x1
    4000076c:	7100001f 	cmp	w0, #0x0
    40000770:	54000041 	b.ne	40000778 <UART_reset+0x8c>  // b.any
	{
    40000774:	17ffffec 	b	40000724 <UART_reset+0x38>
			break;
		}
	}
}
    40000778:	d503201f 	nop
    4000077c:	a8c47bfd 	ldp	x29, x30, [sp], #64
    40000780:	d65f03c0 	ret

0000000040000784 <UART_init>:

// FIXME: read the configuration left by the bootloader to watch what is wrong
void UART_init(UART_ID id)
{
    40000784:	a9b97bfd 	stp	x29, x30, [sp, #-112]!
    40000788:	910003fd 	mov	x29, sp
    4000078c:	b9001fe0 	str	w0, [sp, #28]
	// 17.2.12.1 7357
	uintptr periph_base = UART_N_BASE[id];
    40000790:	90000000 	adrp	x0, 40000000 <_start>
    40000794:	91244000 	add	x0, x0, #0x910
    40000798:	b9401fe1 	ldr	w1, [sp, #28]
    4000079c:	f8617800 	ldr	x0, [x0, x1, lsl #3]
    400007a0:	f90037e0 	str	x0, [sp, #104]

	UartUcr1Value ucr1 = {0};
    400007a4:	b90063ff 	str	wzr, [sp, #96]
	UART_UCR1_BF_set_UARTEN(&ucr1, true);
    400007a8:	910183e0 	add	x0, sp, #0x60
    400007ac:	52800021 	mov	w1, #0x1                   	// #1
    400007b0:	97fffe73 	bl	4000017c <UART_UCR1_BF_set_UARTEN>
	UART_UCR1_write(periph_base, ucr1);
    400007b4:	b94063e1 	ldr	w1, [sp, #96]
    400007b8:	f94037e0 	ldr	x0, [sp, #104]
    400007bc:	97fffe67 	bl	40000158 <UART_UCR1_write>

	UartUcr2Value ucr2 = {0};
    400007c0:	b9005bff 	str	wzr, [sp, #88]
	UART_UCR2_BF_set_SRST(&ucr2, true);
    400007c4:	910163e0 	add	x0, sp, #0x58
    400007c8:	52800021 	mov	w1, #0x1                   	// #1
    400007cc:	97fffece 	bl	40000304 <UART_UCR2_BF_set_SRST>
	UART_UCR2_BF_set_RXEN(&ucr2, true);
    400007d0:	910163e0 	add	x0, sp, #0x58
    400007d4:	52800021 	mov	w1, #0x1                   	// #1
    400007d8:	97fffebd 	bl	400002cc <UART_UCR2_BF_set_RXEN>
	UART_UCR2_BF_set_TXEN(&ucr2, true);
    400007dc:	910163e0 	add	x0, sp, #0x58
    400007e0:	52800021 	mov	w1, #0x1                   	// #1
    400007e4:	97fffeac 	bl	40000294 <UART_UCR2_BF_set_TXEN>
	UART_UCR2_BF_set_WS(&ucr2, true);
    400007e8:	910163e0 	add	x0, sp, #0x58
    400007ec:	52800021 	mov	w1, #0x1                   	// #1
    400007f0:	97fffe9b 	bl	4000025c <UART_UCR2_BF_set_WS>
	UART_UCR2_BF_set_PREN(&ucr2, true);
    400007f4:	910163e0 	add	x0, sp, #0x58
    400007f8:	52800021 	mov	w1, #0x1                   	// #1
    400007fc:	97fffe8a 	bl	40000224 <UART_UCR2_BF_set_PREN>
	UART_UCR2_BF_set_CTSC(&ucr2, true);
    40000800:	910163e0 	add	x0, sp, #0x58
    40000804:	52800021 	mov	w1, #0x1                   	// #1
    40000808:	97fffe79 	bl	400001ec <UART_UCR2_BF_set_CTSC>
	UART_UCR2_write(periph_base, ucr2);
    4000080c:	b9405be1 	ldr	w1, [sp, #88]
    40000810:	f94037e0 	ldr	x0, [sp, #104]
    40000814:	97fffe6d 	bl	400001c8 <UART_UCR2_write>

	UartUcr3Value ucr3 = {0};
    40000818:	b90053ff 	str	wzr, [sp, #80]
	UART_UCR3_BF_set_RXDMUXSEL(&ucr3, true);
    4000081c:	910143e0 	add	x0, sp, #0x50
    40000820:	52800021 	mov	w1, #0x1                   	// #1
    40000824:	97fffef7 	bl	40000400 <UART_UCR3_BF_set_RXDMUXSEL>
	UART_UCR3_BF_set_RI(&ucr3, true);
    40000828:	910143e0 	add	x0, sp, #0x50
    4000082c:	52800021 	mov	w1, #0x1                   	// #1
    40000830:	97fffee6 	bl	400003c8 <UART_UCR3_BF_set_RI>
	UART_UCR3_BF_set_DCD(&ucr3, true);
    40000834:	910143e0 	add	x0, sp, #0x50
    40000838:	52800021 	mov	w1, #0x1                   	// #1
    4000083c:	97fffed5 	bl	40000390 <UART_UCR3_BF_set_DCD>
	UART_UCR3_BF_set_DSR(&ucr3, true);
    40000840:	910143e0 	add	x0, sp, #0x50
    40000844:	52800021 	mov	w1, #0x1                   	// #1
    40000848:	97fffec4 	bl	40000358 <UART_UCR3_BF_set_DSR>
	UART_UCR3_write(periph_base, ucr3);
    4000084c:	b94053e1 	ldr	w1, [sp, #80]
    40000850:	f94037e0 	ldr	x0, [sp, #104]
    40000854:	97fffeb8 	bl	40000334 <UART_UCR3_write>

	UartUcr4Value ucr4 = {0};
    40000858:	b9004bff 	str	wzr, [sp, #72]
	UART_UCR4_BF_set_CTSTL(&ucr4, 31);
    4000085c:	910123e0 	add	x0, sp, #0x48
    40000860:	528003e1 	mov	w1, #0x1f                  	// #31
    40000864:	97fffefe 	bl	4000045c <UART_UCR4_BF_set_CTSTL>
	UART_UCR4_write(periph_base, ucr4);
    40000868:	b9404be1 	ldr	w1, [sp, #72]
    4000086c:	f94037e0 	ldr	x0, [sp, #104]
    40000870:	97fffef2 	bl	40000438 <UART_UCR4_write>

	UartUfcrValue ufcr = {0};
    40000874:	b90043ff 	str	wzr, [sp, #64]
	UART_UFCR_BF_set_RXTL(&ufcr, 30);
    40000878:	910103e0 	add	x0, sp, #0x40
    4000087c:	528003c1 	mov	w1, #0x1e                  	// #30
    40000880:	97ffff2a 	bl	40000528 <UART_UFCR_BF_set_RXTL>
	UART_UFCR_BF_set_RFDIV(&ufcr, UART_UFCR_RFDIV_DIV_BY_5);
    40000884:	910103e0 	add	x0, sp, #0x40
    40000888:	52800021 	mov	w1, #0x1                   	// #1
    4000088c:	97ffff19 	bl	400004f0 <UART_UFCR_BF_set_RFDIV>
	UART_UFCR_BF_set_TXTL(&ufcr, 2);
    40000890:	910103e0 	add	x0, sp, #0x40
    40000894:	52800041 	mov	w1, #0x2                   	// #2
    40000898:	97ffff08 	bl	400004b8 <UART_UFCR_BF_set_TXTL>
	UART_UFCR_write(periph_base, ufcr);
    4000089c:	b94043e1 	ldr	w1, [sp, #64]
    400008a0:	f94037e0 	ldr	x0, [sp, #104]
    400008a4:	97fffefc 	bl	40000494 <UART_UFCR_write>

	UartUbirValue ubir = {0};
    400008a8:	b9003bff 	str	wzr, [sp, #56]
	UART_UBIR_BF_set_INC(&ubir, 2303);
    400008ac:	9100e3e0 	add	x0, sp, #0x38
    400008b0:	52811fe1 	mov	w1, #0x8ff                 	// #2303
    400008b4:	97fffe08 	bl	400000d4 <UART_UBIR_BF_set_INC>
	UART_UBIR_write(periph_base, ubir);
    400008b8:	b9403be1 	ldr	w1, [sp, #56]
    400008bc:	f94037e0 	ldr	x0, [sp, #104]
    400008c0:	97fffdfc 	bl	400000b0 <UART_UBIR_write>

	UartUbmrValue ubmr = {0};
    400008c4:	b90033ff 	str	wzr, [sp, #48]
	UART_UBMR_BF_set_MOD(&ubmr, 3124);
    400008c8:	9100c3e0 	add	x0, sp, #0x30
    400008cc:	52818681 	mov	w1, #0xc34                 	// #3124
    400008d0:	97fffe16 	bl	40000128 <UART_UBMR_BF_set_MOD>
	UART_UBMR_write(periph_base, ubmr);
    400008d4:	b94033e1 	ldr	w1, [sp, #48]
    400008d8:	f94037e0 	ldr	x0, [sp, #104]
    400008dc:	97fffe0a 	bl	40000104 <UART_UBMR_write>

	UartUmcrValue umcr = {0};
    400008e0:	b9002bff 	str	wzr, [sp, #40]
	UART_UMCR_write(periph_base, umcr);
    400008e4:	b9402be1 	ldr	w1, [sp, #40]
    400008e8:	f94037e0 	ldr	x0, [sp, #104]
    400008ec:	97ffff1c 	bl	4000055c <UART_UMCR_write>
}
    400008f0:	d503201f 	nop
    400008f4:	a8c77bfd 	ldp	x29, x30, [sp], #112
    400008f8:	d65f03c0 	ret
    400008fc:	00000000 	udf	#0

Disassembly of section .rodata:

0000000040000900 <UART_N_BASE-0x10>:
    40000900:	6c6c6548 	ldnp	d8, d25, [x10, #-320]
    40000904:	6f77206f 	umlal2	v15.4s, v3.8h, v7.h[3]
    40000908:	0a646c72 	bic	w18, w3, w4, lsr #27
    4000090c:	0000000d 	udf	#13

0000000040000910 <UART_N_BASE>:
static const uintptr UART_N_BASE[] = {
    40000910:	30860000 	adr	x0, 3ff0c911 <_start-0xf36ef>
    40000914:	00000000 	udf	#0
    40000918:	30890000 	adr	x0, 3ff12919 <_start-0xed6e7>
    4000091c:	00000000 	udf	#0
    40000920:	30880000 	adr	x0, 3ff10921 <_start-0xef6df>
    40000924:	00000000 	udf	#0
    40000928:	30a60000 	adr	x0, 3ff4c929 <_start-0xb36d7>
    4000092c:	00000000 	udf	#0

Disassembly of section .debug_line:

0000000000000000 <.debug_line>:
   0:	00000049 	udf	#73
   4:	00080005 	.inst	0x00080005 ; undefined
   8:	0000002e 	udf	#46
   c:	fb010104 	.inst	0xfb010104 ; undefined
  10:	01000d0e 	.inst	0x01000d0e ; undefined
  14:	00010101 	.inst	0x00010101 ; undefined
  18:	00010000 	.inst	0x00010000 ; undefined
  1c:	01010100 	.inst	0x01010100 ; undefined
  20:	0000021f 	udf	#543
  24:	002b0000 	.inst	0x002b0000 ; NYI
  28:	01020000 	.inst	0x01020000 ; undefined
  2c:	020f021f 	.inst	0x020f021f ; undefined
  30:	00000034 	udf	#52
  34:	00003401 	udf	#13313
  38:	09000100 	.inst	0x09000100 ; undefined
  3c:	00006002 	udf	#24578
  40:	00000040 	udf	#64
  44:	21211800 	.inst	0x21211800 ; undefined
  48:	01000102 	.inst	0x01000102 ; undefined
  4c:	00005601 	udf	#22017
  50:	08000500 	stxrb	w0, w0, [x8]
  54:	00002e00 	udf	#11776
  58:	01010400 	.inst	0x01010400 ; undefined
  5c:	000d0efb 	.inst	0x000d0efb ; undefined
  60:	01010101 	.inst	0x01010101 ; undefined
  64:	01000000 	.inst	0x01000000 ; undefined
  68:	01010000 	.inst	0x01010000 ; undefined
  6c:	00021f01 	.inst	0x00021f01 ; undefined
  70:	43000000 	.inst	0x43000000 ; undefined
  74:	02000000 	.inst	0x02000000 ; undefined
  78:	0f021f01 	.inst	0x0f021f01 ; undefined
  7c:	00004d02 	udf	#19714
  80:	004d0100 	.inst	0x004d0100 ; undefined
  84:	00010000 	.inst	0x00010000 ; undefined
  88:	00000209 	udf	#521
  8c:	00004000 	udf	#16384
  90:	22160000 	.inst	0x22160000 ; undefined
  94:	21232123 	.inst	0x21232123 ; undefined
  98:	21222123 	.inst	0x21222123 ; undefined
  9c:	23212121 	.inst	0x23212121 ; undefined
  a0:	09022123 	.inst	0x09022123 ; undefined
  a4:	6f010100 	.inst	0x6f010100 ; undefined
  a8:	05000000 	orr	z0.s, z0.s, #0x1
  ac:	45000800 	.inst	0x45000800 ; undefined
  b0:	04000000 	add	z0.b, p0/m, z0.b, z0.b
  b4:	0efb0101 	.inst	0x0efb0101 ; undefined
  b8:	0101000d 	.inst	0x0101000d ; undefined
  bc:	00000101 	udf	#257
  c0:	00000100 	udf	#256
  c4:	1f010101 	fmadd	s1, s8, s1, s0
  c8:	00000004 	udf	#4
  cc:	00006f00 	udf	#28416
  d0:	00007b00 	udf	#31488
  d4:	00008800 	udf	#34816
  d8:	1f010200 	fmadd	s0, s16, s1, s0
  dc:	60050f02 	.inst	0x60050f02 ; undefined
  e0:	01000000 	.inst	0x01000000 ; undefined
  e4:	00000060 	udf	#96
  e8:	00009e01 	udf	#40449
  ec:	00a70200 	.inst	0x00a70200 ; undefined
  f0:	ae030000 	.inst	0xae030000 ; undefined
  f4:	02000000 	.inst	0x02000000 ; undefined
  f8:	09000105 	.inst	0x09000105 ; undefined
  fc:	00006c02 	udf	#27650
 100:	00000040 	udf	#64
 104:	01090300 	.inst	0x01090300 ; undefined
 108:	052f1f05 	ext	z5.b, z5.b, z24.b, #127
 10c:	04020002 	.inst	0x04020002 ; undefined
 110:	4e682001 	ssubl2	v1.4s, v0.8h, v8.8h
 114:	00020232 	.inst	0x00020232 ; undefined
 118:	01eb0101 	.inst	0x01eb0101 ; undefined
 11c:	00050000 	.inst	0x00050000 ; undefined
 120:	007f0008 	.inst	0x007f0008 ; undefined
 124:	01040000 	.inst	0x01040000 ; undefined
 128:	0d0efb01 	.inst	0x0d0efb01 ; undefined
 12c:	01010100 	.inst	0x01010100 ; undefined
 130:	00000001 	udf	#1
 134:	01000001 	.inst	0x01000001 ; undefined
 138:	061f0101 	.inst	0x061f0101 ; undefined
 13c:	00000000 	udf	#0
 140:	000000d6 	udf	#214
 144:	000000e8 	udf	#232
 148:	0000007b 	udf	#123
 14c:	00000088 	udf	#136
 150:	00000102 	udf	#258
 154:	021f0102 	.inst	0x021f0102 ; undefined
 158:	00cf0f0f 	.inst	0x00cf0f0f ; undefined
 15c:	14010000 	b	4015c <_start-0x3ffbfea4>
 160:	02000001 	.inst	0x02000001 ; undefined
 164:	00000120 	udf	#288
 168:	00012c02 	.inst	0x00012c02 ; undefined
 16c:	01380200 	.inst	0x01380200 ; undefined
 170:	44020000 	.inst	0x44020000 ; undefined
 174:	02000001 	.inst	0x02000001 ; undefined
 178:	00000150 	udf	#336
 17c:	00015c02 	.inst	0x00015c02 ; undefined
 180:	01680200 	.inst	0x01680200 ; undefined
 184:	74020000 	.inst	0x74020000 ; undefined
 188:	02000001 	.inst	0x02000001 ; undefined
 18c:	0000017f 	udf	#383
 190:	0000cf02 	udf	#52994
 194:	009e0100 	.inst	0x009e0100 ; undefined
 198:	a7030000 	.inst	0xa7030000 ; undefined
 19c:	04000000 	add	z0.b, p0/m, z0.b, z0.b
 1a0:	0000018b 	udf	#395
 1a4:	00010505 	.inst	0x00010505 ; undefined
 1a8:	00b00209 	.inst	0x00b00209 ; undefined
 1ac:	00004000 	udf	#16384
 1b0:	17030000 	b	fffffffffc0c01b0 <__stack_el2_top+0xffffffffbb1bf1b0>
 1b4:	0c033c01 	.inst	0x0c033c01 ; undefined
 1b8:	02043c66 	.inst	0x02043c66 ; undefined
 1bc:	3c907303 	stur	q3, [x24, #-249]
 1c0:	3c660c03 	.inst	0x3c660c03 ; undefined
 1c4:	74030304 	.inst	0x74030304 ; undefined
 1c8:	0d033c90 	.inst	0x0d033c90 ; undefined
 1cc:	04043c66 	.inst	0x04043c66 ; undefined
 1d0:	2e907003 	.inst	0x2e907003 ; undefined
 1d4:	17033c5b 	b	fffffffffc0cf340 <__stack_el2_top+0xffffffffbb1ce340>
 1d8:	1b033c66 	madd	w6, w3, w3, w15
 1dc:	0f033cac 	.inst	0x0f033cac ; undefined
 1e0:	0f033cac 	.inst	0x0f033cac ; undefined
 1e4:	3cb13cac 	.inst	0x3cb13cac ; undefined
 1e8:	05043cb1 	.inst	0x05043cb1 ; undefined
 1ec:	907fa603 	adrp	x3, ff4c0000 <__stack_el2_top+0xbe5bf000>
 1f0:	6624033c 	.inst	0x6624033c ; undefined
 1f4:	b13cb13c 	adds	x28, x9, #0xf2c
 1f8:	ac1e033c 	stnp	q28, q0, [x25, #960]
 1fc:	0306043c 	.inst	0x0306043c ; undefined
 200:	3cac7fb4 	.inst	0x3cac7fb4 ; undefined
 204:	3c660d03 	.inst	0x3c660d03 ; undefined
 208:	73030704 	.inst	0x73030704 ; undefined
 20c:	0d033cac 	.inst	0x0d033cac ; undefined
 210:	11033c66 	add	w6, w3, #0xcf
 214:	0a033cac 	and	w12, w5, w3, lsl #15
 218:	08043cac 	stxrb	w4, w12, [x5]
 21c:	3c9e5803 	.inst	0x3c9e5803 ; undefined
 220:	2e630904 	.inst	0x2e630904 ; undefined
 224:	2e583303 	.inst	0x2e583303 ; undefined
 228:	2e740a03 	.inst	0x2e740a03 ; undefined
 22c:	42030a04 	.inst	0x42030a04 ; undefined
 230:	0b043c74 	add	w20, w3, w4, lsl #15
 234:	3d150567 	str	b7, [x11, #1345]
 238:	053d0905 	ext	z5.b, z5.b, z8.b, #234
 23c:	05313d01 	.inst	0x05313d01 ; undefined
 240:	10054b18 	adr	x24, aba0 <_start-0x3fff5460>
 244:	22080520 	.inst	0x22080520 ; undefined
 248:	05210305 	ext	z5.b, z5.b, z24.b, #8
 24c:	09051f26 	.inst	0x09051f26 ; undefined
 250:	0402004a 	.inst	0x0402004a ; undefined
 254:	052e0601 	ext	z1.b, z1.b, z16.b, #113
 258:	0540061d 	eor	z29.b, z29.b, #0x1
 25c:	01054a02 	.inst	0x01054a02 ; undefined
 260:	08053f2f 	stxrb	w5, w15, [x25]
 264:	001d054b 	.inst	0x001d054b ; undefined
 268:	20020402 	.inst	0x20020402 ; undefined
 26c:	02000d05 	.inst	0x02000d05 ; undefined
 270:	053c0204 	ext	z4.b, z4.b, z16.b, #224
 274:	04020009 	.inst	0x04020009 ; undefined
 278:	01054a01 	.inst	0x01054a01 ; undefined
 27c:	0a054d4b 	and	w11, w10, w5, lsl #19
 280:	5917053d 	.inst	0x5917053d ; undefined
 284:	053d0205 	ext	z5.b, z5.b, z16.b, #232
 288:	0305400f 	.inst	0x0305400f ; undefined
 28c:	00250520 	.inst	0x00250520 ; NYI
 290:	20030402 	.inst	0x20030402 ; undefined
 294:	02002105 	.inst	0x02002105 ; undefined
 298:	05200304 	ext	z4.b, z4.b, z24.b, #0
 29c:	04020018 	.inst	0x04020018 ; undefined
 2a0:	16053c01 	b	fffffffff814f2a4 <__stack_el2_top+0xffffffffb724e2a4>
 2a4:	3d07053e 	str	b30, [x9, #449]
 2a8:	02002405 	.inst	0x02002405 ; undefined
 2ac:	053c0104 	ext	z4.b, z4.b, z8.b, #224
 2b0:	04020006 	.inst	0x04020006 ; undefined
 2b4:	02052e01 	.inst	0x02052e01 ; undefined
 2b8:	28010538 	stnp	w24, w1, [x9, #8]
 2bc:	3e0a0540 	.inst	0x3e0a0540 ; undefined
 2c0:	055a1005 	mov	z5.h, p10/z, #-128
 2c4:	053d2102 	mov	z2.b, z8.b[14]
 2c8:	02053e10 	.inst	0x02053e10 ; undefined
 2cc:	3d3d3d21 	str	b1, [x9, #3919]
 2d0:	053d3d3d 	.inst	0x053d3d3d ; undefined
 2d4:	02053e10 	.inst	0x02053e10 ; undefined
 2d8:	3d3d3d21 	str	b1, [x9, #3919]
 2dc:	3e10053d 	.inst	0x3e10053d ; undefined
 2e0:	3d210205 	str	b5, [x16, #2112]
 2e4:	053e1005 	ext	z5.b, z5.b, z0.b, #244
 2e8:	3d3d2102 	str	b2, [x8, #3912]
 2ec:	3e10053d 	.inst	0x3e10053d ; undefined
 2f0:	3d210205 	str	b5, [x16, #2112]
 2f4:	053e1005 	ext	z5.b, z5.b, z0.b, #244
 2f8:	053d2102 	mov	z2.b, z8.b[14]
 2fc:	02053e10 	.inst	0x02053e10 ; undefined
 300:	3d010521 	str	b1, [x9, #65]
 304:	01000302 	.inst	0x01000302 ; undefined
 308:	Address 0x308 is out of bounds.


Disassembly of section .debug_line_str:

0000000000000000 <.debug_line_str>:
   0:	6d6f682f 	ldp	d15, d26, [x1, #-272]
   4:	6e752f65 	uqsub	v5.8h, v27.8h, v21.8h
   8:	662f6261 	.inst	0x662f6261 ; undefined
   c:	73656c69 	.inst	0x73656c69 ; undefined
  10:	73616d2f 	.inst	0x73616d2f ; undefined
  14:	2f726574 	.inst	0x2f726574 ; undefined
  18:	2f6d6674 	.inst	0x2f6d6674 ; undefined
  1c:	38786d69 	.inst	0x38786d69 ; undefined
  20:	702f706d 	adr	x13, 5ee2f <_start-0x3ffa11d1>
  24:	656a6f72 	fnmls	z18.h, p3/m, z27.h, z10.h
  28:	5f007463 	.inst	0x5f007463 ; undefined
  2c:	2f637273 	fcmla	v19.4h, v19.4h, v3.h[1], #270
  30:	0062696c 	.inst	0x0062696c ; undefined
  34:	6e72656b 	umax	v11.8h, v11.8h, v18.8h
  38:	755f6c65 	.inst	0x755f6c65 ; undefined
  3c:	736c6974 	.inst	0x736c6974 ; undefined
  40:	5f00532e 	fmls	h14, h25, v0.h[0]
  44:	2f637273 	fcmla	v19.4h, v19.4h, v3.h[1], #270
  48:	746f6f62 	.inst	0x746f6f62 ; undefined
  4c:	6f6f6200 	umlsl2	v0.4s, v16.8h, v15.h[2]
  50:	00532e74 	.inst	0x00532e74 ; undefined
  54:	6372735f 	.inst	0x6372735f ; undefined
  58:	72656b2f 	.inst	0x72656b2f ; undefined
  5c:	2f6c656e 	.inst	0x2f6c656e ; undefined
  60:	6e72656b 	umax	v11.8h, v11.8h, v18.8h
  64:	655f6c65 	fcmeq	p5.h, p3/z, z3.h, z31.h
  68:	7972746e 	ldrh	w14, [x3, #6458]
  6c:	5f00632e 	.inst	0x5f00632e ; undefined
  70:	2f637273 	fcmla	v19.4h, v19.4h, v3.h[1], #270
  74:	6e72656b 	umax	v11.8h, v11.8h, v18.8h
  78:	5f006c65 	.inst	0x5f006c65 ; undefined
  7c:	6c636e69 	ldnp	d9, d27, [x19, #-464]
  80:	2f656475 	.inst	0x2f656475 ; undefined
  84:	0062696c 	.inst	0x0062696c ; undefined
  88:	636e695f 	.inst	0x636e695f ; undefined
  8c:	6564756c 	fnmls	z12.h, p5/m, z11.h, z4.h
  90:	6972642f 	ldpsw	x15, x25, [x1, #-112]
  94:	73726576 	.inst	0x73726576 ; undefined
  98:	7261752f 	.inst	0x7261752f ; undefined
  9c:	74730074 	.inst	0x74730074 ; undefined
  a0:	746e6964 	.inst	0x746e6964 ; undefined
  a4:	7500682e 	.inst	0x7500682e ; undefined
  a8:	2e747261 	uabdl	v1.4s, v19.4h, v20.4h
  ac:	656b0068 	fmla	z8.h, p0/m, z3.h, z11.h
  b0:	6c656e72 	ldnp	d18, d27, [x19, #-432]
  b4:	6974755f 	ldpsw	xzr, x29, [x10, #-96]
  b8:	682e736c 	.inst	0x682e736c ; undefined
  bc:	72735f00 	.inst	0x72735f00 ; undefined
  c0:	72642f63 	.inst	0x72642f63 ; undefined
  c4:	72657669 	.inst	0x72657669 ; undefined
  c8:	61752f73 	.inst	0x61752f73 ; undefined
  cc:	752f7472 	.inst	0x752f7472 ; undefined
  d0:	2e747261 	uabdl	v1.4s, v19.4h, v20.4h
  d4:	735f0063 	.inst	0x735f0063 ; undefined
  d8:	642f6372 	.inst	0x642f6372 ; undefined
  dc:	65766972 	fnmls	z18.h, p2/m, z11.h, z22.h
  e0:	752f7372 	.inst	0x752f7372 ; undefined
  e4:	00747261 	.inst	0x00747261 ; undefined
  e8:	636e695f 	.inst	0x636e695f ; undefined
  ec:	6564756c 	fnmls	z12.h, p5/m, z11.h, z4.h
  f0:	6972642f 	ldpsw	x15, x25, [x1, #-112]
  f4:	73726576 	.inst	0x73726576 ; undefined
  f8:	7261752f 	.inst	0x7261752f ; undefined
  fc:	61722f74 	.inst	0x61722f74 ; undefined
 100:	695f0077 	ldpsw	x23, x0, [x3, #248]
 104:	756c636e 	.inst	0x756c636e ; undefined
 108:	6c2f6564 	stnp	d4, d25, [x11, #-272]
 10c:	6d2f6269 	stp	d9, d24, [x19, #-272]
 110:	006f696d 	.inst	0x006f696d ; undefined
 114:	74726175 	.inst	0x74726175 ; undefined
 118:	6962755f 	ldpsw	xzr, x29, [x10, #-240]
 11c:	00682e72 	.inst	0x00682e72 ; undefined
 120:	74726175 	.inst	0x74726175 ; undefined
 124:	6d62755f 	ldp	d31, d29, [x10, #-480]
 128:	00682e72 	.inst	0x00682e72 ; undefined
 12c:	74726175 	.inst	0x74726175 ; undefined
 130:	7263755f 	.inst	0x7263755f ; undefined
 134:	00682e31 	.inst	0x00682e31 ; undefined
 138:	74726175 	.inst	0x74726175 ; undefined
 13c:	7263755f 	.inst	0x7263755f ; undefined
 140:	00682e32 	.inst	0x00682e32 ; undefined
 144:	74726175 	.inst	0x74726175 ; undefined
 148:	7263755f 	.inst	0x7263755f ; undefined
 14c:	00682e33 	.inst	0x00682e33 ; undefined
 150:	74726175 	.inst	0x74726175 ; undefined
 154:	7263755f 	.inst	0x7263755f ; undefined
 158:	00682e34 	.inst	0x00682e34 ; undefined
 15c:	74726175 	.inst	0x74726175 ; undefined
 160:	6366755f 	.inst	0x6366755f ; undefined
 164:	00682e72 	.inst	0x00682e72 ; undefined
 168:	74726175 	.inst	0x74726175 ; undefined
 16c:	636d755f 	.inst	0x636d755f ; undefined
 170:	00682e72 	.inst	0x00682e72 ; undefined
 174:	74726175 	.inst	0x74726175 ; undefined
 178:	7374755f 	.inst	0x7374755f ; undefined
 17c:	7500682e 	.inst	0x7500682e ; undefined
 180:	5f747261 	sqdmlsl	s1, h19, v4.h[3]
 184:	64787475 	.inst	0x64787475 ; undefined
 188:	6d00682e 	stp	d14, d26, [x1]
 18c:	5f6f696d 	.inst	0x5f6f696d ; undefined
 190:	73676572 	.inst	0x73676572 ; undefined
 194:	Address 0x194 is out of bounds.


Disassembly of section .debug_info:

0000000000000000 <.debug_info>:
   0:	00000024 	udf	#36
   4:	08010005 	stxrb	w1, w5, [x0]
   8:	00000000 	udf	#0
   c:	00000001 	udf	#1
  10:	00006000 	udf	#24576
  14:	00000040 	udf	#64
  18:	00000c00 	udf	#3072
  1c:	00180000 	.inst	0x00180000 ; undefined
  20:	00430000 	.inst	0x00430000 ; undefined
  24:	80010000 	.inst	0x80010000 ; undefined
  28:	00000024 	udf	#36
  2c:	08010005 	stxrb	w1, w5, [x0]
  30:	00000014 	udf	#20
  34:	00004d01 	udf	#19713
  38:	00000000 	udf	#0
  3c:	00000040 	udf	#64
  40:	00516000 	.inst	0x00516000 ; undefined
  44:	00180000 	.inst	0x00180000 ; undefined
  48:	00430000 	.inst	0x00430000 ; undefined
  4c:	80010000 	.inst	0x80010000 ; undefined
  50:	00000140 	udf	#320
  54:	08010005 	stxrb	w1, w5, [x0]
  58:	00000028 	udf	#40
  5c:	00009c06 	udf	#39942
  60:	00541d00 	.inst	0x00541d00 ; undefined
  64:	00000000 	udf	#0
  68:	006c0000 	.inst	0x006c0000 ; undefined
  6c:	00004000 	udf	#16384
  70:	00440000 	.inst	0x00440000 ; undefined
  74:	00000000 	udf	#0
  78:	00a70000 	.inst	0x00a70000 ; undefined
  7c:	01010000 	.inst	0x01010000 ; undefined
  80:	00011406 	.inst	0x00011406 ; undefined
  84:	007f0400 	.inst	0x007f0400 ; undefined
  88:	0a020000 	and	w0, w0, w2
  8c:	00004117 	udf	#16663
  90:	08010100 	stxrb	w1, w0, [x8]
  94:	00000112 	udf	#274
  98:	7d050201 	str	h1, [x16, #640]
  9c:	01000001 	.inst	0x01000001 ; undefined
  a0:	012a0702 	.inst	0x012a0702 ; undefined
  a4:	04070000 	.inst	0x04070000 ; undefined
  a8:	746e6905 	.inst	0x746e6905 ; undefined
  ac:	00560800 	.inst	0x00560800 ; undefined
  b0:	70040000 	adr	x0, 80b3 <_start-0x3fff7f4d>
  b4:	02000000 	.inst	0x02000000 ; undefined
  b8:	006e1610 	.inst	0x006e1610 ; undefined
  bc:	04010000 	sub	z0.b, p0/m, z0.b, z0.b
  c0:	00008f07 	udf	#36615
  c4:	05080100 	.inst	0x05080100 ; undefined
  c8:	00000062 	udf	#98
  cc:	85070801 	.inst	0x85070801 ; undefined
  d0:	01000000 	.inst	0x01000000 ; undefined
  d4:	00670508 	.inst	0x00670508 ; undefined
  d8:	08010000 	stxrb	w1, w0, [x0]
  dc:	00008a07 	udf	#35335
  e0:	04070900 	.inst	0x04070900 ; undefined
  e4:	0000006e 	udf	#110
  e8:	b80e0403 	str	w3, [x0], #224
  ec:	03000000 	.inst	0x03000000 ; undefined
  f0:	0000013d 	udf	#317
  f4:	01470300 	.inst	0x01470300 ; undefined
  f8:	03010000 	.inst	0x03010000 ; undefined
  fc:	00000151 	udf	#337
 100:	015b0302 	.inst	0x015b0302 ; undefined
 104:	00030000 	.inst	0x00030000 ; undefined
 108:	00007704 	udf	#30468
 10c:	03090300 	.inst	0x03090300 ; undefined
 110:	00000091 	udf	#145
 114:	00019105 	.inst	0x00019105 ; undefined
 118:	00d40d00 	.inst	0x00d40d00 ; undefined
 11c:	b8020000 	stur	w0, [x0, #32]
 120:	00000000 	udf	#0
 124:	00018705 	.inst	0x00018705 ; undefined
 128:	00e91100 	.inst	0x00e91100 ; undefined
 12c:	b8020000 	stur	w0, [x0, #32]
 130:	02000000 	.inst	0x02000000 ; undefined
 134:	000000e9 	udf	#233
 138:	f6080a00 	.inst	0xf6080a00 ; undefined
 13c:	01000000 	.inst	0x01000000 ; undefined
 140:	011b0801 	.inst	0x011b0801 ; undefined
 144:	ef0b0000 	.inst	0xef0b0000 ; undefined
 148:	05000000 	orr	z0.s, z0.s, #0x1
 14c:	00000120 	udf	#288
 150:	0001100f 	.inst	0x0001100f ; undefined
 154:	00b80200 	.inst	0x00b80200 ; undefined
 158:	35020000 	cbnz	w0, 4158 <_start-0x3fffbea8>
 15c:	00000000 	udf	#0
 160:	0001720c 	.inst	0x0001720c ; undefined
 164:	0f040400 	movi	v0.2s, #0x80
 168:	00000062 	udf	#98
 16c:	0001650d 	.inst	0x0001650d ; undefined
 170:	06090100 	.inst	0x06090100 ; undefined
 174:	4000006c 	.inst	0x4000006c ; undefined
 178:	00000000 	udf	#0
 17c:	00000044 	udf	#68
 180:	00000000 	udf	#0
 184:	0f0e9c01 	sqrshrn	v1.8b, v0.8h, #2
 188:	1b010069 	madd	w9, w3, w1, w0
 18c:	00005d15 	udf	#23829
 190:	00000000 	udf	#0
 194:	00000b58 	udf	#2904
 198:	08010005 	stxrb	w1, w5, [x0]
 19c:	000000f4 	udf	#244
 1a0:	00009c11 	udf	#39953
 1a4:	00bd1d00 	.inst	0x00bd1d00 ; undefined
 1a8:	00000000 	udf	#0
 1ac:	00b00000 	.inst	0x00b00000 ; undefined
 1b0:	00004000 	udf	#16384
 1b4:	084c0000 	ldxrb	w0, [x0]
 1b8:	00000000 	udf	#0
 1bc:	011a0000 	.inst	0x011a0000 ; undefined
 1c0:	01060000 	.inst	0x01060000 ; undefined
 1c4:	00011406 	.inst	0x00011406 ; undefined
 1c8:	007f0300 	.inst	0x007f0300 ; undefined
 1cc:	0a0c0000 	and	w0, w0, w12
 1d0:	00004117 	udf	#16663
 1d4:	08010600 	stxrb	w1, w0, [x16]
 1d8:	00000112 	udf	#274
 1dc:	7d050206 	str	h6, [x16, #640]
 1e0:	03000001 	.inst	0x03000001 ; undefined
 1e4:	000002c2 	udf	#706
 1e8:	5b180d0c 	.inst	0x5b180d0c ; undefined
 1ec:	06000000 	.inst	0x06000000 ; undefined
 1f0:	012a0702 	.inst	0x012a0702 ; undefined
 1f4:	04120000 	smulh	z0.b, p0/m, z0.b, z0.b
 1f8:	746e6905 	.inst	0x746e6905 ; undefined
 1fc:	00700300 	.inst	0x00700300 ; undefined
 200:	100c0000 	adr	x0, 18200 <_start-0x3ffe7e00>
 204:	00007516 	udf	#29974
 208:	07040600 	.inst	0x07040600 ; undefined
 20c:	0000008f 	udf	#143
 210:	00007513 	udf	#29971
 214:	05080600 	.inst	0x05080600 ; undefined
 218:	00000062 	udf	#98
 21c:	0003ae03 	.inst	0x0003ae03 ; undefined
 220:	1c130c00 	ldr	s0, 263a0 <_start-0x3ffd9c60>
 224:	00000094 	udf	#148
 228:	85070806 	.inst	0x85070806 ; undefined
 22c:	06000000 	.inst	0x06000000 ; undefined
 230:	00670508 	.inst	0x00670508 ; undefined
 234:	7f030000 	.inst	0x7f030000 ; undefined
 238:	0c000003 	st4	{v3.8b-v6.8b}, [x0]
 23c:	00b3171e 	.inst	0x00b3171e ; undefined
 240:	a20b0000 	.inst	0xa20b0000 ; undefined
 244:	06000000 	.inst	0x06000000 ; undefined
 248:	008a0708 	.inst	0x008a0708 ; undefined
 24c:	750f0000 	.inst	0x750f0000 ; undefined
 250:	0d000000 	st1	{v0.b}[0], [x0]
 254:	0000de04 	udf	#56836
 258:	013d0700 	.inst	0x013d0700 ; undefined
 25c:	07000000 	.inst	0x07000000 ; undefined
 260:	00000147 	udf	#327
 264:	01510701 	.inst	0x01510701 ; undefined
 268:	07020000 	.inst	0x07020000 ; undefined
 26c:	0000015b 	udf	#347
 270:	77030003 	.inst	0x77030003 ; undefined
 274:	0d000000 	st1	{v0.b}[0], [x0]
 278:	00ba0309 	.inst	0x00ba0309 ; undefined
 27c:	de0b0000 	.inst	0xde0b0000 ; undefined
 280:	03000000 	.inst	0x03000000 ; undefined
 284:	0000044b 	udf	#1099
 288:	7c1f030e 	stur	h14, [x24, #-16]
 28c:	03000000 	.inst	0x03000000 ; undefined
 290:	000001ab 	udf	#427
 294:	0710060e 	.inst	0x0710060e ; undefined
 298:	0a000001 	and	w1, w0, w0
 29c:	000000ef 	udf	#239
 2a0:	1f130108 	fmadd	s8, s8, s19, s0
 2a4:	09000001 	.inst	0x09000001 ; undefined
 2a8:	006c6176 	.inst	0x006c6176 ; undefined
 2ac:	00691301 	.inst	0x00691301 ; undefined
 2b0:	03000000 	.inst	0x03000000 ; undefined
 2b4:	0000043d 	udf	#1085
 2b8:	0c011301 	.inst	0x0c011301 ; undefined
 2bc:	08000001 	stxrb	w0, w1, [x0]
 2c0:	013e1202 	.inst	0x013e1202 ; undefined
 2c4:	76090000 	.inst	0x76090000 ; undefined
 2c8:	02006c61 	.inst	0x02006c61 ; undefined
 2cc:	00006912 	udf	#26898
 2d0:	01030000 	.inst	0x01030000 ; undefined
 2d4:	02000005 	.inst	0x02000005 ; undefined
 2d8:	012b0112 	.inst	0x012b0112 ; undefined
 2dc:	03080000 	.inst	0x03080000 ; undefined
 2e0:	00015d12 	.inst	0x00015d12 ; undefined
 2e4:	61760900 	.inst	0x61760900 ; undefined
 2e8:	1203006c 	and	w12, w3, #0x20000000
 2ec:	00000069 	udf	#105
 2f0:	057e0300 	ext	z0.b, {z24.b-z25.b}, #240
 2f4:	12030000 	and	w0, w0, #0x20000000
 2f8:	00014a01 	.inst	0x00014a01 ; undefined
 2fc:	12040800 	and	w0, w0, #0x70000000
 300:	0000017c 	udf	#380
 304:	6c617609 	ldnp	d9, d29, [x16, #-496]
 308:	69120400 	stgp	x0, x1, [x0, #576]
 30c:	00000000 	udf	#0
 310:	0002c903 	.inst	0x0002c903 ; undefined
 314:	01120400 	.inst	0x01120400 ; undefined
 318:	00000169 	udf	#361
 31c:	9b120508 	madd	x8, x8, x18, x1
 320:	09000001 	.inst	0x09000001 ; undefined
 324:	006c6176 	.inst	0x006c6176 ; undefined
 328:	00691205 	.inst	0x00691205 ; undefined
 32c:	03000000 	.inst	0x03000000 ; undefined
 330:	000001c0 	udf	#448
 334:	88011205 	stxr	w1, w5, [x16]
 338:	08000001 	stxrb	w0, w1, [x0]
 33c:	01ba1206 	.inst	0x01ba1206 ; undefined
 340:	76090000 	.inst	0x76090000 ; undefined
 344:	06006c61 	.inst	0x06006c61 ; undefined
 348:	00006912 	udf	#26898
 34c:	df030000 	.inst	0xdf030000 ; undefined
 350:	06000004 	.inst	0x06000004 ; undefined
 354:	01a70112 	.inst	0x01a70112 ; undefined
 358:	07080000 	.inst	0x07080000 ; undefined
 35c:	0001d912 	.inst	0x0001d912 ; undefined
 360:	61760900 	.inst	0x61760900 ; undefined
 364:	1207006c 	and	w12, w3, #0x2000000
 368:	00000069 	udf	#105
 36c:	04b70300 	add	z0.s, z24.s, z23.s
 370:	12070000 	and	w0, w0, #0x2000000
 374:	0001c601 	.inst	0x0001c601 ; undefined
 378:	00750f00 	.inst	0x00750f00 ; undefined
 37c:	2a070000 	orr	w0, w0, w7
 380:	0000021b 	udf	#539
 384:	00029007 	.inst	0x00029007 ; undefined
 388:	77070000 	.inst	0x77070000 ; undefined
 38c:	01000002 	.inst	0x01000002 ; undefined
 390:	00025e07 	.inst	0x00025e07 ; undefined
 394:	45070200 	.inst	0x45070200 ; undefined
 398:	03000002 	.inst	0x03000002 ; undefined
 39c:	00022c07 	.inst	0x00022c07 ; undefined
 3a0:	13070400 	sbfiz	w0, w0, #25, #2
 3a4:	05000002 	orr	z2.s, z2.s, #0x1
 3a8:	0002a907 	.inst	0x0002a907 ; undefined
 3ac:	03000600 	.inst	0x03000600 ; undefined
 3b0:	000003cd 	udf	#973
 3b4:	e5033307 	stnt1w	{z7.d}, p4, [z24.d, x3]
 3b8:	08000001 	stxrb	w0, w1, [x0]
 3bc:	023a1208 	.inst	0x023a1208 ; undefined
 3c0:	76090000 	.inst	0x76090000 ; undefined
 3c4:	08006c61 	stxrb	w0, w1, [x3]
 3c8:	00006912 	udf	#26898
 3cc:	e3030000 	.inst	0xe3030000 ; undefined
 3d0:	08000002 	stxrb	w0, w2, [x0]
 3d4:	02270112 	.inst	0x02270112 ; undefined
 3d8:	09080000 	.inst	0x09080000 ; undefined
 3dc:	00025912 	.inst	0x00025912 ; undefined
 3e0:	61760900 	.inst	0x61760900 ; undefined
 3e4:	1209006c 	and	w12, w3, #0x800000
 3e8:	00000069 	udf	#105
 3ec:	04160300 	.inst	0x04160300 ; undefined
 3f0:	12090000 	and	w0, w0, #0x800000
 3f4:	00024601 	.inst	0x00024601 ; undefined
 3f8:	02590b00 	.inst	0x02590b00 ; undefined
 3fc:	0a080000 	and	w0, w0, w8
 400:	00027d11 	.inst	0x00027d11 ; undefined
 404:	61760900 	.inst	0x61760900 ; undefined
 408:	110a006c 	add	w12, w3, #0x280
 40c:	00000069 	udf	#105
 410:	05b80300 	zip1	z0.q, z24.q, z24.q
 414:	110a0000 	add	w0, w0, #0x280
 418:	00026a01 	.inst	0x00026a01 ; undefined
 41c:	00ae1400 	.inst	0x00ae1400 ; undefined
 420:	02990000 	.inst	0x02990000 ; undefined
 424:	b3150000 	.inst	0xb3150000 ; undefined
 428:	03000000 	.inst	0x03000000 ; undefined
 42c:	02890b00 	.inst	0x02890b00 ; undefined
 430:	ab040000 	adds	x0, x0, x4
 434:	0b000004 	add	w4, w0, w0
 438:	00029916 	.inst	0x00029916 ; undefined
 43c:	10030900 	adr	x0, 655c <_start-0x3fff9aa4>
 440:	00400009 	.inst	0x00400009 ; undefined
 444:	0c000000 	st4	{v0.8b-v3.8b}, [x0]
 448:	00000191 	udf	#401
 44c:	0007843b 	.inst	0x0007843b ; undefined
 450:	00000040 	udf	#64
 454:	00017800 	.inst	0x00017800 ; undefined
 458:	00000000 	udf	#0
 45c:	5e9c0100 	.inst	0x5e9c0100 ; undefined
 460:	01000003 	.inst	0x01000003 ; undefined
 464:	0b006469 	add	w9, w3, w0, lsl #25
 468:	00de183b 	.inst	0x00de183b ; undefined
 46c:	91030000 	add	x0, x0, #0xc0
 470:	d7047fac 	.inst	0xd7047fac ; undefined
 474:	3e000002 	.inst	0x3e000002 ; undefined
 478:	0000a20a 	udf	#41482
 47c:	78910200 	ldursh	x0, [x16, #-240]
 480:	00049104 	.inst	0x00049104 ; undefined
 484:	5d104000 	.inst	0x5d104000 ; undefined
 488:	02000001 	.inst	0x02000001 ; undefined
 48c:	96047091 	bl	fffffffff811c6d0 <__stack_el2_top+0xffffffffb721b6d0>
 490:	44000004 	.inst	0x44000004 ; undefined
 494:	00017c10 	.inst	0x00017c10 ; undefined
 498:	68910200 	stgp	x0, x0, [x16], #544
 49c:	00049b04 	.inst	0x00049b04 ; undefined
 4a0:	9b104d00 	madd	x0, x8, x16, x19
 4a4:	02000001 	.inst	0x02000001 ; undefined
 4a8:	a0046091 	ldnt1d	{z16.d-z17.d}, pn8/z, [x4, x4, lsl #3]
 4ac:	54000004 	b.mi	4ac <_start-0x3ffffb54>  // b.first
 4b0:	0001ba10 	.inst	0x0001ba10 ; undefined
 4b4:	58910200 	ldr	x0, fffffffffff224f4 <__stack_el2_top+0xffffffffbf0214f4>
 4b8:	00042304 	.inst	0x00042304 ; undefined
 4bc:	d9105800 	.inst	0xd9105800 ; undefined
 4c0:	02000001 	.inst	0x02000001 ; undefined
 4c4:	7c045091 	stur	h17, [x4, #69]
 4c8:	5e000004 	sha1c	q4, s0, v0.4s
 4cc:	00011f10 	.inst	0x00011f10 ; undefined
 4d0:	48910200 	stllrh	w0, [x16]
 4d4:	0004c504 	.inst	0x0004c504 ; undefined
 4d8:	3e106200 	.inst	0x3e106200 ; undefined
 4dc:	02000001 	.inst	0x02000001 ; undefined
 4e0:	27044091 	.inst	0x27044091 ; undefined
 4e4:	66000005 	.inst	0x66000005 ; undefined
 4e8:	00023a10 	.inst	0x00023a10 ; undefined
 4ec:	b8910300 	ldursw	x0, [x24, #-240]
 4f0:	b50c007f 	cbnz	xzr, 184fc <_start-0x3ffe7b04>
 4f4:	29000001 	stp	w1, w0, [x0]
 4f8:	400006ec 	.inst	0x400006ec ; undefined
 4fc:	00000000 	udf	#0
 500:	00000098 	udf	#152
 504:	00000000 	udf	#0
 508:	03e39c01 	.inst	0x03e39c01 ; undefined
 50c:	69010000 	stgp	x0, x0, [x0, #32]
 510:	290b0064 	stp	w4, w0, [x3, #88]
 514:	0000de19 	udf	#56857
 518:	5c910200 	ldr	d0, fffffffffff22558 <__stack_el2_top+0xffffffffbf021558>
 51c:	0002d704 	.inst	0x0002d704 ; undefined
 520:	a20a2b00 	.inst	0xa20a2b00 ; undefined
 524:	02000000 	.inst	0x02000000 ; undefined
 528:	96047091 	bl	fffffffff811c76c <__stack_el2_top+0xffffffffb721b76c>
 52c:	2c000004 	stnp	s4, s0, [x0]
 530:	00017c10 	.inst	0x00017c10 ; undefined
 534:	68910200 	stgp	x0, x0, [x16], #544
 538:	00072410 	.inst	0x00072410 ; undefined
 53c:	00000040 	udf	#64
 540:	00005000 	udf	#20480
 544:	00000000 	udf	#0
 548:	74750e00 	.inst	0x74750e00 ; undefined
 54c:	10330073 	adr	x19, 66558 <_start-0x3ff99aa8>
 550:	00000259 	udf	#601
 554:	10609102 	adr	x2, c1774 <_start-0x3ff3e88c>
 558:	40000724 	.inst	0x40000724 ; undefined
 55c:	00000000 	udf	#0
 560:	00000024 	udf	#36
 564:	00000000 	udf	#0
 568:	3100690e 	adds	w14, w8, #0x1a
 56c:	0000880f 	udf	#34831
 570:	78910200 	ldursh	x0, [x16, #-240]
 574:	0c000000 	st4	{v0.8b-v3.8b}, [x0]
 578:	00000187 	udf	#391
 57c:	00069c24 	.inst	0x00069c24 ; undefined
 580:	00000040 	udf	#64
 584:	00005000 	udf	#20480
 588:	00000000 	udf	#0
 58c:	1b9c0100 	.inst	0x1b9c0100 ; undefined
 590:	01000004 	.inst	0x01000004 ; undefined
 594:	0b006469 	add	w9, w3, w0, lsl #25
 598:	00ea1e24 	.inst	0x00ea1e24 ; undefined
 59c:	91020000 	add	x0, x0, #0x80
 5a0:	0073017c 	.inst	0x0073017c ; undefined
 5a4:	1b2e240b 	.inst	0x1b2e240b ; undefined
 5a8:	02000004 	.inst	0x02000004 ; undefined
 5ac:	0a007091 	and	w17, w4, w0, lsl #28
 5b0:	00000427 	udf	#1063
 5b4:	1b080106 	madd	w6, w8, w8, w0
 5b8:	0b000001 	add	w1, w0, w0
 5bc:	00000420 	udf	#1056
 5c0:	0001200c 	.inst	0x0001200c ; undefined
 5c4:	06341900 	.inst	0x06341900 ; undefined
 5c8:	00004000 	udf	#16384
 5cc:	00680000 	.inst	0x00680000 ; undefined
 5d0:	00000000 	udf	#0
 5d4:	9c010000 	ldr	q0, 25d4 <_start-0x3fffda2c>
 5d8:	00000472 	udf	#1138
 5dc:	00646901 	.inst	0x00646901 ; undefined
 5e0:	de18190b 	.inst	0xde18190b ; undefined
 5e4:	02000000 	.inst	0x02000000 ; undefined
 5e8:	63016c91 	.inst	0x63016c91 ; undefined
 5ec:	22190b00 	.inst	0x22190b00 ; undefined
 5f0:	00000035 	udf	#53
 5f4:	046b9102 	asr	z2.s, z8.s, #21
 5f8:	000003fb 	udf	#1019
 5fc:	027d101b 	.inst	0x027d101b ; undefined
 600:	91020000 	add	x0, x0, #0x80
 604:	dd160078 	.inst	0xdd160078 ; undefined
 608:	0b000001 	add	w1, w0, w0
 60c:	04b21413 	uqadd	z19.s, z0.s, z18.s
 610:	06080000 	.inst	0x06080000 ; undefined
 614:	00004000 	udf	#16384
 618:	002c0000 	.inst	0x002c0000 ; NYI
 61c:	00000000 	udf	#0
 620:	9c010000 	ldr	q0, 2620 <_start-0x3fffd9e0>
 624:	000004b2 	udf	#1202
 628:	0002d705 	.inst	0x0002d705 ; undefined
 62c:	2e130b00 	ext	v0.8b, v24.8b, v19.8b, #1
 630:	000000a2 	udf	#162
 634:	0e689102 	sqdmlal	v2.4s, v8.4h, v8.4h
 638:	00737475 	.inst	0x00737475 ; undefined
 63c:	02590f15 	.inst	0x02590f15 ; undefined
 640:	91020000 	add	x0, x0, #0x80
 644:	01060078 	.inst	0x01060078 ; undefined
 648:	0004a502 	.inst	0x0004a502 ; undefined
 64c:	04810200 	sub	z0.s, p0/m, z0.s, z16.s
 650:	130a0000 	sbfiz	w0, w0, #22, #1
 654:	400005e4 	.inst	0x400005e4 ; undefined
 658:	00000000 	udf	#0
 65c:	00000024 	udf	#36
 660:	00000000 	udf	#0
 664:	04f39c01 	lsl	z1.d, z0.d, #51
 668:	d7050000 	.inst	0xd7050000 ; undefined
 66c:	0a000002 	and	w2, w0, w0
 670:	00a20113 	.inst	0x00a20113 ; undefined
 674:	91020000 	add	x0, x0, #0x80
 678:	00760178 	.inst	0x00760178 ; undefined
 67c:	7d01130a 	str	h10, [x24, #136]
 680:	02000002 	.inst	0x02000002 ; undefined
 684:	0d007091 	st3	{v17.h-v19.h}[2], [x4]
 688:	000003b5 	udf	#949
 68c:	04b25109 	.inst	0x04b25109 ; undefined
 690:	05c00000 	dupm	z0.s, #0x1
 694:	00004000 	udf	#16384
 698:	00240000 	.inst	0x00240000 ; NYI
 69c:	00000000 	udf	#0
 6a0:	9c010000 	ldr	q0, 26a0 <_start-0x3fffd960>
 6a4:	00000522 	udf	#1314
 6a8:	09007201 	.inst	0x09007201 ; undefined
 6ac:	02650151 	.inst	0x02650151 ; undefined
 6b0:	91020000 	add	x0, x0, #0x80
 6b4:	3c0d0078 	stur	b24, [x3, #208]
 6b8:	09000003 	.inst	0x09000003 ; undefined
 6bc:	0004b247 	.inst	0x0004b247 ; undefined
 6c0:	00059c00 	.inst	0x00059c00 ; undefined
 6c4:	00000040 	udf	#64
 6c8:	00002400 	udf	#9216
 6cc:	00000000 	udf	#0
 6d0:	519c0100 	.inst	0x519c0100 ; undefined
 6d4:	01000005 	.inst	0x01000005 ; undefined
 6d8:	47090072 	.inst	0x47090072 ; undefined
 6dc:	00026501 	.inst	0x00026501 ; undefined
 6e0:	78910200 	ldursh	x0, [x16, #-240]
 6e4:	03dd0d00 	.inst	0x03dd0d00 ; undefined
 6e8:	14090000 	b	2406e8 <_start-0x3fdbf918>
 6ec:	00000259 	udf	#601
 6f0:	40000580 	.inst	0x40000580 ; undefined
 6f4:	00000000 	udf	#0
 6f8:	0000001c 	udf	#28
 6fc:	00000000 	udf	#0
 700:	05829c01 	and	z1.d, z1.d, #0xffffe00000003fff
 704:	d7050000 	.inst	0xd7050000 ; undefined
 708:	09000002 	.inst	0x09000002 ; undefined
 70c:	00a20114 	.inst	0x00a20114 ; undefined
 710:	91020000 	add	x0, x0, #0x80
 714:	2c020078 	stnp	s24, s0, [x3, #16]
 718:	08000003 	stxrb	w0, w3, [x0]
 71c:	00055c17 	.inst	0x00055c17 ; undefined
 720:	00000040 	udf	#64
 724:	00002400 	udf	#9216
 728:	00000000 	udf	#0
 72c:	bc9c0100 	.inst	0xbc9c0100 ; undefined
 730:	05000005 	orr	z5.s, z5.s, #0x1
 734:	000002d7 	udf	#727
 738:	a2011708 	.inst	0xa2011708 ; undefined
 73c:	02000000 	.inst	0x02000000 ; undefined
 740:	76017891 	.inst	0x76017891 ; undefined
 744:	01170800 	.inst	0x01170800 ; undefined
 748:	0000023a 	udf	#570
 74c:	00709102 	.inst	0x00709102 ; undefined
 750:	00052c02 	.inst	0x00052c02 ; undefined
 754:	283f0700 	stnp	w0, w1, [x24, #-8]
 758:	00400005 	.inst	0x00400005 ; undefined
 75c:	34000000 	cbz	w0, 75c <_start-0x3ffff8a4>
 760:	00000000 	udf	#0
 764:	01000000 	.inst	0x01000000 ; undefined
 768:	0005f49c 	.inst	0x0005f49c ; undefined
 76c:	00720100 	.inst	0x00720100 ; undefined
 770:	f4013f07 	.inst	0xf4013f07 ; undefined
 774:	02000005 	.inst	0x02000005 ; undefined
 778:	76017891 	.inst	0x76017891 ; undefined
 77c:	013f0700 	.inst	0x013f0700 ; undefined
 780:	00000035 	udf	#53
 784:	00779102 	.inst	0x00779102 ; undefined
 788:	0001d90a 	.inst	0x0001d90a ; undefined
 78c:	05a10200 	zip1	z0.q, z16.q, z1.q
 790:	35070000 	cbnz	w0, e790 <_start-0x3fff1870>
 794:	400004f0 	.inst	0x400004f0 ; undefined
 798:	00000000 	udf	#0
 79c:	00000038 	udf	#56
 7a0:	00000000 	udf	#0
 7a4:	06319c01 	.inst	0x06319c01 ; undefined
 7a8:	72010000 	ands	w0, w0, #0x80000000
 7ac:	01350700 	.inst	0x01350700 ; undefined
 7b0:	000005f4 	udf	#1524
 7b4:	01789102 	.inst	0x01789102 ; undefined
 7b8:	35070076 	cbnz	w22, e7c4 <_start-0x3fff183c>
 7bc:	00021b01 	.inst	0x00021b01 ; undefined
 7c0:	74910200 	.inst	0x74910200 ; undefined
 7c4:	05420200 	eor	z0.d, z0.d, #0x1ffff
 7c8:	24070000 	cmphs	p0.b, p0/z, z0.b, z7.b
 7cc:	400004b8 	.inst	0x400004b8 ; undefined
 7d0:	00000000 	udf	#0
 7d4:	00000038 	udf	#56
 7d8:	00000000 	udf	#0
 7dc:	06699c01 	.inst	0x06699c01 ; undefined
 7e0:	72010000 	ands	w0, w0, #0x80000000
 7e4:	01240700 	.inst	0x01240700 ; undefined
 7e8:	000005f4 	udf	#1524
 7ec:	01789102 	.inst	0x01789102 ; undefined
 7f0:	24070076 	cmphi	p6.b, p0/z, z3.b, z7.b
 7f4:	00003501 	udf	#13569
 7f8:	77910200 	.inst	0x77910200 ; undefined
 7fc:	031c0200 	.inst	0x031c0200 ; undefined
 800:	17070000 	b	fffffffffc1c0800 <__stack_el2_top+0xffffffffbb2bf800>
 804:	40000494 	.inst	0x40000494 ; undefined
 808:	00000000 	udf	#0
 80c:	00000024 	udf	#36
 810:	00000000 	udf	#0
 814:	06a39c01 	.inst	0x06a39c01 ; undefined
 818:	d7050000 	.inst	0xd7050000 ; undefined
 81c:	07000002 	.inst	0x07000002 ; undefined
 820:	00a20117 	.inst	0x00a20117 ; undefined
 824:	91020000 	add	x0, x0, #0x80
 828:	00760178 	.inst	0x00760178 ; undefined
 82c:	d9011707 	.inst	0xd9011707 ; undefined
 830:	02000001 	.inst	0x02000001 ; undefined
 834:	02007091 	.inst	0x02007091 ; undefined
 838:	00000397 	udf	#919
 83c:	045c2406 	orqv	v6.8h, p1, z0.h
 840:	00004000 	udf	#16384
 844:	00380000 	.inst	0x00380000 ; NYI
 848:	00000000 	udf	#0
 84c:	9c010000 	ldr	q0, 284c <_start-0x3fffd7b4>
 850:	000006db 	udf	#1755
 854:	06007201 	.inst	0x06007201 ; undefined
 858:	06db0124 	.inst	0x06db0124 ; undefined
 85c:	91020000 	add	x0, x0, #0x80
 860:	00760178 	.inst	0x00760178 ; undefined
 864:	35012406 	cbnz	w6, 2ce4 <_start-0x3fffd31c>
 868:	02000000 	.inst	0x02000000 ; undefined
 86c:	0a007791 	and	w17, w28, w0, lsl #29
 870:	000001ba 	udf	#442
 874:	00055802 	.inst	0x00055802 ; undefined
 878:	38170600 	strb	w0, [x16], #-144
 87c:	00400004 	.inst	0x00400004 ; undefined
 880:	24000000 	cmphs	p0.b, p0/z, z0.b, z0.b
 884:	00000000 	udf	#0
 888:	01000000 	.inst	0x01000000 ; undefined
 88c:	00071a9c 	.inst	0x00071a9c ; undefined
 890:	02d70500 	.inst	0x02d70500 ; undefined
 894:	17060000 	b	fffffffffc180894 <__stack_el2_top+0xffffffffbb27f894>
 898:	0000a201 	udf	#41473
 89c:	78910200 	ldursh	x0, [x16, #-240]
 8a0:	06007601 	.inst	0x06007601 ; undefined
 8a4:	01ba0117 	.inst	0x01ba0117 ; undefined
 8a8:	91020000 	add	x0, x0, #0x80
 8ac:	f1020070 	subs	x16, x3, #0x80
 8b0:	05000002 	orr	z2.s, z2.s, #0x1
 8b4:	00040063 	.inst	0x00040063 ; undefined
 8b8:	00000040 	udf	#64
 8bc:	00003800 	udf	#14336
 8c0:	00000000 	udf	#0
 8c4:	529c0100 	mov	w0, #0xe008                	// #57352
 8c8:	01000007 	.inst	0x01000007 ; undefined
 8cc:	63050072 	.inst	0x63050072 ; undefined
 8d0:	00075201 	.inst	0x00075201 ; undefined
 8d4:	78910200 	ldursh	x0, [x16, #-240]
 8d8:	05007601 	orr	z1.b, z1.b, #0x4
 8dc:	04b20163 	add	z3.s, z11.s, z18.s
 8e0:	91020000 	add	x0, x0, #0x80
 8e4:	9b0a0077 	madd	x23, x3, x10, x0
 8e8:	02000001 	.inst	0x02000001 ; undefined
 8ec:	000004ed 	udf	#1261
 8f0:	03c84505 	.inst	0x03c84505 ; undefined
 8f4:	00004000 	udf	#16384
 8f8:	00380000 	.inst	0x00380000 ; NYI
 8fc:	00000000 	udf	#0
 900:	9c010000 	ldr	q0, 2900 <_start-0x3fffd700>
 904:	0000078f 	udf	#1935
 908:	05007201 	orr	z1.s, z1.s, #0xfffc0007
 90c:	07520145 	.inst	0x07520145 ; undefined
 910:	91020000 	add	x0, x0, #0x80
 914:	00760178 	.inst	0x00760178 ; undefined
 918:	b2014505 	orr	x5, x8, #0x8001ffff8001ffff
 91c:	02000004 	.inst	0x02000004 ; undefined
 920:	02007791 	.inst	0x02007791 ; undefined
 924:	00000428 	udf	#1064
 928:	03904005 	.inst	0x03904005 ; undefined
 92c:	00004000 	udf	#16384
 930:	00380000 	.inst	0x00380000 ; NYI
 934:	00000000 	udf	#0
 938:	9c010000 	ldr	q0, 2938 <_start-0x3fffd6c8>
 93c:	000007c7 	udf	#1991
 940:	05007201 	orr	z1.s, z1.s, #0xfffc0007
 944:	07520140 	.inst	0x07520140 ; undefined
 948:	91020000 	add	x0, x0, #0x80
 94c:	00760178 	.inst	0x00760178 ; undefined
 950:	b2014005 	orr	x5, x0, #0x8000ffff8000ffff
 954:	02000004 	.inst	0x02000004 ; undefined
 958:	02007791 	.inst	0x02007791 ; undefined
 95c:	0000058c 	udf	#1420
 960:	03583b05 	.inst	0x03583b05 ; undefined
 964:	00004000 	udf	#16384
 968:	00380000 	.inst	0x00380000 ; NYI
 96c:	00000000 	udf	#0
 970:	9c010000 	ldr	q0, 2970 <_start-0x3fffd690>
 974:	000007ff 	udf	#2047
 978:	05007201 	orr	z1.s, z1.s, #0xfffc0007
 97c:	0752013b 	.inst	0x0752013b ; undefined
 980:	91020000 	add	x0, x0, #0x80
 984:	00760178 	.inst	0x00760178 ; undefined
 988:	b2013b05 	orr	x5, x24, #0x80003fff80003fff
 98c:	02000004 	.inst	0x02000004 ; undefined
 990:	02007791 	.inst	0x02007791 ; undefined
 994:	0000030c 	udf	#780
 998:	03341705 	.inst	0x03341705 ; undefined
 99c:	00004000 	udf	#16384
 9a0:	00240000 	.inst	0x00240000 ; NYI
 9a4:	00000000 	udf	#0
 9a8:	9c010000 	ldr	q0, 29a8 <_start-0x3fffd658>
 9ac:	00000839 	udf	#2105
 9b0:	0002d705 	.inst	0x0002d705 ; undefined
 9b4:	01170500 	.inst	0x01170500 ; undefined
 9b8:	000000a2 	udf	#162
 9bc:	01789102 	.inst	0x01789102 ; undefined
 9c0:	17050076 	b	fffffffffc140b98 <__stack_el2_top+0xffffffffbb23fb98>
 9c4:	00019b01 	.inst	0x00019b01 ; undefined
 9c8:	70910200 	adr	x0, fffffffffff22a0b <__stack_el2_top+0xffffffffbf021a0b>
 9cc:	03530200 	.inst	0x03530200 ; undefined
 9d0:	71040000 	subs	w0, w0, #0x100
 9d4:	40000304 	.inst	0x40000304 ; undefined
 9d8:	00000000 	udf	#0
 9dc:	00000030 	udf	#48
 9e0:	00000000 	udf	#0
 9e4:	08719c01 	.inst	0x08719c01 ; undefined
 9e8:	72010000 	ands	w0, w0, #0x80000000
 9ec:	01710400 	.inst	0x01710400 ; undefined
 9f0:	00000871 	udf	#2161
 9f4:	01789102 	.inst	0x01789102 ; undefined
 9f8:	71040076 	subs	w22, w3, #0x100
 9fc:	0004b201 	.inst	0x0004b201 ; undefined
 a00:	77910200 	.inst	0x77910200 ; undefined
 a04:	017c0a00 	.inst	0x017c0a00 ; undefined
 a08:	69020000 	stgp	x0, x0, [x0, #64]
 a0c:	04000003 	add	z3.b, p0/m, z3.b, z0.b
 a10:	0002cc6c 	.inst	0x0002cc6c ; undefined
 a14:	00000040 	udf	#64
 a18:	00003800 	udf	#14336
 a1c:	00000000 	udf	#0
 a20:	ae9c0100 	.inst	0xae9c0100 ; undefined
 a24:	01000008 	.inst	0x01000008 ; undefined
 a28:	6c040072 	stnp	d18, d0, [x3, #64]
 a2c:	00087101 	.inst	0x00087101 ; undefined
 a30:	78910200 	ldursh	x0, [x16, #-240]
 a34:	04007601 	mls	z1.b, p5/m, z16.b, z0.b
 a38:	04b2016c 	add	z12.s, z11.s, z18.s
 a3c:	91020000 	add	x0, x0, #0x80
 a40:	68020077 	.inst	0x68020077 ; undefined
 a44:	04000005 	add	z5.b, p0/m, z5.b, z0.b
 a48:	00029467 	.inst	0x00029467 ; undefined
 a4c:	00000040 	udf	#64
 a50:	00003800 	udf	#14336
 a54:	00000000 	udf	#0
 a58:	e69c0100 	.inst	0xe69c0100 ; undefined
 a5c:	01000008 	.inst	0x01000008 ; undefined
 a60:	67040072 	.inst	0x67040072 ; undefined
 a64:	00087101 	.inst	0x00087101 ; undefined
 a68:	78910200 	ldursh	x0, [x16, #-240]
 a6c:	04007601 	mls	z1.b, p5/m, z16.b, z0.b
 a70:	04b20167 	add	z7.s, z11.s, z18.s
 a74:	91020000 	add	x0, x0, #0x80
 a78:	ef020077 	.inst	0xef020077 ; undefined
 a7c:	04000001 	add	z1.b, p0/m, z1.b, z0.b
 a80:	00025c58 	.inst	0x00025c58 ; undefined
 a84:	00000040 	udf	#64
 a88:	00003800 	udf	#14336
 a8c:	00000000 	udf	#0
 a90:	1e9c0100 	.inst	0x1e9c0100 ; undefined
 a94:	01000009 	.inst	0x01000009 ; undefined
 a98:	58040072 	ldr	x18, 8aa4 <_start-0x3fff755c>
 a9c:	00087101 	.inst	0x00087101 ; undefined
 aa0:	78910200 	ldursh	x0, [x16, #-240]
 aa4:	04007601 	mls	z1.b, p5/m, z16.b, z0.b
 aa8:	04b20158 	add	z24.s, z10.s, z18.s
 aac:	91020000 	add	x0, x0, #0x80
 ab0:	00020077 	.inst	0x00020077 ; undefined
 ab4:	04000004 	add	z4.b, p0/m, z4.b, z0.b
 ab8:	00022449 	.inst	0x00022449 ; undefined
 abc:	00000040 	udf	#64
 ac0:	00003800 	udf	#14336
 ac4:	00000000 	udf	#0
 ac8:	569c0100 	.inst	0x569c0100 ; undefined
 acc:	01000009 	.inst	0x01000009 ; undefined
 ad0:	49040072 	.inst	0x49040072 ; undefined
 ad4:	00087101 	.inst	0x00087101 ; undefined
 ad8:	78910200 	ldursh	x0, [x16, #-240]
 adc:	04007601 	mls	z1.b, p5/m, z16.b, z0.b
 ae0:	04b20149 	add	z9.s, z10.s, z18.s
 ae4:	91020000 	add	x0, x0, #0x80
 ae8:	66020077 	.inst	0x66020077 ; undefined
 aec:	04000004 	add	z4.b, p0/m, z4.b, z0.b
 af0:	0001ec2e 	.inst	0x0001ec2e ; undefined
 af4:	00000040 	udf	#64
 af8:	00003800 	udf	#14336
 afc:	00000000 	udf	#0
 b00:	8e9c0100 	.inst	0x8e9c0100 ; undefined
 b04:	01000009 	.inst	0x01000009 ; undefined
 b08:	2e040072 	ext	v18.8b, v3.8b, v4.8b, #0
 b0c:	00087101 	.inst	0x00087101 ; undefined
 b10:	78910200 	ldursh	x0, [x16, #-240]
 b14:	04007601 	mls	z1.b, p5/m, z16.b, z0.b
 b18:	04b2012e 	add	z14.s, z9.s, z18.s
 b1c:	91020000 	add	x0, x0, #0x80
 b20:	9b020077 	madd	x23, x3, x2, x0
 b24:	04000001 	add	z1.b, p0/m, z1.b, z0.b
 b28:	0001c817 	.inst	0x0001c817 ; undefined
 b2c:	00000040 	udf	#64
 b30:	00002400 	udf	#9216
 b34:	00000000 	udf	#0
 b38:	c89c0100 	stllr	x0, [x8]
 b3c:	05000009 	orr	z9.s, z9.s, #0x1
 b40:	000002d7 	udf	#727
 b44:	a2011704 	.inst	0xa2011704 ; undefined
 b48:	02000000 	.inst	0x02000000 ; undefined
 b4c:	76017891 	.inst	0x76017891 ; undefined
 b50:	01170400 	.inst	0x01170400 ; undefined
 b54:	0000017c 	udf	#380
 b58:	00709102 	.inst	0x00709102 ; undefined
 b5c:	0001ce0d 	.inst	0x0001ce0d ; undefined
 b60:	7c140400 	str	h0, [x0], #-192
 b64:	ac000001 	stnp	q1, q0, [x0]
 b68:	00400001 	.inst	0x00400001 ; undefined
 b6c:	1c000000 	ldr	s0, b6c <_start-0x3ffff494>
 b70:	00000000 	udf	#0
 b74:	01000000 	.inst	0x01000000 ; undefined
 b78:	0009f99c 	.inst	0x0009f99c ; undefined
 b7c:	02d70500 	.inst	0x02d70500 ; undefined
 b80:	14040000 	b	100b80 <_start-0x3feff480>
 b84:	0000a201 	udf	#41473
 b88:	78910200 	ldursh	x0, [x16, #-240]
 b8c:	050f0200 	.inst	0x050f0200 ; undefined
 b90:	24030000 	cmphs	p0.b, p0/z, z0.b, z3.b
 b94:	4000017c 	.inst	0x4000017c ; undefined
 b98:	00000000 	udf	#0
 b9c:	00000030 	udf	#48
 ba0:	00000000 	udf	#0
 ba4:	0a319c01 	.inst	0x0a319c01 ; undefined
 ba8:	72010000 	ands	w0, w0, #0x80000000
 bac:	01240300 	.inst	0x01240300 ; undefined
 bb0:	00000a31 	udf	#2609
 bb4:	01789102 	.inst	0x01789102 ; undefined
 bb8:	24030076 	cmphi	p6.b, p0/z, z3.b, z3.b
 bbc:	0004b201 	.inst	0x0004b201 ; undefined
 bc0:	77910200 	.inst	0x77910200 ; undefined
 bc4:	015d0a00 	.inst	0x015d0a00 ; undefined
 bc8:	03020000 	.inst	0x03020000 ; undefined
 bcc:	03000002 	.inst	0x03000002 ; undefined
 bd0:	00015817 	.inst	0x00015817 ; undefined
 bd4:	00000040 	udf	#64
 bd8:	00002400 	udf	#9216
 bdc:	00000000 	udf	#0
 be0:	709c0100 	adr	x0, fffffffffff38c03 <__stack_el2_top+0xffffffffbf037c03>
 be4:	0500000a 	orr	z10.s, z10.s, #0x1
 be8:	000002d7 	udf	#727
 bec:	a2011703 	.inst	0xa2011703 ; undefined
 bf0:	02000000 	.inst	0x02000000 ; undefined
 bf4:	76017891 	.inst	0x76017891 ; undefined
 bf8:	01170300 	.inst	0x01170300 ; undefined
 bfc:	0000015d 	udf	#349
 c00:	00709102 	.inst	0x00709102 ; undefined
 c04:	00045102 	.inst	0x00045102 ; undefined
 c08:	28230200 	stnp	w0, w0, [x16, #-232]
 c0c:	00400001 	.inst	0x00400001 ; undefined
 c10:	30000000 	adr	x0, c11 <_start-0x3ffff3ef>
 c14:	00000000 	udf	#0
 c18:	01000000 	.inst	0x01000000 ; undefined
 c1c:	000aa89c 	.inst	0x000aa89c ; undefined
 c20:	00720100 	.inst	0x00720100 ; undefined
 c24:	a8012302 	stnp	x2, x8, [x24, #16]
 c28:	0200000a 	.inst	0x0200000a ; undefined
 c2c:	76017891 	.inst	0x76017891 ; undefined
 c30:	01230200 	.inst	0x01230200 ; undefined
 c34:	0000004f 	udf	#79
 c38:	00769102 	.inst	0x00769102 ; undefined
 c3c:	00013e0a 	.inst	0x00013e0a ; undefined
 c40:	03870200 	.inst	0x03870200 ; undefined
 c44:	17020000 	b	fffffffffc080c44 <__stack_el2_top+0xffffffffbb17fc44>
 c48:	40000104 	.inst	0x40000104 ; undefined
 c4c:	00000000 	udf	#0
 c50:	00000024 	udf	#36
 c54:	00000000 	udf	#0
 c58:	0ae79c01 	.inst	0x0ae79c01 ; undefined
 c5c:	d7050000 	.inst	0xd7050000 ; undefined
 c60:	02000002 	.inst	0x02000002 ; undefined
 c64:	00a20117 	.inst	0x00a20117 ; undefined
 c68:	91020000 	add	x0, x0, #0x80
 c6c:	00760178 	.inst	0x00760178 ; undefined
 c70:	3e011702 	.inst	0x3e011702 ; undefined
 c74:	02000001 	.inst	0x02000001 ; undefined
 c78:	02007091 	.inst	0x02007091 ; undefined
 c7c:	000004ca 	udf	#1226
 c80:	00d42401 	.inst	0x00d42401 ; undefined
 c84:	00004000 	udf	#16384
 c88:	00300000 	.inst	0x00300000 ; NYI
 c8c:	00000000 	udf	#0
 c90:	9c010000 	ldr	q0, 2c90 <_start-0x3fffd370>
 c94:	00000b1f 	udf	#2847
 c98:	01007201 	.inst	0x01007201 ; undefined
 c9c:	0b1f0124 	add	w4, w9, wzr
 ca0:	91020000 	add	x0, x0, #0x80
 ca4:	00760178 	.inst	0x00760178 ; undefined
 ca8:	4f012401 	movi	v1.4s, #0x20, lsl #8
 cac:	02000000 	.inst	0x02000000 ; undefined
 cb0:	0a007691 	and	w17, w20, w0, lsl #29
 cb4:	0000011f 	udf	#287
 cb8:	0003eb17 	.inst	0x0003eb17 ; undefined
 cbc:	01180100 	.inst	0x01180100 ; undefined
 cc0:	400000b0 	.inst	0x400000b0 ; undefined
 cc4:	00000000 	udf	#0
 cc8:	00000024 	udf	#36
 ccc:	00000000 	udf	#0
 cd0:	d7059c01 	.inst	0xd7059c01 ; undefined
 cd4:	01000002 	.inst	0x01000002 ; undefined
 cd8:	00a20118 	.inst	0x00a20118 ; undefined
 cdc:	91020000 	add	x0, x0, #0x80
 ce0:	00760178 	.inst	0x00760178 ; undefined
 ce4:	1f011801 	fmadd	s1, s0, s1, s6
 ce8:	02000001 	.inst	0x02000001 ; undefined
 cec:	00007091 	udf	#28817

Disassembly of section .debug_abbrev:

0000000000000000 <.debug_abbrev>:
   0:	10001101 	adr	x1, 220 <_start-0x3ffffde0>
   4:	12011117 	and	w23, w8, #0x8000000f
   8:	1b0e030f 	madd	w15, w24, w14, w0
   c:	130e250e 	sbfiz	w14, w8, #18, #10
  10:	00000005 	udf	#5
  14:	10001101 	adr	x1, 234 <_start-0x3ffffdcc>
  18:	12011117 	and	w23, w8, #0x8000000f
  1c:	1b0e030f 	madd	w15, w24, w14, w0
  20:	130e250e 	sbfiz	w14, w8, #18, #10
  24:	00000005 	udf	#5
  28:	0b002401 	add	w1, w0, w0, lsl #9
  2c:	030b3e0b 	.inst	0x030b3e0b ; undefined
  30:	0200000e 	.inst	0x0200000e ; undefined
  34:	13490005 	.inst	0x13490005 ; undefined
  38:	28030000 	stnp	w0, w0, [x0, #24]
  3c:	1c0e0300 	ldr	s0, 1c09c <_start-0x3ffe3f64>
  40:	0400000b 	add	z11.b, p0/m, z11.b, z0.b
  44:	0e030016 	tbl	v22.8b, {v0.16b}, v3.8b
  48:	0b3b0b3a 	add	w26, w25, w27, uxtb #2
  4c:	13490b39 	.inst	0x13490b39 ; undefined
  50:	2e050000 	ext	v0.8b, v0.8b, v5.8b, #0
  54:	03193f01 	.inst	0x03193f01 ; undefined
  58:	03213a0e 	.inst	0x03213a0e ; undefined
  5c:	21390b3b 	.inst	0x21390b3b ; undefined
  60:	3c192706 	str	b6, [x24], #-110
  64:	00130119 	.inst	0x00130119 ; undefined
  68:	01110600 	.inst	0x01110600 ; undefined
  6c:	0b130e25 	add	w5, w17, w19, lsl #3
  70:	1f1b1f03 	fmadd	s3, s24, s27, s7
  74:	07120111 	.inst	0x07120111 ; undefined
  78:	00001710 	udf	#5904
  7c:	0b002407 	add	w7, w0, w0, lsl #9
  80:	030b3e0b 	.inst	0x030b3e0b ; undefined
  84:	08000008 	stxrb	w0, w8, [x0]
  88:	13490035 	.inst	0x13490035 ; undefined
  8c:	04090000 	umax	z0.b, p0/m, z0.b, z0.b
  90:	0b0b3e01 	add	w1, w16, w11, lsl #15
  94:	3a13490b 	.inst	0x3a13490b ; undefined
  98:	390b3b0b 	strb	w11, [x24, #718]
  9c:	0013010b 	.inst	0x0013010b ; undefined
  a0:	000f0a00 	.inst	0x000f0a00 ; undefined
  a4:	13490b0b 	.inst	0x13490b0b ; undefined
  a8:	260b0000 	.inst	0x260b0000 ; undefined
  ac:	00134900 	.inst	0x00134900 ; undefined
  b0:	002e0c00 	.inst	0x002e0c00 ; NYI
  b4:	0e03193f 	uzp1	v31.8b, v9.8b, v3.8b
  b8:	0b3b0b3a 	add	w26, w25, w27, uxtb #2
  bc:	19270b39 	rcwcas	x7, x25, [x25]
  c0:	193c1349 	ldclrp	x9, x28, [x26]
  c4:	2e0d0000 	ext	v0.8b, v0.8b, v13.8b, #0
  c8:	03193f01 	.inst	0x03193f01 ; undefined
  cc:	3b0b3a0e 	.inst	0x3b0b3a0e ; undefined
  d0:	270b390b 	.inst	0x270b390b ; undefined
  d4:	12011119 	and	w25, w8, #0x8000000f
  d8:	7c184007 	stur	h7, [x0, #-124]
  dc:	0e000019 	tbl	v25.8b, {v0.16b}, v0.8b
  e0:	0000010b 	udf	#267
  e4:	0300340f 	.inst	0x0300340f ; undefined
  e8:	3b0b3a08 	.inst	0x3b0b3a08 ; undefined
  ec:	490b390b 	.inst	0x490b390b ; undefined
  f0:	00000013 	udf	#19
  f4:	03000501 	.inst	0x03000501 ; undefined
  f8:	3b0b3a08 	.inst	0x3b0b3a08 ; undefined
  fc:	490b390b 	.inst	0x490b390b ; undefined
 100:	00180213 	.inst	0x00180213 ; undefined
 104:	012e0200 	.inst	0x012e0200 ; undefined
 108:	0b3a0e03 	add	w3, w16, w26, uxtb #3
 10c:	21390b3b 	.inst	0x21390b3b ; undefined
 110:	11192701 	add	w1, w24, #0x649
 114:	40071201 	.inst	0x40071201 ; undefined
 118:	01197a18 	.inst	0x01197a18 ; undefined
 11c:	03000013 	.inst	0x03000013 ; undefined
 120:	0e030016 	tbl	v22.8b, {v0.16b}, v3.8b
 124:	0b3b0b3a 	add	w26, w25, w27, uxtb #2
 128:	13490b39 	.inst	0x13490b39 ; undefined
 12c:	34040000 	cbz	w0, 812c <_start-0x3fff7ed4>
 130:	3a0e0300 	adcs	w0, w24, w14
 134:	0b3b0b21 	add	w1, w25, w27, uxtb #2
 138:	13490b39 	.inst	0x13490b39 ; undefined
 13c:	00001802 	udf	#6146
 140:	03000505 	.inst	0x03000505 ; undefined
 144:	3b0b3a0e 	.inst	0x3b0b3a0e ; undefined
 148:	490b390b 	.inst	0x490b390b ; undefined
 14c:	00180213 	.inst	0x00180213 ; undefined
 150:	00240600 	.inst	0x00240600 ; NYI
 154:	0b3e0b0b 	add	w11, w24, w30, uxtb #2
 158:	00000e03 	udf	#3587
 15c:	03002807 	.inst	0x03002807 ; undefined
 160:	000b1c0e 	.inst	0x000b1c0e ; undefined
 164:	01130800 	.inst	0x01130800 ; undefined
 168:	3a04210b 	.inst	0x3a04210b ; undefined
 16c:	390b3b0b 	strb	w11, [x24, #718]
 170:	13010121 	sbfiz	w1, w9, #31, #1
 174:	0d090000 	.inst	0x0d090000 ; undefined
 178:	3a080300 	adcs	w0, w24, w8
 17c:	390b3b0b 	strb	w11, [x24, #718]
 180:	13490121 	.inst	0x13490121 ; undefined
 184:	00002138 	udf	#8504
 188:	000f0a00 	.inst	0x000f0a00 ; undefined
 18c:	4908210b 	.inst	0x4908210b ; undefined
 190:	0b000013 	add	w19, w0, w0
 194:	13490026 	.inst	0x13490026 ; undefined
 198:	2e0c0000 	ext	v0.8b, v0.8b, v12.8b, #0
 19c:	03193f01 	.inst	0x03193f01 ; undefined
 1a0:	0b213a0e 	.inst	0x0b213a0e ; undefined
 1a4:	21390b3b 	.inst	0x21390b3b ; undefined
 1a8:	11192706 	add	w6, w24, #0x649
 1ac:	40071201 	.inst	0x40071201 ; undefined
 1b0:	01197c18 	.inst	0x01197c18 ; undefined
 1b4:	0d000013 	st1	{v19.b}[0], [x0]
 1b8:	0e03012e 	tbl	v14.8b, {v9.16b}, v3.8b
 1bc:	0b3b0b3a 	add	w26, w25, w27, uxtb #2
 1c0:	27012139 	.inst	0x27012139 ; undefined
 1c4:	11134919 	add	w25, w8, #0x4d2
 1c8:	40071201 	.inst	0x40071201 ; undefined
 1cc:	01197a18 	.inst	0x01197a18 ; undefined
 1d0:	0e000013 	tbl	v19.8b, {v0.16b}, v0.8b
 1d4:	08030034 	stxrb	w3, w20, [x1]
 1d8:	3b0b213a 	.inst	0x3b0b213a ; undefined
 1dc:	490b390b 	.inst	0x490b390b ; undefined
 1e0:	00180213 	.inst	0x00180213 ; undefined
 1e4:	01040f00 	.inst	0x01040f00 ; undefined
 1e8:	0b07213e 	add	w30, w9, w7, lsl #8
 1ec:	13490421 	.inst	0x13490421 ; undefined
 1f0:	0b3b0b3a 	add	w26, w25, w27, uxtb #2
 1f4:	010e2139 	.inst	0x010e2139 ; undefined
 1f8:	10000013 	adr	x19, 1f8 <_start-0x3ffffe08>
 1fc:	0111010b 	.inst	0x0111010b ; undefined
 200:	00000712 	udf	#1810
 204:	25011111 	cmpgt	p1.b, p4/z, z8.b, #1
 208:	030b130e 	.inst	0x030b130e ; undefined
 20c:	111f1b1f 	add	wsp, w24, #0x7c6
 210:	10071201 	adr	x1, e450 <_start-0x3fff1bb0>
 214:	12000017 	and	w23, w0, #0x1
 218:	0b0b0024 	add	w4, w1, w11
 21c:	08030b3e 	stxrb	w3, w30, [x25]
 220:	35130000 	cbnz	w0, 26220 <_start-0x3ffd9de0>
 224:	00134900 	.inst	0x00134900 ; undefined
 228:	01011400 	.inst	0x01011400 ; undefined
 22c:	13011349 	sbfx	w9, w26, #1, #4
 230:	21150000 	.inst	0x21150000 ; undefined
 234:	2f134900 	.inst	0x2f134900 ; undefined
 238:	1600000b 	b	fffffffff8000264 <__stack_el2_top+0xffffffffb70ff264>
 23c:	0e03012e 	tbl	v14.8b, {v9.16b}, v3.8b
 240:	0b3b0b3a 	add	w26, w25, w27, uxtb #2
 244:	19270b39 	rcwcas	x7, x25, [x25]
 248:	01111349 	.inst	0x01111349 ; undefined
 24c:	18400712 	ldr	w18, 8032c <_start-0x3ff7fcd4>
 250:	1301197c 	sbfx	w28, w11, #1, #6
 254:	2e170000 	ext	v0.8b, v0.8b, v23.8b, #0
 258:	3a0e0301 	adcs	w1, w24, w14
 25c:	390b3b0b 	strb	w11, [x24, #718]
 260:	1119270b 	add	w11, w24, #0x649
 264:	40071201 	.inst	0x40071201 ; undefined
 268:	00197a18 	.inst	0x00197a18 ; undefined
	...

Disassembly of section .debug_aranges:

0000000000000000 <.debug_aranges>:
   0:	0000002c 	udf	#44
   4:	00000002 	udf	#2
   8:	00080000 	.inst	0x00080000 ; undefined
   c:	00000000 	udf	#0
  10:	40000060 	.inst	0x40000060 ; undefined
  14:	00000000 	udf	#0
  18:	0000000c 	udf	#12
	...
  30:	0000002c 	udf	#44
  34:	00280002 	.inst	0x00280002 ; NYI
  38:	00080000 	.inst	0x00080000 ; undefined
  3c:	00000000 	udf	#0
  40:	40000000 	.inst	0x40000000 ; undefined
  44:	00000000 	udf	#0
  48:	00000060 	udf	#96
	...
  60:	0000002c 	udf	#44
  64:	00500002 	.inst	0x00500002 ; undefined
  68:	00080000 	.inst	0x00080000 ; undefined
  6c:	00000000 	udf	#0
  70:	4000006c 	.inst	0x4000006c ; undefined
  74:	00000000 	udf	#0
  78:	00000044 	udf	#68
	...
  90:	0000002c 	udf	#44
  94:	01940002 	.inst	0x01940002 ; undefined
  98:	00080000 	.inst	0x00080000 ; undefined
  9c:	00000000 	udf	#0
  a0:	400000b0 	.inst	0x400000b0 ; undefined
  a4:	00000000 	udf	#0
  a8:	0000084c 	udf	#2124
	...

Disassembly of section .debug_str:

0000000000000000 <.debug_str>:
   0:	6372735f 	.inst	0x6372735f ; undefined
   4:	62696c2f 	.inst	0x62696c2f ; undefined
   8:	72656b2f 	.inst	0x72656b2f ; undefined
   c:	5f6c656e 	.inst	0x5f6c656e ; undefined
  10:	6c697475 	ldnp	d21, d29, [x3, #-368]
  14:	00532e73 	.inst	0x00532e73 ; undefined
  18:	6d6f682f 	ldp	d15, d26, [x1, #-272]
  1c:	6e752f65 	uqsub	v5.8h, v27.8h, v21.8h
  20:	662f6261 	.inst	0x662f6261 ; undefined
  24:	73656c69 	.inst	0x73656c69 ; undefined
  28:	73616d2f 	.inst	0x73616d2f ; undefined
  2c:	2f726574 	.inst	0x2f726574 ; undefined
  30:	2f6d6674 	.inst	0x2f6d6674 ; undefined
  34:	38786d69 	.inst	0x38786d69 ; undefined
  38:	702f706d 	adr	x13, 5ee47 <_start-0x3ffa11b9>
  3c:	656a6f72 	fnmls	z18.h, p3/m, z27.h, z10.h
  40:	47007463 	.inst	0x47007463 ; undefined
  44:	4120554e 	.inst	0x4120554e ; undefined
  48:	2e322053 	usubl	v19.8h, v2.8b, v18.8b
  4c:	312e3334 	adds	w20, w25, #0xb8c
  50:	72735f00 	.inst	0x72735f00 ; undefined
  54:	6f622f63 	.inst	0x6f622f63 ; undefined
  58:	622f746f 	.inst	0x622f746f ; undefined
  5c:	2e746f6f 	umin	v15.4h, v27.4h, v20.4h
  60:	6f6c0053 	mla	v19.8h, v2.8h, v12.h[2]
  64:	6c20676e 	stnp	d14, d25, [x27, #-512]
  68:	20676e6f 	.inst	0x20676e6f ; undefined
  6c:	00746e69 	.inst	0x00746e69 ; undefined
  70:	746e6975 	.inst	0x746e6975 ; undefined
  74:	55003233 	.inst	0x55003233 ; undefined
  78:	5f545241 	.inst	0x5f545241 ; undefined
  7c:	75004449 	.inst	0x75004449 ; undefined
  80:	38746e69 	.inst	0x38746e69 ; undefined
  84:	6e6f6c00 	umin	v0.8h, v0.8h, v15.8h
  88:	6f6c2067 	umlal2	v7.4s, v3.8h, v12.h[2]
  8c:	7520676e 	.inst	0x7520676e ; undefined
  90:	6769736e 	.inst	0x6769736e ; undefined
  94:	2064656e 	.inst	0x2064656e ; undefined
  98:	00746e69 	.inst	0x00746e69 ; undefined
  9c:	20554e47 	.inst	0x20554e47 ; undefined
  a0:	20333243 	.inst	0x20333243 ; undefined
  a4:	322e3431 	orr	w17, w1, #0xfffc0000
  a8:	3220312e 	orr	w14, w9, #0x1fff
  ac:	31343230 	adds	w16, w17, #0xd0c
  b0:	20393131 	.inst	0x20393131 ; undefined
  b4:	72616d2d 	.inst	0x72616d2d ; undefined
  b8:	613d6863 	.inst	0x613d6863 ; undefined
  bc:	38766d72 	.inst	0x38766d72 ; undefined
  c0:	612d322e 	.inst	0x612d322e ; undefined
  c4:	636d2d20 	.inst	0x636d2d20 ; undefined
  c8:	633d7570 	.inst	0x633d7570 ; undefined
  cc:	6574726f 	fnmls	z15.h, p4/m, z19.h, z20.h
  d0:	37612d78 	tbnz	w24, #12, 267c <_start-0x3fffd984>
  d4:	6d2d2036 	stp	d22, d8, [x1, #-304]
  d8:	7474696c 	.inst	0x7474696c ; undefined
  dc:	652d656c 	.inst	0x652d656c ; undefined
  e0:	6169646e 	.inst	0x6169646e ; undefined
  e4:	6d2d206e 	stp	d14, d8, [x3, #-304]
  e8:	3d696261 	ldr	b1, [x19, #2648]
  ec:	3436706c 	cbz	w12, 6cef8 <_start-0x3ff93108>
  f0:	20672d20 	.inst	0x20672d20 ; undefined
  f4:	20304f2d 	.inst	0x20304f2d ; undefined
  f8:	6474732d 	.inst	0x6474732d ; undefined
  fc:	756e673d 	.inst	0x756e673d ; undefined
 100:	2d203332 	stp	s18, s12, [x25, #-256]
 104:	65726666 	fnmls	z6.h, p1/m, z19.h, z18.h
 108:	61747365 	.inst	0x61747365 ; undefined
 10c:	6e69646e 	umax	v14.8h, v3.8h, v9.8h
 110:	6e750067 	uaddl2	v7.4s, v3.8h, v21.8h
 114:	6e676973 	.inst	0x6e676973 ; undefined
 118:	63206465 	.inst	0x63206465 ; undefined
 11c:	00726168 	.inst	0x00726168 ; undefined
 120:	54524155 	bc.pl	a4948 <_start-0x3ff5b6b8>  // bc.nfrst
 124:	7475705f 	.inst	0x7475705f ; undefined
 128:	68730063 	.inst	0x68730063 ; undefined
 12c:	2074726f 	.inst	0x2074726f ; undefined
 130:	69736e75 	ldpsw	x21, x27, [x19, #-104]
 134:	64656e67 	.inst	0x64656e67 ; undefined
 138:	746e6920 	.inst	0x746e6920 ; undefined
 13c:	52415500 	.inst	0x52415500 ; undefined
 140:	44495f54 	umlslt	z20.h, z26.b, z9.b
 144:	5500315f 	.inst	0x5500315f ; undefined
 148:	5f545241 	.inst	0x5f545241 ; undefined
 14c:	325f4449 	.inst	0x325f4449 ; undefined
 150:	52415500 	.inst	0x52415500 ; undefined
 154:	44495f54 	umlslt	z20.h, z26.b, z9.b
 158:	5500335f 	.inst	0x5500335f ; undefined
 15c:	5f545241 	.inst	0x5f545241 ; undefined
 160:	345f4449 	cbz	w9, be9e8 <_start-0x3ff41618>
 164:	72656b00 	.inst	0x72656b00 ; undefined
 168:	5f6c656e 	.inst	0x5f6c656e ; undefined
 16c:	72746e65 	.inst	0x72746e65 ; undefined
 170:	635f0079 	.inst	0x635f0079 ; undefined
 174:	65727275 	fnmls	z21.h, p4/m, z19.h, z18.h
 178:	4c45746e 	.inst	0x4c45746e ; undefined
 17c:	6f687300 	fcmla	v0.8h, v24.8h, v8.h[1], #270
 180:	69207472 	stgp	x18, x29, [x3, #-1024]
 184:	5500746e 	.inst	0x5500746e ; undefined
 188:	5f545241 	.inst	0x5f545241 ; undefined
 18c:	73747570 	.inst	0x73747570 ; undefined
 190:	52415500 	.inst	0x52415500 ; undefined
 194:	6e695f54 	uqrshl	v20.8h, v26.8h, v9.8h
 198:	55007469 	.inst	0x55007469 ; undefined
 19c:	5f545241 	.inst	0x5f545241 ; undefined
 1a0:	32524355 	.inst	0x32524355 ; undefined
 1a4:	6972775f 	ldpsw	xzr, x29, [x26, #-112]
 1a8:	72006574 	ands	w20, w11, #0x3ffffff
 1ac:	32336765 	orr	w5, w27, #0xffffe07f
 1b0:	7274705f 	.inst	0x7274705f ; undefined
 1b4:	52415500 	.inst	0x52415500 ; undefined
 1b8:	65725f54 	fnmla	z20.h, p7/m, z26.h, z18.h
 1bc:	00746573 	.inst	0x00746573 ; undefined
 1c0:	74726155 	.inst	0x74726155 ; undefined
 1c4:	33726355 	.inst	0x33726355 ; undefined
 1c8:	756c6156 	.inst	0x756c6156 ; undefined
 1cc:	41550065 	.inst	0x41550065 ; undefined
 1d0:	555f5452 	.inst	0x555f5452 ; undefined
 1d4:	5f325243 	fmls	h3, h18, v2.h[3]
 1d8:	64616572 	.inst	0x64616572 ; undefined
 1dc:	52415500 	.inst	0x52415500 ; undefined
 1e0:	78745f54 	.inst	0x78745f54 ; undefined
 1e4:	6669665f 	.inst	0x6669665f ; undefined
 1e8:	75665f6f 	.inst	0x75665f6f ; undefined
 1ec:	55006c6c 	.inst	0x55006c6c ; undefined
 1f0:	5f545241 	.inst	0x5f545241 ; undefined
 1f4:	32524355 	.inst	0x32524355 ; undefined
 1f8:	5f46425f 	.inst	0x5f46425f ; undefined
 1fc:	5f746573 	.inst	0x5f746573 ; undefined
 200:	55005357 	.inst	0x55005357 ; undefined
 204:	5f545241 	.inst	0x5f545241 ; undefined
 208:	31524355 	adds	w21, w26, #0x490, lsl #12
 20c:	6972775f 	ldpsw	xzr, x29, [x26, #-112]
 210:	55006574 	.inst	0x55006574 ; undefined
 214:	5f545241 	.inst	0x5f545241 ; undefined
 218:	52434655 	.inst	0x52434655 ; undefined
 21c:	4446525f 	smlslb	z31.h, z18.b, z6.b
 220:	445f5649 	smlslt	z9.h, z18.b, z31.b
 224:	425f5649 	.inst	0x425f5649 ; undefined
 228:	00315f59 	.inst	0x00315f59 ; NYI
 22c:	54524155 	bc.pl	a4a54 <_start-0x3ff5b5ac>  // bc.nfrst
 230:	4346555f 	.inst	0x4346555f ; undefined
 234:	46525f52 	.inst	0x46525f52 ; undefined
 238:	5f564944 	.inst	0x5f564944 ; undefined
 23c:	5f564944 	.inst	0x5f564944 ; undefined
 240:	325f5942 	.inst	0x325f5942 ; undefined
 244:	52415500 	.inst	0x52415500 ; undefined
 248:	46555f54 	.inst	0x46555f54 ; undefined
 24c:	525f5243 	.inst	0x525f5243 ; undefined
 250:	56494446 	.inst	0x56494446 ; undefined
 254:	5649445f 	.inst	0x5649445f ; undefined
 258:	5f59425f 	.inst	0x5f59425f ; undefined
 25c:	41550033 	.inst	0x41550033 ; undefined
 260:	555f5452 	.inst	0x555f5452 ; undefined
 264:	5f524346 	.inst	0x5f524346 ; undefined
 268:	49444652 	.inst	0x49444652 ; undefined
 26c:	49445f56 	.inst	0x49445f56 ; undefined
 270:	59425f56 	.inst	0x59425f56 ; undefined
 274:	5500345f 	.inst	0x5500345f ; undefined
 278:	5f545241 	.inst	0x5f545241 ; undefined
 27c:	52434655 	.inst	0x52434655 ; undefined
 280:	4446525f 	smlslb	z31.h, z18.b, z6.b
 284:	445f5649 	smlslt	z9.h, z18.b, z31.b
 288:	425f5649 	.inst	0x425f5649 ; undefined
 28c:	00355f59 	.inst	0x00355f59 ; NYI
 290:	54524155 	bc.pl	a4ab8 <_start-0x3ff5b548>  // bc.nfrst
 294:	4346555f 	.inst	0x4346555f ; undefined
 298:	46525f52 	.inst	0x46525f52 ; undefined
 29c:	5f564944 	.inst	0x5f564944 ; undefined
 2a0:	5f564944 	.inst	0x5f564944 ; undefined
 2a4:	365f5942 	tbz	w2, #11, ffffffffffffedcc <__stack_el2_top+0xffffffffbf0fddcc>
 2a8:	52415500 	.inst	0x52415500 ; undefined
 2ac:	46555f54 	.inst	0x46555f54 ; undefined
 2b0:	525f5243 	.inst	0x525f5243 ; undefined
 2b4:	56494446 	.inst	0x56494446 ; undefined
 2b8:	5649445f 	.inst	0x5649445f ; undefined
 2bc:	5f59425f 	.inst	0x5f59425f ; undefined
 2c0:	69750037 	ldpsw	x23, x0, [x1, #-88]
 2c4:	3631746e 	tbz	w14, #6, 3150 <_start-0x3fffceb0>
 2c8:	72615500 	.inst	0x72615500 ; undefined
 2cc:	72635574 	.inst	0x72635574 ; undefined
 2d0:	6c615632 	ldnp	d18, d21, [x17, #-496]
 2d4:	70006575 	adr	x21, f83 <_start-0x3ffff07d>
 2d8:	70697265 	adr	x5, d3127 <_start-0x3ff2ced9>
 2dc:	61625f68 	.inst	0x61625f68 ; undefined
 2e0:	55006573 	.inst	0x55006573 ; undefined
 2e4:	55747261 	.inst	0x55747261 ; undefined
 2e8:	5672636d 	.inst	0x5672636d ; undefined
 2ec:	65756c61 	fnmls	z1.h, p3/m, z3.h, z21.h
 2f0:	52415500 	.inst	0x52415500 ; undefined
 2f4:	43555f54 	.inst	0x43555f54 ; undefined
 2f8:	425f3352 	.inst	0x425f3352 ; undefined
 2fc:	65735f46 	fnmla	z6.h, p7/m, z26.h, z19.h
 300:	58525f74 	ldr	x20, a4eec <_start-0x3ff5b114>
 304:	58554d44 	ldr	x4, aacac <_start-0x3ff55354>
 308:	004c4553 	.inst	0x004c4553 ; undefined
 30c:	54524155 	bc.pl	a4b34 <_start-0x3ff5b4cc>  // bc.nfrst
 310:	5243555f 	.inst	0x5243555f ; undefined
 314:	72775f33 	.inst	0x72775f33 ; undefined
 318:	00657469 	.inst	0x00657469 ; undefined
 31c:	54524155 	bc.pl	a4b44 <_start-0x3ff5b4bc>  // bc.nfrst
 320:	4346555f 	.inst	0x4346555f ; undefined
 324:	72775f52 	.inst	0x72775f52 ; undefined
 328:	00657469 	.inst	0x00657469 ; undefined
 32c:	54524155 	bc.pl	a4b54 <_start-0x3ff5b4ac>  // bc.nfrst
 330:	434d555f 	.inst	0x434d555f ; undefined
 334:	72775f52 	.inst	0x72775f52 ; undefined
 338:	00657469 	.inst	0x00657469 ; undefined
 33c:	54524155 	bc.pl	a4b64 <_start-0x3ff5b49c>  // bc.nfrst
 340:	5354555f 	.inst	0x5354555f ; undefined
 344:	5f46425f 	.inst	0x5f46425f ; undefined
 348:	5f746567 	.inst	0x5f746567 ; undefined
 34c:	55465854 	.inst	0x55465854 ; undefined
 350:	55004c4c 	.inst	0x55004c4c ; undefined
 354:	5f545241 	.inst	0x5f545241 ; undefined
 358:	32524355 	.inst	0x32524355 ; undefined
 35c:	5f46425f 	.inst	0x5f46425f ; undefined
 360:	5f746573 	.inst	0x5f746573 ; undefined
 364:	54535253 	bc.cc	a6dac <_start-0x3ff59254>  // bc.lo, bc.ul, bc.last
 368:	52415500 	.inst	0x52415500 ; undefined
 36c:	43555f54 	.inst	0x43555f54 ; undefined
 370:	425f3252 	.inst	0x425f3252 ; undefined
 374:	65735f46 	fnmla	z6.h, p7/m, z26.h, z19.h
 378:	58525f74 	ldr	x20, a4f64 <_start-0x3ff5b09c>
 37c:	75004e45 	.inst	0x75004e45 ; undefined
 380:	70746e69 	adr	x9, e914f <_start-0x3ff16eb1>
 384:	55007274 	.inst	0x55007274 ; undefined
 388:	5f545241 	.inst	0x5f545241 ; undefined
 38c:	524d4255 	.inst	0x524d4255 ; undefined
 390:	6972775f 	ldpsw	xzr, x29, [x26, #-112]
 394:	55006574 	.inst	0x55006574 ; undefined
 398:	5f545241 	.inst	0x5f545241 ; undefined
 39c:	34524355 	cbz	w21, a4c04 <_start-0x3ff5b3fc>
 3a0:	5f46425f 	.inst	0x5f46425f ; undefined
 3a4:	5f746573 	.inst	0x5f746573 ; undefined
 3a8:	54535443 	b.cc	a6e30 <_start-0x3ff591d0>  // b.lo, b.ul, b.last
 3ac:	6975004c 	ldpsw	x12, x0, [x2, #-88]
 3b0:	3436746e 	cbz	w14, 6d23c <_start-0x3ff92dc4>
 3b4:	52415500 	.inst	0x52415500 ; undefined
 3b8:	54555f54 	bc.mi	aafa0 <_start-0x3ff55060>  // bc.first
 3bc:	46425f53 	.inst	0x46425f53 ; undefined
 3c0:	7465675f 	.inst	0x7465675f ; undefined
 3c4:	464f535f 	.inst	0x464f535f ; undefined
 3c8:	54535254 	bc.mi	a6e10 <_start-0x3ff591f0>  // bc.first
 3cc:	52415500 	.inst	0x52415500 ; undefined
 3d0:	46555f54 	.inst	0x46555f54 ; undefined
 3d4:	525f5243 	.inst	0x525f5243 ; undefined
 3d8:	56494446 	.inst	0x56494446 ; undefined
 3dc:	52415500 	.inst	0x52415500 ; undefined
 3e0:	54555f54 	bc.mi	aafc8 <_start-0x3ff55038>  // bc.first
 3e4:	65725f53 	fnmla	z19.h, p7/m, z26.h, z18.h
 3e8:	55006461 	.inst	0x55006461 ; undefined
 3ec:	5f545241 	.inst	0x5f545241 ; undefined
 3f0:	52494255 	.inst	0x52494255 ; undefined
 3f4:	6972775f 	ldpsw	xzr, x29, [x26, #-112]
 3f8:	75006574 	.inst	0x75006574 ; undefined
 3fc:	00647874 	.inst	0x00647874 ; undefined
 400:	54524155 	bc.pl	a4c28 <_start-0x3ff5b3d8>  // bc.nfrst
 404:	5243555f 	.inst	0x5243555f ; undefined
 408:	46425f32 	.inst	0x46425f32 ; undefined
 40c:	7465735f 	.inst	0x7465735f ; undefined
 410:	4552505f 	ssubwb	z31.h, z2.h, z18.b
 414:	6155004e 	.inst	0x6155004e ; undefined
 418:	74557472 	.inst	0x74557472 ; undefined
 41c:	6c615673 	ldnp	d19, d21, [x19, #-496]
 420:	75006575 	.inst	0x75006575 ; undefined
 424:	00726366 	.inst	0x00726366 ; undefined
 428:	54524155 	bc.pl	a4c50 <_start-0x3ff5b3b0>  // bc.nfrst
 42c:	5243555f 	.inst	0x5243555f ; undefined
 430:	46425f33 	.inst	0x46425f33 ; undefined
 434:	7465735f 	.inst	0x7465735f ; undefined
 438:	4443445f 	smlalt	z31.h, z2.b, z3.b
 43c:	72615500 	.inst	0x72615500 ; undefined
 440:	69625574 	ldpsw	x20, x21, [x11, #-240]
 444:	6c615672 	ldnp	d18, d21, [x19, #-496]
 448:	72006575 	ands	w21, w11, #0x3ffffff
 44c:	32336765 	orr	w5, w27, #0xffffe07f
 450:	52415500 	.inst	0x52415500 ; undefined
 454:	42555f54 	.inst	0x42555f54 ; undefined
 458:	425f524d 	.inst	0x425f524d ; undefined
 45c:	65735f46 	fnmla	z6.h, p7/m, z26.h, z19.h
 460:	4f4d5f74 	.inst	0x4f4d5f74 ; undefined
 464:	41550044 	.inst	0x41550044 ; undefined
 468:	555f5452 	.inst	0x555f5452 ; undefined
 46c:	5f325243 	fmls	h3, h18, v2.h[3]
 470:	735f4642 	.inst	0x735f4642 ; undefined
 474:	435f7465 	.inst	0x435f7465 ; undefined
 478:	00435354 	.inst	0x00435354 ; undefined
 47c:	72696275 	.inst	0x72696275 ; undefined
 480:	52415500 	.inst	0x52415500 ; undefined
 484:	54555f54 	bc.mi	ab06c <_start-0x3ff54f94>  // bc.first
 488:	775f4458 	.inst	0x775f4458 ; undefined
 48c:	65746972 	fnmls	z18.h, p2/m, z11.h, z20.h
 490:	72637500 	.inst	0x72637500 ; undefined
 494:	63750031 	.inst	0x63750031 ; undefined
 498:	75003272 	.inst	0x75003272 ; undefined
 49c:	00337263 	.inst	0x00337263 ; NYI
 4a0:	34726375 	cbz	w21, e510c <_start-0x3ff1aef4>
 4a4:	6f425f00 	.inst	0x6f425f00 ; undefined
 4a8:	55006c6f 	.inst	0x55006c6f ; undefined
 4ac:	5f545241 	.inst	0x5f545241 ; undefined
 4b0:	41425f4e 	.inst	0x41425f4e ; undefined
 4b4:	55004553 	.inst	0x55004553 ; undefined
 4b8:	55747261 	.inst	0x55747261 ; undefined
 4bc:	56726366 	.inst	0x56726366 ; undefined
 4c0:	65756c61 	fnmls	z1.h, p3/m, z3.h, z21.h
 4c4:	6d627500 	ldp	d0, d29, [x8, #-480]
 4c8:	41550072 	.inst	0x41550072 ; undefined
 4cc:	555f5452 	.inst	0x555f5452 ; undefined
 4d0:	5f524942 	.inst	0x5f524942 ; undefined
 4d4:	735f4642 	.inst	0x735f4642 ; undefined
 4d8:	495f7465 	.inst	0x495f7465 ; undefined
 4dc:	5500434e 	.inst	0x5500434e ; undefined
 4e0:	55747261 	.inst	0x55747261 ; undefined
 4e4:	56347263 	.inst	0x56347263 ; undefined
 4e8:	65756c61 	fnmls	z1.h, p3/m, z3.h, z21.h
 4ec:	52415500 	.inst	0x52415500 ; undefined
 4f0:	43555f54 	.inst	0x43555f54 ; undefined
 4f4:	425f3352 	.inst	0x425f3352 ; undefined
 4f8:	65735f46 	fnmla	z6.h, p7/m, z26.h, z19.h
 4fc:	49525f74 	.inst	0x49525f74 ; undefined
 500:	72615500 	.inst	0x72615500 ; undefined
 504:	6d625574 	ldp	d20, d21, [x11, #-480]
 508:	6c615672 	ldnp	d18, d21, [x19, #-496]
 50c:	55006575 	.inst	0x55006575 ; undefined
 510:	5f545241 	.inst	0x5f545241 ; undefined
 514:	31524355 	adds	w21, w26, #0x490, lsl #12
 518:	5f46425f 	.inst	0x5f46425f ; undefined
 51c:	5f746573 	.inst	0x5f746573 ; undefined
 520:	54524155 	bc.pl	a4d48 <_start-0x3ff5b2b8>  // bc.nfrst
 524:	75004e45 	.inst	0x75004e45 ; undefined
 528:	0072636d 	.inst	0x0072636d ; undefined
 52c:	54524155 	bc.pl	a4d54 <_start-0x3ff5b2ac>  // bc.nfrst
 530:	4346555f 	.inst	0x4346555f ; undefined
 534:	46425f52 	.inst	0x46425f52 ; undefined
 538:	7465735f 	.inst	0x7465735f ; undefined
 53c:	5458525f 	bc.nv	b0f84 <_start-0x3ff4f07c>
 540:	4155004c 	.inst	0x4155004c ; undefined
 544:	555f5452 	.inst	0x555f5452 ; undefined
 548:	5f524346 	.inst	0x5f524346 ; undefined
 54c:	735f4642 	.inst	0x735f4642 ; undefined
 550:	545f7465 	b.pl	bf3dc <_start-0x3ff40c24>  // b.nfrst
 554:	004c5458 	.inst	0x004c5458 ; undefined
 558:	54524155 	bc.pl	a4d80 <_start-0x3ff5b280>  // bc.nfrst
 55c:	5243555f 	.inst	0x5243555f ; undefined
 560:	72775f34 	.inst	0x72775f34 ; undefined
 564:	00657469 	.inst	0x00657469 ; undefined
 568:	54524155 	bc.pl	a4d90 <_start-0x3ff5b270>  // bc.nfrst
 56c:	5243555f 	.inst	0x5243555f ; undefined
 570:	46425f32 	.inst	0x46425f32 ; undefined
 574:	7465735f 	.inst	0x7465735f ; undefined
 578:	4558545f 	ssubwt	z31.h, z2.h, z24.b
 57c:	6155004e 	.inst	0x6155004e ; undefined
 580:	63557472 	.inst	0x63557472 ; undefined
 584:	61563172 	.inst	0x61563172 ; undefined
 588:	0065756c 	.inst	0x0065756c ; undefined
 58c:	54524155 	bc.pl	a4db4 <_start-0x3ff5b24c>  // bc.nfrst
 590:	5243555f 	.inst	0x5243555f ; undefined
 594:	46425f33 	.inst	0x46425f33 ; undefined
 598:	7465735f 	.inst	0x7465735f ; undefined
 59c:	5253445f 	.inst	0x5253445f ; undefined
 5a0:	52415500 	.inst	0x52415500 ; undefined
 5a4:	46555f54 	.inst	0x46555f54 ; undefined
 5a8:	425f5243 	.inst	0x425f5243 ; undefined
 5ac:	65735f46 	fnmla	z6.h, p7/m, z26.h, z19.h
 5b0:	46525f74 	.inst	0x46525f74 ; undefined
 5b4:	00564944 	.inst	0x00564944 ; undefined
 5b8:	74726155 	.inst	0x74726155 ; undefined
 5bc:	64787455 	.inst	0x64787455 ; undefined
 5c0:	756c6156 	.inst	0x756c6156 ; undefined
 5c4:	Address 0x5c4 is out of bounds.


Disassembly of section .comment:

0000000000000000 <.comment>:
   0:	3a434347 	ccmn	w26, w3, #0x7, mi	// mi = first
   4:	72412820 	.inst	0x72412820 ; undefined
   8:	4e47206d 	luti4	v13.16b, {v3.16b}, v7[0]
   c:	6f542055 	umlal2	v21.4s, v2.8h, v4.h[1]
  10:	68636c6f 	.inst	0x68636c6f ; undefined
  14:	206e6961 	.inst	0x206e6961 ; undefined
  18:	322e3431 	orr	w17, w1, #0xfffc0000
  1c:	6c65522e 	ldnp	d14, d20, [x17, #-432]
  20:	42282031 	.inst	0x42282031 ; undefined
  24:	646c6975 	.inst	0x646c6975 ; undefined
  28:	6d726120 	ldp	d0, d24, [x9, #-224]
  2c:	2e34312d 	usubw	v13.8h, v9.8h, v20.8b
  30:	29293235 	stp	w21, w12, [x17, #-184]
  34:	2e343120 	usubw	v0.8h, v9.8h, v20.8b
  38:	20312e32 	.inst	0x20312e32 ; undefined
  3c:	34323032 	cbz	w18, 64640 <_start-0x3ff9b9c0>
  40:	39313131 	strb	w17, [x9, #3148]
	...

Disassembly of section .debug_frame:

0000000000000000 <.debug_frame>:
   0:	0000000c 	udf	#12
   4:	ffffffff 	.inst	0xffffffff ; undefined
   8:	78040001 	sturh	w1, [x0, #64]
   c:	001f0c1e 	.inst	0x001f0c1e ; undefined
  10:	0000001c 	udf	#28
  14:	00000000 	udf	#0
  18:	4000006c 	.inst	0x4000006c ; undefined
  1c:	00000000 	udf	#0
  20:	00000044 	udf	#68
  24:	00000000 	udf	#0
  28:	9d200e41 	.inst	0x9d200e41 ; undefined
  2c:	00039e04 	.inst	0x00039e04 ; undefined
  30:	0000000c 	udf	#12
  34:	ffffffff 	.inst	0xffffffff ; undefined
  38:	78040001 	sturh	w1, [x0, #64]
  3c:	001f0c1e 	.inst	0x001f0c1e ; undefined
  40:	0000001c 	udf	#28
  44:	00000030 	udf	#48
  48:	400000b0 	.inst	0x400000b0 ; undefined
  4c:	00000000 	udf	#0
  50:	00000024 	udf	#36
  54:	00000000 	udf	#0
  58:	47100e41 	.inst	0x47100e41 ; undefined
  5c:	0000000e 	udf	#14
  60:	0000001c 	udf	#28
  64:	00000030 	udf	#48
  68:	400000d4 	.inst	0x400000d4 ; undefined
  6c:	00000000 	udf	#0
  70:	00000030 	udf	#48
  74:	00000000 	udf	#0
  78:	4a100e41 	eor	w1, w18, w16, lsl #3
  7c:	0000000e 	udf	#14
  80:	0000001c 	udf	#28
  84:	00000030 	udf	#48
  88:	40000104 	.inst	0x40000104 ; undefined
  8c:	00000000 	udf	#0
  90:	00000024 	udf	#36
  94:	00000000 	udf	#0
  98:	47100e41 	.inst	0x47100e41 ; undefined
  9c:	0000000e 	udf	#14
  a0:	0000001c 	udf	#28
  a4:	00000030 	udf	#48
  a8:	40000128 	.inst	0x40000128 ; undefined
  ac:	00000000 	udf	#0
  b0:	00000030 	udf	#48
  b4:	00000000 	udf	#0
  b8:	4a100e41 	eor	w1, w18, w16, lsl #3
  bc:	0000000e 	udf	#14
  c0:	0000001c 	udf	#28
  c4:	00000030 	udf	#48
  c8:	40000158 	.inst	0x40000158 ; undefined
  cc:	00000000 	udf	#0
  d0:	00000024 	udf	#36
  d4:	00000000 	udf	#0
  d8:	47100e41 	.inst	0x47100e41 ; undefined
  dc:	0000000e 	udf	#14
  e0:	0000001c 	udf	#28
  e4:	00000030 	udf	#48
  e8:	4000017c 	.inst	0x4000017c ; undefined
  ec:	00000000 	udf	#0
  f0:	00000030 	udf	#48
  f4:	00000000 	udf	#0
  f8:	4a100e41 	eor	w1, w18, w16, lsl #3
  fc:	0000000e 	udf	#14
 100:	0000001c 	udf	#28
 104:	00000030 	udf	#48
 108:	400001ac 	.inst	0x400001ac ; undefined
 10c:	00000000 	udf	#0
 110:	0000001c 	udf	#28
 114:	00000000 	udf	#0
 118:	45100e41 	.inst	0x45100e41 ; undefined
 11c:	0000000e 	udf	#14
 120:	0000001c 	udf	#28
 124:	00000030 	udf	#48
 128:	400001c8 	.inst	0x400001c8 ; undefined
 12c:	00000000 	udf	#0
 130:	00000024 	udf	#36
 134:	00000000 	udf	#0
 138:	47100e41 	.inst	0x47100e41 ; undefined
 13c:	0000000e 	udf	#14
 140:	0000001c 	udf	#28
 144:	00000030 	udf	#48
 148:	400001ec 	.inst	0x400001ec ; undefined
 14c:	00000000 	udf	#0
 150:	00000038 	udf	#56
 154:	00000000 	udf	#0
 158:	4c100e41 	.inst	0x4c100e41 ; undefined
 15c:	0000000e 	udf	#14
 160:	0000001c 	udf	#28
 164:	00000030 	udf	#48
 168:	40000224 	.inst	0x40000224 ; undefined
 16c:	00000000 	udf	#0
 170:	00000038 	udf	#56
 174:	00000000 	udf	#0
 178:	4c100e41 	.inst	0x4c100e41 ; undefined
 17c:	0000000e 	udf	#14
 180:	0000001c 	udf	#28
 184:	00000030 	udf	#48
 188:	4000025c 	.inst	0x4000025c ; undefined
 18c:	00000000 	udf	#0
 190:	00000038 	udf	#56
 194:	00000000 	udf	#0
 198:	4c100e41 	.inst	0x4c100e41 ; undefined
 19c:	0000000e 	udf	#14
 1a0:	0000001c 	udf	#28
 1a4:	00000030 	udf	#48
 1a8:	40000294 	.inst	0x40000294 ; undefined
 1ac:	00000000 	udf	#0
 1b0:	00000038 	udf	#56
 1b4:	00000000 	udf	#0
 1b8:	4c100e41 	.inst	0x4c100e41 ; undefined
 1bc:	0000000e 	udf	#14
 1c0:	0000001c 	udf	#28
 1c4:	00000030 	udf	#48
 1c8:	400002cc 	.inst	0x400002cc ; undefined
 1cc:	00000000 	udf	#0
 1d0:	00000038 	udf	#56
 1d4:	00000000 	udf	#0
 1d8:	4c100e41 	.inst	0x4c100e41 ; undefined
 1dc:	0000000e 	udf	#14
 1e0:	0000001c 	udf	#28
 1e4:	00000030 	udf	#48
 1e8:	40000304 	.inst	0x40000304 ; undefined
 1ec:	00000000 	udf	#0
 1f0:	00000030 	udf	#48
 1f4:	00000000 	udf	#0
 1f8:	4a100e41 	eor	w1, w18, w16, lsl #3
 1fc:	0000000e 	udf	#14
 200:	0000001c 	udf	#28
 204:	00000030 	udf	#48
 208:	40000334 	.inst	0x40000334 ; undefined
 20c:	00000000 	udf	#0
 210:	00000024 	udf	#36
 214:	00000000 	udf	#0
 218:	47100e41 	.inst	0x47100e41 ; undefined
 21c:	0000000e 	udf	#14
 220:	0000001c 	udf	#28
 224:	00000030 	udf	#48
 228:	40000358 	.inst	0x40000358 ; undefined
 22c:	00000000 	udf	#0
 230:	00000038 	udf	#56
 234:	00000000 	udf	#0
 238:	4c100e41 	.inst	0x4c100e41 ; undefined
 23c:	0000000e 	udf	#14
 240:	0000001c 	udf	#28
 244:	00000030 	udf	#48
 248:	40000390 	.inst	0x40000390 ; undefined
 24c:	00000000 	udf	#0
 250:	00000038 	udf	#56
 254:	00000000 	udf	#0
 258:	4c100e41 	.inst	0x4c100e41 ; undefined
 25c:	0000000e 	udf	#14
 260:	0000001c 	udf	#28
 264:	00000030 	udf	#48
 268:	400003c8 	.inst	0x400003c8 ; undefined
 26c:	00000000 	udf	#0
 270:	00000038 	udf	#56
 274:	00000000 	udf	#0
 278:	4c100e41 	.inst	0x4c100e41 ; undefined
 27c:	0000000e 	udf	#14
 280:	0000001c 	udf	#28
 284:	00000030 	udf	#48
 288:	40000400 	.inst	0x40000400 ; undefined
 28c:	00000000 	udf	#0
 290:	00000038 	udf	#56
 294:	00000000 	udf	#0
 298:	4c100e41 	.inst	0x4c100e41 ; undefined
 29c:	0000000e 	udf	#14
 2a0:	0000001c 	udf	#28
 2a4:	00000030 	udf	#48
 2a8:	40000438 	.inst	0x40000438 ; undefined
 2ac:	00000000 	udf	#0
 2b0:	00000024 	udf	#36
 2b4:	00000000 	udf	#0
 2b8:	47100e41 	.inst	0x47100e41 ; undefined
 2bc:	0000000e 	udf	#14
 2c0:	0000001c 	udf	#28
 2c4:	00000030 	udf	#48
 2c8:	4000045c 	.inst	0x4000045c ; undefined
 2cc:	00000000 	udf	#0
 2d0:	00000038 	udf	#56
 2d4:	00000000 	udf	#0
 2d8:	4c100e41 	.inst	0x4c100e41 ; undefined
 2dc:	0000000e 	udf	#14
 2e0:	0000001c 	udf	#28
 2e4:	00000030 	udf	#48
 2e8:	40000494 	.inst	0x40000494 ; undefined
 2ec:	00000000 	udf	#0
 2f0:	00000024 	udf	#36
 2f4:	00000000 	udf	#0
 2f8:	47100e41 	.inst	0x47100e41 ; undefined
 2fc:	0000000e 	udf	#14
 300:	0000001c 	udf	#28
 304:	00000030 	udf	#48
 308:	400004b8 	.inst	0x400004b8 ; undefined
 30c:	00000000 	udf	#0
 310:	00000038 	udf	#56
 314:	00000000 	udf	#0
 318:	4c100e41 	.inst	0x4c100e41 ; undefined
 31c:	0000000e 	udf	#14
 320:	0000001c 	udf	#28
 324:	00000030 	udf	#48
 328:	400004f0 	.inst	0x400004f0 ; undefined
 32c:	00000000 	udf	#0
 330:	00000038 	udf	#56
 334:	00000000 	udf	#0
 338:	4c100e41 	.inst	0x4c100e41 ; undefined
 33c:	0000000e 	udf	#14
 340:	0000001c 	udf	#28
 344:	00000030 	udf	#48
 348:	40000528 	.inst	0x40000528 ; undefined
 34c:	00000000 	udf	#0
 350:	00000034 	udf	#52
 354:	00000000 	udf	#0
 358:	4b100e41 	sub	w1, w18, w16, lsl #3
 35c:	0000000e 	udf	#14
 360:	0000001c 	udf	#28
 364:	00000030 	udf	#48
 368:	4000055c 	.inst	0x4000055c ; undefined
 36c:	00000000 	udf	#0
 370:	00000024 	udf	#36
 374:	00000000 	udf	#0
 378:	47100e41 	.inst	0x47100e41 ; undefined
 37c:	0000000e 	udf	#14
 380:	0000001c 	udf	#28
 384:	00000030 	udf	#48
 388:	40000580 	.inst	0x40000580 ; undefined
 38c:	00000000 	udf	#0
 390:	0000001c 	udf	#28
 394:	00000000 	udf	#0
 398:	45100e41 	.inst	0x45100e41 ; undefined
 39c:	0000000e 	udf	#14
 3a0:	0000001c 	udf	#28
 3a4:	00000030 	udf	#48
 3a8:	4000059c 	.inst	0x4000059c ; undefined
 3ac:	00000000 	udf	#0
 3b0:	00000024 	udf	#36
 3b4:	00000000 	udf	#0
 3b8:	47100e41 	.inst	0x47100e41 ; undefined
 3bc:	0000000e 	udf	#14
 3c0:	0000001c 	udf	#28
 3c4:	00000030 	udf	#48
 3c8:	400005c0 	.inst	0x400005c0 ; undefined
 3cc:	00000000 	udf	#0
 3d0:	00000024 	udf	#36
 3d4:	00000000 	udf	#0
 3d8:	47100e41 	.inst	0x47100e41 ; undefined
 3dc:	0000000e 	udf	#14
 3e0:	0000001c 	udf	#28
 3e4:	00000030 	udf	#48
 3e8:	400005e4 	.inst	0x400005e4 ; undefined
 3ec:	00000000 	udf	#0
 3f0:	00000024 	udf	#36
 3f4:	00000000 	udf	#0
 3f8:	47100e41 	.inst	0x47100e41 ; undefined
 3fc:	0000000e 	udf	#14
 400:	00000024 	udf	#36
 404:	00000030 	udf	#48
 408:	40000608 	.inst	0x40000608 ; undefined
 40c:	00000000 	udf	#0
 410:	0000002c 	udf	#44
 414:	00000000 	udf	#0
 418:	9d300e41 	.inst	0x9d300e41 ; undefined
 41c:	49059e06 	.inst	0x49059e06 ; undefined
 420:	000eddde 	.inst	0x000eddde ; undefined
 424:	00000000 	udf	#0
 428:	00000024 	udf	#36
 42c:	00000030 	udf	#48
 430:	40000634 	.inst	0x40000634 ; undefined
 434:	00000000 	udf	#0
 438:	00000068 	udf	#104
 43c:	00000000 	udf	#0
 440:	9d300e41 	.inst	0x9d300e41 ; undefined
 444:	58059e06 	ldr	x6, b804 <_start-0x3fff47fc>
 448:	000eddde 	.inst	0x000eddde ; undefined
 44c:	00000000 	udf	#0
 450:	00000024 	udf	#36
 454:	00000030 	udf	#48
 458:	4000069c 	.inst	0x4000069c ; undefined
 45c:	00000000 	udf	#0
 460:	00000050 	udf	#80
 464:	00000000 	udf	#0
 468:	9d200e41 	.inst	0x9d200e41 ; undefined
 46c:	52039e04 	eor	w4, w16, #0xe01fe01f
 470:	000eddde 	.inst	0x000eddde ; undefined
 474:	00000000 	udf	#0
 478:	00000024 	udf	#36
 47c:	00000030 	udf	#48
 480:	400006ec 	.inst	0x400006ec ; undefined
 484:	00000000 	udf	#0
 488:	00000098 	udf	#152
 48c:	00000000 	udf	#0
 490:	9d400e41 	.inst	0x9d400e41 ; undefined
 494:	64079e08 	.inst	0x64079e08 ; undefined
 498:	000eddde 	.inst	0x000eddde ; undefined
 49c:	00000000 	udf	#0
 4a0:	00000024 	udf	#36
 4a4:	00000030 	udf	#48
 4a8:	40000784 	.inst	0x40000784 ; undefined
 4ac:	00000000 	udf	#0
 4b0:	00000178 	udf	#376
 4b4:	00000000 	udf	#0
 4b8:	9d700e41 	.inst	0x9d700e41 ; undefined
 4bc:	020d9e0e 	.inst	0x020d9e0e ; undefined
 4c0:	0eddde5c 	.inst	0x0eddde5c ; undefined
 4c4:	00000000 	udf	#0
