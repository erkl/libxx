; Copyright (c) 2018, Erik Lundin.

    section .text align=64

    global  xx__hchacha_sse2


; An optimized implementation of our core HChaCha function, targeting the SSE2
; instruction set extension.

xx__hchacha_sse2:
    movdqa      xmm0, [rel sigma]
    movdqu      xmm1, [rsi]
    movdqu      xmm2, [rsi + 16]
    movdqu      xmm3, [rdx]

.r:
    sub     rcx, 2
    jc      .b

    paddd       xmm0, xmm1
    pxor        xmm3, xmm0
    pshuflw     xmm3, xmm3, 0xb1
    pshufhw     xmm3, xmm3, 0xb1
    paddd       xmm2, xmm3
    pxor        xmm1, xmm2
    movdqa      xmm8, xmm1
    pslld       xmm8, 12
    psrld       xmm1, 20
    por         xmm1, xmm8
    paddd       xmm0, xmm1
    pxor        xmm3, xmm0
    movdqa      xmm8, xmm3
    pslld       xmm3, 8
    psrld       xmm8, 24
    por         xmm3, xmm8
    paddd       xmm2, xmm3
    pxor        xmm1, xmm2
    movdqa      xmm8, xmm1
    pslld       xmm8, 7
    psrld       xmm1, 25
    por         xmm1, xmm8
    pshufd      xmm0, xmm0, 0x93
    pshufd      xmm2, xmm2, 0x39
    pshufd      xmm3, xmm3, 0x4e

    paddd       xmm0, xmm1
    pxor        xmm3, xmm0
    pshuflw     xmm3, xmm3, 0xb1
    pshufhw     xmm3, xmm3, 0xb1
    paddd       xmm2, xmm3
    pxor        xmm1, xmm2
    movdqa      xmm8, xmm1
    pslld       xmm8, 12
    psrld       xmm1, 20
    por         xmm1, xmm8
    paddd       xmm0, xmm1
    pxor        xmm3, xmm0
    movdqa      xmm8, xmm3
    pslld       xmm3, 8
    psrld       xmm8, 24
    por         xmm3, xmm8
    paddd       xmm2, xmm3
    pxor        xmm1, xmm2
    movdqa      xmm8, xmm1
    pslld       xmm8, 7
    psrld       xmm1, 25
    por         xmm1, xmm8
    pshufd      xmm0, xmm0, 0x39
    pshufd      xmm2, xmm2, 0x93
    pshufd      xmm3, xmm3, 0x4e

    jmp     .r

.b:
    movdqu      [rdi], xmm0
    movdqu      [rdi + 16], xmm3

    ret


    section .rodata
    align   64

sigma:
    db  "expand 32-byte k"
