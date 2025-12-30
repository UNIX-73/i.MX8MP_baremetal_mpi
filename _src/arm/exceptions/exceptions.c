#include <arm/exceptions/exceptions.h>
#include <arm/sysregs/sysregs.h>
#include <boot/panic.h>
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
ARM_exception_status ARM_exceptions_get_status()
{
	uint64 daif = _exceptions_get_DAIF();

	return (ARM_exception_status){.fiq = !((daif >> 6) & 1UL),
								  .irq = !((daif >> 7) & 1UL),
								  .serror = !((daif >> 8) & 1UL),
								  .debug = !((daif >> 9) & 1UL)};
}

void ARM_exceptions_set_status(ARM_exception_status status)
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
	ARM_exception_status current = ARM_exceptions_get_status();

	if (current.fiq != status.fiq || current.irq != status.irq ||
		current.serror != status.serror || current.debug != status.debug)
		PANIC("exceptions_set_status error");
#endif
}

void ARM_exceptions_enable(bool fiq, bool irq, bool serror, bool debug)
{
	if (fiq) _fiq_exceptions_enable();

	if (irq) _irq_exceptions_enable();

	if (serror) _serror_exceptions_enable();

	if (debug) _debug_exceptions_enable();
}

void ARM_exceptions_disable(bool fiq, bool irq, bool serror, bool debug)
{
	if (fiq) _fiq_exceptions_disable();

	if (irq) _irq_exceptions_disable();

	if (serror) _serror_exceptions_disable();

	if (debug) _debug_exceptions_disable();
}

size_t ARM_get_exception_level() { return (size_t)_ARM_currentEL(); }
