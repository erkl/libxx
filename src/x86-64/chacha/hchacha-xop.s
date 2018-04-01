; Copyright (c) 2018, Erik Lundin.

    section .text align=64

    global  xx__hchacha_xop


; An optimized implementation of our core HChaCha function, targeting the XOP
; instruction set extension.

xx__hchacha_xop:
    vmovdqa     xmm0, [rel sigma]
    vmovdqu     xmm1, [rsi]
    vmovdqu     xmm2, [rsi + 16]
    vmovdqu     xmm3, [rdx]

.r:
    sub     rcx, 2
    jc      .b

    vpaddd      xmm0, xmm0, xmm1
    vpxor       xmm3, xmm3, xmm0
    vprotd      xmm3, xmm3, 16
    vpaddd      xmm2, xmm2, xmm3
    vpxor       xmm1, xmm1, xmm2
    vprotd      xmm1, xmm1, 12
    vpaddd      xmm0, xmm0, xmm1
    vpxor       xmm3, xmm3, xmm0
    vprotd      xmm3, xmm3, 8
    vpaddd      xmm2, xmm2, xmm3
    vpxor       xmm1, xmm1, xmm2
    vprotd      xmm1, xmm1, 7
    vpshufd     xmm0, xmm0, 0x93
    vpshufd     xmm2, xmm2, 0x39
    vpshufd     xmm3, xmm3, 0x4e

    vpaddd      xmm0, xmm0, xmm1
    vpxor       xmm3, xmm3, xmm0
    vprotd      xmm3, xmm3, 16
    vpaddd      xmm2, xmm2, xmm3
    vpxor       xmm1, xmm1, xmm2
    vprotd      xmm1, xmm1, 12
    vpaddd      xmm0, xmm0, xmm1
    vpxor       xmm3, xmm3, xmm0
    vprotd      xmm3, xmm3, 8
    vpaddd      xmm2, xmm2, xmm3
    vpxor       xmm1, xmm1, xmm2
    vprotd      xmm1, xmm1, 7
    vpshufd     xmm0, xmm0, 0x39
    vpshufd     xmm2, xmm2, 0x93
    vpshufd     xmm3, xmm3, 0x4e

    jmp     .r

.b:
    vmovdqu     [rdi], xmm0
    vmovdqu     [rdi + 16], xmm3

    ret


    section .rodata
    align   64

sigma:
    db  "expand 32-byte k"
