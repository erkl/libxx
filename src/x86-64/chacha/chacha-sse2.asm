; Copyright (c) 2018, Erik Lundin.

    section .text align=64

    global  xx__chacha_sse2


; An optimized implementation of our ChaCha core function, utilizing the SSE2
; instruction set extension.
;
; Since all our SIMD-based implementations follow the same general structure,
; I've eschewed code-level documentation in these files (no one likes repeating
; themselves). Instead, see this directory's README.

xx__chacha_sse2:
    push    rbx
    push    rbp
    mov     rbp, rsp
    and     rsp, ~63
    sub     rsp, 288

    lea     rax, [rsp + 32]
    test    rdx, rdx
    cmovz   rdx, rax

    lea     rbx, [rcx + 63]
    shr     rbx, 6
    and     rcx, 63

    test    rbx, rbx
    jz      .r
    cmp     rbx, 2
    jb      .s
    je      .m

.l:
    movdqu      xmm3, [r8]
    pshufd      xmm0, xmm3, 0x00
    pshufd      xmm1, xmm3, 0x55
    pshufd      xmm2, xmm3, 0xaa
    pshufd      xmm3, xmm3, 0xff
    movdqu      xmm7, [r8 + 16]
    pshufd      xmm4, xmm7, 0x00
    pshufd      xmm5, xmm7, 0x55
    pshufd      xmm6, xmm7, 0xaa
    pshufd      xmm7, xmm7, 0xff
    movdqu      xmm11, [r8 + 32]
    pshufd      xmm8, xmm11, 0x00
    pshufd      xmm9, xmm11, 0x55
    pshufd      xmm10, xmm11, 0xaa
    pshufd      xmm11, xmm11, 0xff
    movdqu      xmm15, [r8 + 48]
    pshufd      xmm12, xmm15, 0x00
    pshufd      xmm13, xmm15, 0x55
    pshufd      xmm14, xmm15, 0xaa
    pshufd      xmm15, xmm15, 0xff

    movdqa      [rsp + 32], xmm0
    movdqa      [rsp + 48], xmm1
    movdqa      [rsp + 64], xmm2
    movdqa      [rsp + 80], xmm3
    movdqa      [rsp + 96], xmm4
    movdqa      [rsp + 112], xmm5
    movdqa      [rsp + 128], xmm6
    movdqa      [rsp + 144], xmm7
    movdqa      [rsp + 160], xmm8
    movdqa      [rsp + 176], xmm9
    movdqa      [rsp + 192], xmm10
    movdqa      [rsp + 208], xmm11
    movdqa      [rsp + 256], xmm14
    movdqa      [rsp + 272], xmm15

    mov     r10, [r8 + 48]
    jmp     .li

.ll:
    movdqa      xmm0, [rsp + 32]
    movdqa      xmm1, [rsp + 48]
    movdqa      xmm2, [rsp + 64]
    movdqa      xmm3, [rsp + 80]
    movdqa      xmm4, [rsp + 96]
    movdqa      xmm5, [rsp + 112]
    movdqa      xmm6, [rsp + 128]
    movdqa      xmm7, [rsp + 144]
    movdqa      xmm8, [rsp + 160]
    movdqa      xmm9, [rsp + 176]
    movdqa      xmm10, [rsp + 192]
    movdqa      xmm11, [rsp + 208]
    movdqu      xmm13, [r8 + 48]
    pshufd      xmm12, xmm13, 0x00
    pshufd      xmm13, xmm13, 0x55
    movdqa      xmm14, [rsp + 256]
    movdqa      xmm15, [rsp + 272]

.li:
    mov     rax, 4
    cmp     rax, rbx
    cmova   rax, rbx

    mov     r11, r10
    add     r10, rax
    mov     [r8 + 48], r10

    cmp     r10d, eax
    jae     .la

    lea         rax, [rel k00n1]
    add         r11d, 4
    movdqa      [rsp], xmm12
    movdqu      xmm12, [rax + 4 * r11]
    paddd       xmm13, xmm12
    movdqa      xmm12, [rsp]

