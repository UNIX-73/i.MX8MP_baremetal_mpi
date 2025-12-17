#include <arm/exceptions/exceptions.h>
#include <kernel/panic.h>
#include <lib/stdint.h>

extern uint64 _exceptions_get_DAIF();

extern void _fiq_exceptions_enable();
extern void _irq_exceptions_enable();
extern void _serror_exceptions_enable();
extern void _debug_exceptions_enable();

extern void _fiq_exceptions_disable();
extern void _irq_exceptions_disable();
extern void _serror_exceptions_disable();
extern void _debug_exceptions_disable();

// https://developer.arm.com/documentation/111107/2025-09/AArch64-Registers/DAIF--Interrupt-Mask-Bits
EXCEPTION_STATUS exceptions_get_status()
{
	uint64 daif = _exceptions_get_DAIF();

	return (EXCEPTION_STATUS){.fiq = !((daif >> 6) & 0b1),
							  .irq = !((daif >> 7) & 0b1),
							  .serror = !((daif >> 8) & 0b1),
							  .debug = !((daif >> 9) & 0b1)};
}

void exceptions_set_status(EXCEPTION_STATUS status)
{
	if (status.fiq)
		_fiq_exceptions_enable();
	else
		_fiq_exceptions_disable();

	if (status.irq)
		_irq_exceptions_enable();
	else
		_irq_exceptions_disable();

	if (status.serror)
		_serror_exceptions_enable();
	else
		_serror_exceptions_disable();

	if (status.debug)
		_debug_exceptions_enable();
	else
		_debug_exceptions_disable();

#ifdef TEST
	EXCEPTION_STATUS current = exceptions_get_status();

	if (current.fiq != status.fiq || current.irq != status.irq ||
		current.serror != status.serror || current.debug != status.debug)
		PANIC("exceptions_set_status error");
#endif
}

void exceptions_enable(bool fiq, bool irq, bool serror, bool debug)
{
	if (fiq) _fiq_exceptions_enable();

	if (irq) _irq_exceptions_enable();

	if (serror) _serror_exceptions_enable();

	if (debug) _debug_exceptions_enable();
}

void exceptions_disable(bool fiq, bool irq, bool serror, bool debug)
{
	if (fiq) _fiq_exceptions_disable();

	if (irq) _irq_exceptions_disable();

	if (serror) _serror_exceptions_disable();

	if (debug) _debug_exceptions_disable();
}