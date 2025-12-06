#![no_std]
#![allow(non_snake_case)]
#![allow(non_camel_case_types)]
mod drivers;
mod kernel;

use core::panic::PanicInfo;

use crate::drivers::uart::{UART_ID, UART_put_str};

#[unsafe(no_mangle)]
pub extern "C" fn rust_add(a: u64, b: u64) -> u64 {
    if a == 0 {
        panic!();
    }

    a + b
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    UART_put_str(UART_ID::UART_ID_2, "Rust panic!");

    loop {}
}