.la:
    paddd       xmm12, [rel k0123]
    movdqa      [rsp + 224], xmm12
    movdqa      [rsp + 240], xmm13

    mov     rax, r9

.lr:
    sub     rax, 2
    jc      .lb

    paddd       xmm0, xmm4
    paddd       xmm1, xmm5
    pxor        xmm12, xmm0
    pxor        xmm13, xmm1
    pshuflw     xmm12, xmm12, 0xb1
    pshufhw     xmm12, xmm12, 0xb1
    pshuflw     xmm13, xmm13, 0xb1
    pshufhw     xmm13, xmm13, 0xb1
    paddd       xmm2, xmm6
    paddd       xmm3, xmm7
    pxor        xmm14, xmm2
    pxor        xmm15, xmm3
    pshuflw     xmm14, xmm14, 0xb1
    pshufhw     xmm14, xmm14, 0xb1
    pshuflw     xmm15, xmm15, 0xb1
    pshufhw     xmm15, xmm15, 0xb1
    movdqa      [rsp], xmm2
    movdqa      [rsp + 16], xmm3
    paddd       xmm8, xmm12
    paddd       xmm9, xmm13
    pxor        xmm4, xmm8
    pxor        xmm5, xmm9
    movdqa      xmm2, xmm4
    movdqa      xmm3, xmm5
    pslld       xmm4, 12
    pslld       xmm5, 12
    psrld       xmm2, 20
    psrld       xmm3, 20
    pxor        xmm4, xmm2
    pxor        xmm5, xmm3
    paddd       xmm10, xmm14
    paddd       xmm11, xmm15
    pxor        xmm6, xmm10
    pxor        xmm7, xmm11
    movdqa      xmm2, xmm6
    movdqa      xmm3, xmm7
    pslld       xmm6, 12
    pslld       xmm7, 12
    psrld       xmm2, 20
    psrld       xmm3, 20
    pxor        xmm6, xmm2
    pxor        xmm7, xmm3
    paddd       xmm0, xmm4
    paddd       xmm1, xmm5
    pxor        xmm12, xmm0
    pxor        xmm13, xmm1
    movdqa      xmm2, xmm12
    movdqa      xmm3, xmm13
    pslld       xmm12, 8
    pslld       xmm13, 8
    psrld       xmm2, 24
    psrld       xmm3, 24
    pxor        xmm12, xmm2
    pxor        xmm13, xmm3
    movdqa      xmm2, [rsp]
    movdqa      xmm3, [rsp + 16]
    paddd       xmm2, xmm6
    paddd       xmm3, xmm7
    pxor        xmm14, xmm2
    pxor        xmm15, xmm3
    movdqa      [rsp], xmm1
    movdqa      [rsp + 16], xmm2
    movdqa      xmm1, xmm14
    movdqa      xmm2, xmm15
    pslld       xmm14, 8
    pslld       xmm15, 8
    psrld       xmm1, 24
    psrld       xmm2, 24
    pxor        xmm14, xmm1
    pxor        xmm15, xmm2
    paddd       xmm8, xmm12
    paddd       xmm9, xmm13
    pxor        xmm4, xmm8
    pxor        xmm5, xmm9
    movdqa      xmm1, xmm4
    movdqa      xmm2, xmm5
    pslld       xmm4, 7
    pslld       xmm5, 7
    psrld       xmm1, 25
    psrld       xmm2, 25
    pxor        xmm4, xmm1
    pxor        xmm5, xmm2
    paddd       xmm10, xmm14
    paddd       xmm11, xmm15
    pxor        xmm6, xmm10
    pxor        xmm7, xmm11
    movdqa      xmm1, xmm6
    movdqa      xmm2, xmm7
    pslld       xmm6, 7
    pslld       xmm7, 7
    psrld       xmm1, 25
    psrld       xmm2, 25
    pxor        xmm6, xmm1
    pxor        xmm7, xmm2
    movdqa      xmm1, [rsp]
    movdqa      xmm2, [rsp + 16]

    paddd       xmm0, xmm5
    paddd       xmm3, xmm4
    pxor        xmm15, xmm0
    pxor        xmm14, xmm3
    pshuflw     xmm15, xmm15, 0xb1
    pshufhw     xmm15, xmm15, 0xb1
    pshuflw     xmm14, xmm14, 0xb1
    pshufhw     xmm14, xmm14, 0xb1
    paddd       xmm1, xmm6
    paddd       xmm2, xmm7
    pxor        xmm12, xmm1
    pxor        xmm13, xmm2
    pshuflw     xmm12, xmm12, 0xb1
    pshufhw     xmm12, xmm12, 0xb1
    pshuflw     xmm13, xmm13, 0xb1
    pshufhw     xmm13, xmm13, 0xb1
    movdqa      [rsp], xmm1
    movdqa      [rsp + 16], xmm2
    paddd       xmm10, xmm15
    paddd       xmm9, xmm14
    pxor        xmm5, xmm10
    pxor        xmm4, xmm9
    movdqa      xmm1, xmm5
    movdqa      xmm2, xmm4
    pslld       xmm5, 12
    pslld       xmm4, 12
    psrld       xmm1, 20
    psrld       xmm2, 20
    pxor        xmm5, xmm1
    pxor        xmm4, xmm2
    paddd       xmm11, xmm12
    paddd       xmm8, xmm13
    pxor        xmm6, xmm11
    pxor        xmm7, xmm8
    movdqa      xmm1, xmm6
    movdqa      xmm2, xmm7
    pslld       xmm6, 12
    pslld       xmm7, 12
    psrld       xmm1, 20
    psrld       xmm2, 20
    pxor        xmm6, xmm1
    pxor        xmm7, xmm2
    paddd       xmm0, xmm5
    paddd       xmm3, xmm4
    pxor        xmm15, xmm0
    pxor        xmm14, xmm3
    movdqa      xmm1, xmm15
    movdqa      xmm2, xmm14
    pslld       xmm15, 8
    pslld       xmm14, 8
    psrld       xmm1, 24
    psrld       xmm2, 24
    pxor        xmm15, xmm1
    pxor        xmm14, xmm2
    movdqa      xmm1, [rsp]
    movdqa      xmm2, [rsp + 16]
    paddd       xmm1, xmm6
    paddd       xmm2, xmm7
    pxor        xmm12, xmm1
    pxor        xmm13, xmm2
    movdqa      [rsp], xmm2
    movdqa      [rsp + 16], xmm3
    movdqa      xmm2, xmm12
    movdqa      xmm3, xmm13
    pslld       xmm12, 8
    pslld       xmm13, 8
    psrld       xmm2, 24
    psrld       xmm3, 24
    pxor        xmm12, xmm2
    pxor        xmm13, xmm3
    paddd       xmm10, xmm15
    paddd       xmm9, xmm14
    pxor        xmm5, xmm10
    pxor        xmm4, xmm9
    movdqa      xmm2, xmm5
    movdqa      xmm3, xmm4
    pslld       xmm5, 7
    pslld       xmm4, 7
    psrld       xmm2, 25
    psrld       xmm3, 25
    pxor        xmm5, xmm2
    pxor        xmm4, xmm3
    paddd       xmm11, xmm12
    paddd       xmm8, xmm13
    pxor        xmm6, xmm11
    pxor        xmm7, xmm8
    movdqa      xmm2, xmm6
    movdqa      xmm3, xmm7
    pslld       xmm6, 7
    pslld       xmm7, 7
    psrld       xmm2, 25
    psrld       xmm3, 25
    pxor        xmm6, xmm2
    pxor        xmm7, xmm3
    movdqa      xmm2, [rsp]
    movdqa      xmm3, [rsp + 16]

    jmp     .lr

