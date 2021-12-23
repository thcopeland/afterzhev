.nolist
.if defined(__atmega2560) || defined(__atmega2561)
    .include "m2560def.inc" ; TODO: verify 2561
.elseif defined(__atmega1280) || defined(__atmega1281)
    .include "m1280def.inc" ; TODO: verify
.else
    .error "Device not supported. Supported devices for After Zhev are ATmega1280/1281 and ATmega2560/2561."
    .exit
.endif
.list
