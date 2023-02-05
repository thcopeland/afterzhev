.nolist
.if defined(__atmega2560) || defined(__atmega2561)
    .include "m2560def.inc"
    .equ PC_SIZE = 3
.else
    .error "Device not supported. Supported devices for AfterZhev are ATmega2560/2561."
    .exit
.endif

.if !defined(TARGET)
    .message "Target not specified, assuming MCU. Set TARGET to 0 (PC) or 1 (MCU)"
    .equ TARGETING_MCU = 1
.elseif TARGET == 0
    .message "Building for PC target"
    .equ TARGETING_MCU = 0
.else
    .message "Building for MCU target"
    .equ TARGETING_MCU = 1
.endif

.equ TARGETING_PC = !(!TARGETING_MCU)

.list