.lb:
    movdqa      [rsp], xmm14
    movdqa      [rsp + 16], xmm15

    paddd           xmm0, [rsp + 32]
    paddd           xmm1, [rsp + 48]
    movdqa          xmm14, xmm1
    movdqa          xmm1, xmm0
    punpckldq       xmm0, xmm14
    punpckhdq       xmm1, xmm14
    paddd           xmm2, [rsp + 64]
    paddd           xmm3, [rsp + 80]
    movdqa          xmm14, xmm2
    movdqa          xmm15, xmm2
    punpckldq       xmm14, xmm3
    punpckhdq       xmm15, xmm3
    movdqa          xmm2, xmm0
    movdqa          xmm3, xmm1
    punpcklqdq      xmm0, xmm14
    punpckhqdq      xmm2, xmm14
    punpcklqdq      xmm1, xmm15
    punpckhqdq      xmm3, xmm15
    paddd           xmm4, [rsp + 96]
    paddd           xmm5, [rsp + 112]
    movdqa          xmm14, xmm5
    movdqa          xmm5, xmm4
    punpckldq       xmm4, xmm14
    punpckhdq       xmm5, xmm14
    paddd           xmm6, [rsp + 128]
    paddd           xmm7, [rsp + 144]
    movdqa          xmm14, xmm6
    movdqa          xmm15, xmm6
    punpckldq       xmm14, xmm7
    punpckhdq       xmm15, xmm7
    movdqa          xmm6, xmm4
    movdqa          xmm7, xmm5
    punpcklqdq      xmm4, xmm14
    punpckhqdq      xmm6, xmm14
    punpcklqdq      xmm5, xmm15
    punpckhqdq      xmm7, xmm15

    movdqa      xmm14, [rsp]
    movdqa      xmm15, [rsp + 16]
    movdqa      [rsp], xmm6
    movdqa      [rsp + 16], xmm7

    paddd           xmm8, [rsp + 160]
    paddd           xmm9, [rsp + 176]
    movdqa          xmm6, xmm9
    movdqa          xmm9, xmm8
    punpckldq       xmm8, xmm6
    punpckhdq       xmm9, xmm6
    paddd           xmm10, [rsp + 192]
    paddd           xmm11, [rsp + 208]
    movdqa          xmm6, xmm10
    movdqa          xmm7, xmm10
    punpckldq       xmm6, xmm11
    punpckhdq       xmm7, xmm11
    movdqa          xmm10, xmm8
    movdqa          xmm11, xmm9
    punpcklqdq      xmm8, xmm6
    punpckhqdq      xmm10, xmm6
    punpcklqdq      xmm9, xmm7
    punpckhqdq      xmm11, xmm7
    paddd           xmm12, [rsp + 224]
    paddd           xmm13, [rsp + 240]
    movdqa          xmm6, xmm13
    movdqa          xmm13, xmm12
    punpckldq       xmm12, xmm6
    punpckhdq       xmm13, xmm6
    paddd           xmm14, [rsp + 256]
    paddd           xmm15, [rsp + 272]
    movdqa          xmm6, xmm14
    movdqa          xmm7, xmm14
    punpckldq       xmm6, xmm15
    punpckhdq       xmm7, xmm15
    movdqa          xmm14, xmm12
    movdqa          xmm15, xmm13
    punpcklqdq      xmm12, xmm6
    punpckhqdq      xmm14, xmm6
    punpcklqdq      xmm13, xmm7
    punpckhqdq      xmm15, xmm7

    cmp     rbx, 4
    jbe     .lf

    test    rsi, rsi
    jnz     .lx4
    jmp     .lm4

