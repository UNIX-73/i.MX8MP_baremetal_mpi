use core::{
    cell::UnsafeCell,
    sync::atomic::{AtomicBool, Ordering},
};

#[repr(C)]
struct ArmExceptionStatus {
    fiq: u8,
    irq: u8,
    serror: u8,
    debug: u8,
}

unsafe extern "C" {

    fn ARM_exceptions_enable(fiq: u8, irq: u8, serror: u8, debug: u8);
    fn ARM_exceptions_disable(fiq: u8, irq: u8, serror: u8, debug: u8);
    fn ARM_exceptions_get_status() -> ArmExceptionStatus;

}

pub struct RsMutex<T> {
    data: UnsafeCell<T>,
    locked: AtomicBool,
}
unsafe impl<T> Sync for RsMutex<T> {}

impl<T> RsMutex<T> {
    pub const fn new(value: T) -> Self {
        Self {
            data: UnsafeCell::new(value),
            locked: AtomicBool::new(false),
        }
    }

    pub fn lock<R>(&self, f: impl FnOnce(&mut T) -> R) -> R {
        let status = unsafe { ARM_exceptions_get_status() };
        unsafe { ARM_exceptions_disable(1, 1, 1, 1) };

        while self
            .locked
            .compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed)
            .is_err()
        {
            core::hint::spin_loop();
        }

        let r = unsafe { f(&mut *self.data.get()) };

        self.locked.store(false, Ordering::Release);

        unsafe { ARM_exceptions_enable(status.fiq, status.irq, status.serror, status.debug) };

        r
    }
}