.lf:
    test    rcx, rcx
    jnz     .ls
    test    rsi, rsi
    jnz     .lx
    jmp     .lm

.ls:
    cmp     rbx, 4
    jb      .ls3

.ls4:
    movdqa      xmm7, [rsp + 16]
    movdqu      [rdx + 48], xmm15
    movdqu      [rdx + 32], xmm11
    movdqu      [rdx + 16], xmm7
    movdqu      [rdx], xmm3

    mov     r11, 192
    test    rsi, rsi
    jnz     .lx3
    jmp     .lm3

.ls3:
    movdqu      [rdx + 48], xmm13
    movdqu      [rdx + 32], xmm9
    movdqu      [rdx + 16], xmm5
    movdqu      [rdx], xmm1

    mov     r11, 128
    test    rsi, rsi
    jnz     .lx2
    jmp     .lm2

.lm:
    cmp     rbx, 4
    jb      .lm3

.lm4:
    movdqa      xmm7, [rsp + 16]
    movdqu      [rdi + 240], xmm15
    movdqu      [rdi + 224], xmm11
    movdqu      [rdi + 208], xmm7
    movdqu      [rdi + 192], xmm3
.lm3:
    movdqu      [rdi + 176], xmm13
    movdqu      [rdi + 160], xmm9
    movdqu      [rdi + 144], xmm5
    movdqu      [rdi + 128], xmm1
.lm2:
    movdqa      xmm6, [rsp]
    movdqu      [rdi + 112], xmm14
    movdqu      [rdi + 96], xmm10
    movdqu      [rdi + 80], xmm6
    movdqu      [rdi + 64], xmm2
.lm1:
    movdqu      [rdi + 48], xmm12
    movdqu      [rdi + 32], xmm8
    movdqu      [rdi + 16], xmm4
    movdqu      [rdi], xmm0

    cmp     rbx, 4
    jbe     .f

    add     rdi, 256
    sub     rbx, 4

    cmp     rbx, 2
    ja      .ll
    je      .m
    jmp     .s

.lx:
    cmp     rbx, 4
    jb      .lx3

.lx4:
    movdqu      xmm7, [rsi + 240]
    movdqu      xmm6, [rsi + 224]
    pxor        xmm7, xmm15
    pxor        xmm6, xmm11
    movdqu      [rdi + 240], xmm7
    movdqu      [rdi + 224], xmm6
    movdqu      xmm7, [rsi + 208]
    movdqu      xmm6, [rsi + 192]
    pxor        xmm7, [rsp + 16]
    pxor        xmm6, xmm3
    movdqu      [rdi + 208], xmm7
    movdqu      [rdi + 192], xmm6
.lx3:
    movdqu      xmm7, [rsi + 176]
    movdqu      xmm6, [rsi + 160]
    pxor        xmm7, xmm13
    pxor        xmm6, xmm9
    movdqu      [rdi + 176], xmm7
    movdqu      [rdi + 160], xmm6
    movdqu      xmm7, [rsi + 144]
    movdqu      xmm6, [rsi + 128]
    pxor        xmm7, xmm5
    pxor        xmm6, xmm1
    movdqu      [rdi + 144], xmm7
    movdqu      [rdi + 128], xmm6
.lx2:
    movdqu      xmm7, [rsi + 112]
    movdqu      xmm6, [rsi + 96]
    pxor        xmm7, xmm14
    pxor        xmm6, xmm10
    movdqu      [rdi + 112], xmm7
    movdqu      [rdi + 96], xmm6
    movdqu      xmm7, [rsi + 80]
    movdqu      xmm6, [rsi + 64]
    pxor        xmm7, [rsp]
    pxor        xmm6, xmm2
    movdqu      [rdi + 80], xmm7
    movdqu      [rdi + 64], xmm6
.lx1:
    movdqu      xmm7, [rsi + 48]
    movdqu      xmm6, [rsi + 32]
    pxor        xmm7, xmm12
    pxor        xmm6, xmm8
    movdqu      [rdi + 48], xmm7
    movdqu      [rdi + 32], xmm6
    movdqu      xmm7, [rsi + 16]
    movdqu      xmm6, [rsi]
    pxor        xmm7, xmm4
    pxor        xmm6, xmm0
    movdqu      [rdi + 16], xmm7
    movdqu      [rdi], xmm6

    cmp     rbx, 4
    jbe     .f

    add     rdi, 256
    add     rsi, 256
    sub     rbx, 4

    cmp     rbx, 2
    ja      .ll
    je      .m

.s:
    movdqu      xmm10, [r8]
    movdqu      xmm11, [r8 + 16]
    movdqu      xmm12, [r8 + 32]
    movdqu      xmm13, [r8 + 48]

    movdqa      xmm0, xmm10
    movdqa      xmm1, xmm11
    movdqa      xmm2, xmm12
    movdqa      xmm3, xmm13

    add     [r8 + 48], rbx

.sr:
    sub     r9, 2
    jc      .sb

    paddd       xmm0, xmm1
    pxor        xmm3, xmm0
    pshuflw     xmm3, xmm3, 0xb1
    pshufhw     xmm3, xmm3, 0xb1
    paddd       xmm2, xmm3
    pxor        xmm1, xmm2
    movdqa      xmm8, xmm1
    pslld       xmm8, 12
    psrld       xmm1, 20
    pxor        xmm1, xmm8
    paddd       xmm0, xmm1
    pxor        xmm3, xmm0
    movdqa      xmm8, xmm3
    pslld       xmm3, 8
    psrld       xmm8, 24
    pxor        xmm3, xmm8
    paddd       xmm2, xmm3
    pxor        xmm1, xmm2
    movdqa      xmm8, xmm1
    pslld       xmm8, 7
    psrld       xmm1, 25
    pxor        xmm1, xmm8
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
    pxor        xmm1, xmm8
    paddd       xmm0, xmm1
    pxor        xmm3, xmm0
    movdqa      xmm8, xmm3
    pslld       xmm3, 8
    psrld       xmm8, 24
    pxor        xmm3, xmm8
    paddd       xmm2, xmm3
    pxor        xmm1, xmm2
    movdqa      xmm8, xmm1
    pslld       xmm8, 7
    psrld       xmm1, 25
    pxor        xmm1, xmm8
    pshufd      xmm0, xmm0, 0x39
    pshufd      xmm2, xmm2, 0x93
    pshufd      xmm3, xmm3, 0x4e

    jmp     .sr

.sb:
    paddd       xmm0, xmm10
    paddd       xmm1, xmm11
    paddd       xmm2, xmm12
    paddd       xmm3, xmm13

    test    rcx, rcx
    jnz     .ms1
    test    rsi, rsi
    jnz     .mx1
    jmp     .mm1

.m:
    movdqu      xmm10, [r8]
    movdqu      xmm11, [r8 + 16]
    movdqu      xmm12, [r8 + 32]
    movdqu      xmm13, [r8 + 48]

    movdqa      xmm14, [rel k1000]
    paddq       xmm14, xmm13

    movdqa      xmm0, xmm10
    movdqa      xmm1, xmm11
    movdqa      xmm2, xmm12
    movdqa      xmm3, xmm13
    movdqa      xmm4, xmm10
    movdqa      xmm5, xmm11
    movdqa      xmm6, xmm12
    movdqa      xmm7, xmm14

    add     [r8 + 48], rbx

.mr:
    sub     r9, 2
    jc      .mb

    paddd       xmm0, xmm1
    paddd       xmm4, xmm5
    pxor        xmm3, xmm0
    pxor        xmm7, xmm4
    pshuflw     xmm3, xmm3, 0xb1
    pshufhw     xmm3, xmm3, 0xb1
    pshuflw     xmm7, xmm7, 0xb1
    pshufhw     xmm7, xmm7, 0xb1
    paddd       xmm2, xmm3
    paddd       xmm6, xmm7
    pxor        xmm1, xmm2
    pxor        xmm5, xmm6
    movdqa      xmm8, xmm1
    pslld       xmm8, 12
    psrld       xmm1, 20
    movdqa      xmm9, xmm5
    pslld       xmm9, 12
    psrld       xmm5, 20
    pxor        xmm1, xmm8
    pxor        xmm5, xmm9
    paddd       xmm0, xmm1
    paddd       xmm4, xmm5
    pxor        xmm3, xmm0
    pxor        xmm7, xmm4
    movdqa      xmm8, xmm3
    pslld       xmm8, 8
    psrld       xmm3, 24
    movdqa      xmm9, xmm7
    pslld       xmm9, 8
    psrld       xmm7, 24
    pxor        xmm3, xmm8
    pxor        xmm7, xmm9
    paddd       xmm2, xmm3
    paddd       xmm6, xmm7
    pxor        xmm1, xmm2
    pxor        xmm5, xmm6
    pshufd      xmm0, xmm0, 0x93
    pshufd      xmm4, xmm4, 0x93
    movdqa      xmm8, xmm1
    pslld       xmm8, 7
    psrld       xmm1, 25
    pshufd      xmm2, xmm2, 0x39
    pshufd      xmm6, xmm6, 0x39
    movdqa      xmm9, xmm5
    pslld       xmm9, 7
    psrld       xmm5, 25
    pshufd      xmm3, xmm3, 0x4e
    pshufd      xmm7, xmm7, 0x4e
    pxor        xmm1, xmm8
    pxor        xmm5, xmm9

    paddd       xmm0, xmm1
    paddd       xmm4, xmm5
    pxor        xmm3, xmm0
    pxor        xmm7, xmm4
    pshuflw     xmm3, xmm3, 0xb1
    pshufhw     xmm3, xmm3, 0xb1
    pshuflw     xmm7, xmm7, 0xb1
    pshufhw     xmm7, xmm7, 0xb1
    paddd       xmm2, xmm3
    paddd       xmm6, xmm7
    pxor        xmm1, xmm2
    pxor        xmm5, xmm6
    movdqa      xmm8, xmm1
    pslld       xmm8, 12
    psrld       xmm1, 20
    movdqa      xmm9, xmm5
    pslld       xmm9, 12
    psrld       xmm5, 20
    pxor        xmm1, xmm8
    pxor        xmm5, xmm9
    paddd       xmm0, xmm1
    paddd       xmm4, xmm5
    pxor        xmm3, xmm0
    pxor        xmm7, xmm4
    movdqa      xmm8, xmm3
    pslld       xmm8, 8
    psrld       xmm3, 24
    movdqa      xmm9, xmm7
    pslld       xmm9, 8
    psrld       xmm7, 24
    pxor        xmm3, xmm8
    pxor        xmm7, xmm9
    paddd       xmm2, xmm3
    paddd       xmm6, xmm7
    pxor        xmm1, xmm2
    pxor        xmm5, xmm6
    pshufd      xmm0, xmm0, 0x39
    pshufd      xmm4, xmm4, 0x39
    movdqa      xmm8, xmm1
    pslld       xmm8, 7
    psrld       xmm1, 25
    pshufd      xmm2, xmm2, 0x93
    pshufd      xmm6, xmm6, 0x93
    movdqa      xmm9, xmm5
    pslld       xmm9, 7
    psrld       xmm5, 25
    pshufd      xmm3, xmm3, 0x4e
    pshufd      xmm7, xmm7, 0x4e
    pxor        xmm1, xmm8
    pxor        xmm5, xmm9

    jmp     .mr

.mb:
    paddd       xmm0, xmm10
    paddd       xmm1, xmm11
    paddd       xmm2, xmm12
    paddd       xmm3, xmm13
    paddd       xmm4, xmm10
    paddd       xmm5, xmm11
    paddd       xmm6, xmm12
    paddd       xmm7, xmm14

    test    rcx, rcx
    jnz     .ms2
    test    rsi, rsi
    jnz     .mx2
    jmp     .mm2

.ms2:
    movdqu      [rdx + 48], xmm7
    movdqu      [rdx + 32], xmm6
    movdqu      [rdx + 16], xmm5
    movdqu      [rdx], xmm4

    mov     r11, 64
    test    rsi, rsi
    jnz     .mx1
    jmp     .mm1

.ms1:
    movdqu      [rdx + 48], xmm3
    movdqu      [rdx + 32], xmm2
    movdqu      [rdx + 16], xmm1
    movdqu      [rdx], xmm0

    xor     r11, r11
    jmp     .f

.mm2:
    movdqu      [rdi + 112], xmm7
    movdqu      [rdi + 96], xmm6
    movdqu      [rdi + 80], xmm5
    movdqu      [rdi + 64], xmm4
.mm1:
    movdqu      [rdi + 48], xmm3
    movdqu      [rdi + 32], xmm2
    movdqu      [rdi + 16], xmm1
    movdqu      [rdi], xmm0

    jmp     .f

.mx2:
    movdqu      xmm13, [rsi + 112]
    movdqu      xmm12, [rsi + 96]
    movdqu      xmm11, [rsi + 80]
    movdqu      xmm10, [rsi + 64]
    pxor        xmm7, xmm13
    pxor        xmm6, xmm12
    pxor        xmm5, xmm11
    pxor        xmm4, xmm10
    movdqu      [rdi + 112], xmm7
    movdqu      [rdi + 96], xmm6
    movdqu      [rdi + 80], xmm5
    movdqu      [rdi + 64], xmm4
.mx1:
    movdqu      xmm13, [rsi + 48]
    movdqu      xmm12, [rsi + 32]
    movdqu      xmm11, [rsi + 16]
    movdqu      xmm10, [rsi]
    pxor        xmm3, xmm13
    pxor        xmm2, xmm12
    pxor        xmm1, xmm11
    pxor        xmm0, xmm10
    movdqu      [rdi + 48], xmm3
    movdqu      [rdi + 32], xmm2
    movdqu      [rdi + 16], xmm1
    movdqu      [rdi], xmm0

.f:
    test    rcx, rcx
    jz      .r
    test    rsi, rsi
    jnz     .fx

.fm:
    add     rdi, r11
    xor     rbx, rbx

    bt      rcx, 5
    jnc     .fm16

    movdqu      xmm1, [rdx + rbx + 16]
    movdqu      xmm0, [rdx + rbx]
    movdqu      [rdi + rbx + 16], xmm1
    movdqu      [rdi + rbx], xmm0
    add         rbx, 32

.fm16:
    bt      rcx, 4
    jnc     .fm8

    movdqu      xmm0, [rdx + rbx]
    movdqu      [rdi + rbx], xmm0
    add         rbx, 16

.fm8:
    bt      rcx, 3
    jnc     .fm4

    mov     rax, [rdx + rbx]
    mov     [rdi + rbx], rax
    add     rbx, 8

.fm4:
    bt      rcx, 2
    jnc     .fm2

    mov     eax, [rdx + rbx]
    mov     [rdi + rbx], eax
    add     rbx, 4

.fm2:
    bt      rcx, 1
    jnc     .fm1

    mov     ax, [rdx + rbx]
    mov     [rdi + rbx], ax
    add     rbx, 2

.fm1:
    bt      rcx, 0
    jnc     .r

    mov     al, [rdx + rbx]
    mov     [rdi + rbx], al
    jmp     .r

.fx:
    add     rdi, r11
    add     rsi, r11
    xor     rbx, rbx

    bt      rcx, 5
    jnc     .fx16

    movdqu      xmm3, [rdx + rbx + 16]
    movdqu      xmm2, [rdx + rbx]
    movdqu      xmm1, [rsi + rbx + 16]
    movdqu      xmm0, [rsi + rbx]
    pxor        xmm1, xmm3
    pxor        xmm0, xmm2
    movdqu      [rdi + rbx + 16], xmm1
    movdqu      [rdi + rbx], xmm0
    add         rbx, 32

.fx16:
    bt      rcx, 4
    jnc     .fx8

    movdqu      xmm1, [rdx + rbx]
    movdqu      xmm0, [rsi + rbx]
    pxor        xmm0, xmm1
    movdqu      [rdi + rbx], xmm0
    add         rbx, 16

.fx8:
    bt      rcx, 3
    jnc     .fx4

    mov     rax, [rdx + rbx]
    xor     rax, [rsi + rbx]
    mov     [rdi + rbx], rax
    add     rbx, 8

.fx4:
    bt      rcx, 2
    jnc     .fx2

    mov     eax, [rdx + rbx]
    xor     eax, [rsi + rbx]
    mov     [rdi + rbx], eax
    add     rbx, 4

.fx2:
    bt      rcx, 1
    jnc     .fx1

    mov     ax, [rdx + rbx]
    xor     ax, [rsi + rbx]
    mov     [rdi + rbx], ax
    add     rbx, 2

.fx1:
    bt      rcx, 0
    jnc     .r

    mov     al, [rdx + rbx]
    xor     al, [rsi + rbx]
    mov     [rdi + rbx], al

.r:
    mov     rsp, rbp
    pop     rbp
    pop     rbx
    ret


    section .rodata
    align   64

k0123:
    dd  0, 1, 2, 3

k1000:
    dd  1, 0, 0, 0

k00n1:
    dd  0, 0, 0, 0
    dd  1, 1, 1, 1
