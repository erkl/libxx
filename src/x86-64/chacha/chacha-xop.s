; Copyright (c) 2018, Erik Lundin.

    section .text align=64

    global  xx__chacha_xop


; An optimized implementation of our core ChaCha function, targeting the XOP
; instruction set extension.

xx__chacha_xop:
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

    ; One or more batches of 3 or 4 blocks each.

.l:
    vbroadcastss    xmm0, [r8]
    vbroadcastss    xmm1, [r8 + 4]
    vbroadcastss    xmm2, [r8 + 8]
    vbroadcastss    xmm3, [r8 + 12]
    vbroadcastss    xmm4, [r8 + 16]
    vbroadcastss    xmm5, [r8 + 20]
    vbroadcastss    xmm6, [r8 + 24]
    vbroadcastss    xmm7, [r8 + 28]
    vbroadcastss    xmm8, [r8 + 32]
    vbroadcastss    xmm9, [r8 + 36]
    vbroadcastss    xmm10, [r8 + 40]
    vbroadcastss    xmm11, [r8 + 44]
    vbroadcastss    xmm12, [r8 + 48]
    vbroadcastss    xmm13, [r8 + 52]
    vbroadcastss    xmm14, [r8 + 56]
    vbroadcastss    xmm15, [r8 + 60]

    vmovdqa     [rsp + 32], xmm0
    vmovdqa     [rsp + 48], xmm1
    vmovdqa     [rsp + 64], xmm2
    vmovdqa     [rsp + 80], xmm3
    vmovdqa     [rsp + 96], xmm4
    vmovdqa     [rsp + 112], xmm5
    vmovdqa     [rsp + 128], xmm6
    vmovdqa     [rsp + 144], xmm7
    vmovdqa     [rsp + 160], xmm8
    vmovdqa     [rsp + 176], xmm9
    vmovdqa     [rsp + 192], xmm10
    vmovdqa     [rsp + 208], xmm11
    vmovdqa     [rsp + 256], xmm14
    vmovdqa     [rsp + 272], xmm15

    mov     r10, [r8 + 48]
    jmp     .li

    ; Outer loop jump target.

.ll:
    vbroadcastss    xmm0, [r8]
    vbroadcastss    xmm1, [r8 + 4]
    vbroadcastss    xmm2, [r8 + 8]
    vbroadcastss    xmm3, [r8 + 12]
    vbroadcastss    xmm4, [r8 + 16]
    vbroadcastss    xmm5, [r8 + 20]
    vbroadcastss    xmm6, [r8 + 24]
    vbroadcastss    xmm7, [r8 + 28]
    vbroadcastss    xmm8, [r8 + 32]
    vbroadcastss    xmm9, [r8 + 36]
    vbroadcastss    xmm10, [r8 + 40]
    vbroadcastss    xmm11, [r8 + 44]
    vbroadcastss    xmm12, [r8 + 48]
    vbroadcastss    xmm13, [r8 + 52]
    vbroadcastss    xmm14, [r8 + 56]
    vbroadcastss    xmm15, [r8 + 60]

    ; Bump the block counter.

.li:
    mov     rax, 4
    cmp     rax, rbx
    cmova   rax, rbx

    mov     r11, r10
    add     r10, rax
    mov     [r8 + 48], r10

    ; Propagate block counter carries.

    cmp     r10d, eax
    jae     .la

    lea         rax, [rel k00n1]
    add         r11d, 4
    vpaddd      xmm13, xmm13, [rax + 4 * r11]

.la:
    vpaddd      xmm12, xmm12, [rel k0123]
    vmovdqa     [rsp + 224], xmm12
    vmovdqa     [rsp + 240], xmm13

    ; Double-round loop.

    mov     rax, r9

.lr:
    sub     rax, 2
    jc      .lb

    vpaddd      xmm0, xmm0, xmm4
    vpxor       xmm12, xmm12, xmm0
    vprotd      xmm12, xmm12, 16
    vpaddd      xmm1, xmm1, xmm5
    vpxor       xmm13, xmm13, xmm1
    vprotd      xmm13, xmm13, 16
    vpaddd      xmm2, xmm2, xmm6
    vpxor       xmm14, xmm14, xmm2
    vprotd      xmm14, xmm14, 16
    vpaddd      xmm3, xmm3, xmm7
    vpxor       xmm15, xmm15, xmm3
    vprotd      xmm15, xmm15, 16
    vpaddd      xmm8, xmm8, xmm12
    vpxor       xmm4, xmm4, xmm8
    vprotd      xmm4, xmm4, 12
    vpaddd      xmm9, xmm9, xmm13
    vpxor       xmm5, xmm5, xmm9
    vprotd      xmm5, xmm5, 12
    vpaddd      xmm10, xmm10, xmm14
    vpxor       xmm6, xmm6, xmm10
    vprotd      xmm6, xmm6, 12
    vpaddd      xmm11, xmm11, xmm15
    vpxor       xmm7, xmm7, xmm11
    vprotd      xmm7, xmm7, 12
    vpaddd      xmm0, xmm0, xmm4
    vpxor       xmm12, xmm12, xmm0
    vprotd      xmm12, xmm12, 8
    vpaddd      xmm1, xmm1, xmm5
    vpxor       xmm13, xmm13, xmm1
    vprotd      xmm13, xmm13, 8
    vpaddd      xmm2, xmm2, xmm6
    vpxor       xmm14, xmm14, xmm2
    vprotd      xmm14, xmm14, 8
    vpaddd      xmm3, xmm3, xmm7
    vpxor       xmm15, xmm15, xmm3
    vprotd      xmm15, xmm15, 8
    vpaddd      xmm8, xmm8, xmm12
    vpxor       xmm4, xmm4, xmm8
    vprotd      xmm4, xmm4, 7
    vpaddd      xmm9, xmm9, xmm13
    vpxor       xmm5, xmm5, xmm9
    vprotd      xmm5, xmm5, 7
    vpaddd      xmm10, xmm10, xmm14
    vpxor       xmm6, xmm6, xmm10
    vprotd      xmm6, xmm6, 7
    vpaddd      xmm11, xmm11, xmm15
    vpxor       xmm7, xmm7, xmm11
    vprotd      xmm7, xmm7, 7

    vpaddd      xmm0, xmm0, xmm5
    vpxor       xmm15, xmm15, xmm0
    vprotd      xmm15, xmm15, 16
    vpaddd      xmm3, xmm3, xmm4
    vpxor       xmm14, xmm14, xmm3
    vprotd      xmm14, xmm14, 16
    vpaddd      xmm1, xmm1, xmm6
    vpxor       xmm12, xmm12, xmm1
    vprotd      xmm12, xmm12, 16
    vpaddd      xmm2, xmm2, xmm7
    vpxor       xmm13, xmm13, xmm2
    vprotd      xmm13, xmm13, 16
    vpaddd      xmm10, xmm10, xmm15
    vpxor       xmm5, xmm5, xmm10
    vprotd      xmm5, xmm5, 12
    vpaddd      xmm9, xmm9, xmm14
    vpxor       xmm4, xmm4, xmm9
    vprotd      xmm4, xmm4, 12
    vpaddd      xmm11, xmm11, xmm12
    vpxor       xmm6, xmm6, xmm11
    vprotd      xmm6, xmm6, 12
    vpaddd      xmm8, xmm8, xmm13
    vpxor       xmm7, xmm7, xmm8
    vprotd      xmm7, xmm7, 12
    vpaddd      xmm0, xmm0, xmm5
    vpxor       xmm15, xmm15, xmm0
    vprotd      xmm15, xmm15, 8
    vpaddd      xmm3, xmm3, xmm4
    vpxor       xmm14, xmm14, xmm3
    vprotd      xmm14, xmm14, 8
    vpaddd      xmm1, xmm1, xmm6
    vpxor       xmm12, xmm12, xmm1
    vprotd      xmm12, xmm12, 8
    vpaddd      xmm2, xmm2, xmm7
    vpxor       xmm13, xmm13, xmm2
    vprotd      xmm13, xmm13, 8
    vpaddd      xmm10, xmm10, xmm15
    vpxor       xmm5, xmm5, xmm10
    vprotd      xmm5, xmm5, 7
    vpaddd      xmm9, xmm9, xmm14
    vpxor       xmm4, xmm4, xmm9
    vprotd      xmm4, xmm4, 7
    vpaddd      xmm11, xmm11, xmm12
    vpxor       xmm6, xmm6, xmm11
    vprotd      xmm6, xmm6, 7
    vpaddd      xmm8, xmm8, xmm13
    vpxor       xmm7, xmm7, xmm8
    vprotd      xmm7, xmm7, 7

    jmp     .lr

    ; Finish and transpose this batch.

.lb:
    vmovdqa     [rsp], xmm14
    vmovdqa     [rsp + 16], xmm15

    vpaddd          xmm0, xmm0, [rsp + 32]
    vpaddd          xmm1, xmm1, [rsp + 48]
    vpunpckldq      xmm14, xmm0, xmm1
    vpunpckhdq      xmm1, xmm0, xmm1
    vpaddd          xmm2, xmm2, [rsp + 64]
    vpaddd          xmm3, xmm3, [rsp + 80]
    vpunpckhdq      xmm15, xmm2, xmm3
    vpunpckldq      xmm2, xmm2, xmm3
    vpunpcklqdq     xmm0, xmm14, xmm2
    vpunpckhqdq     xmm2, xmm14, xmm2
    vpunpckhqdq     xmm3, xmm1, xmm15
    vpunpcklqdq     xmm1, xmm1, xmm15
    vpaddd          xmm4, xmm4, [rsp + 96]
    vpaddd          xmm5, xmm5, [rsp + 112]
    vpunpckldq      xmm14, xmm4, xmm5
    vpunpckhdq      xmm5, xmm4, xmm5
    vpaddd          xmm6, xmm6, [rsp + 128]
    vpaddd          xmm7, xmm7, [rsp + 144]
    vpunpckhdq      xmm15, xmm6, xmm7
    vpunpckldq      xmm6, xmm6, xmm7
    vpunpcklqdq     xmm4, xmm14, xmm6
    vpunpckhqdq     xmm6, xmm14, xmm6
    vpunpckhqdq     xmm7, xmm5, xmm15
    vpunpcklqdq     xmm5, xmm5, xmm15

    vmovdqa     xmm14, [rsp]
    vmovdqa     xmm15, [rsp + 16]
    vmovdqa     [rsp], xmm6
    vmovdqa     [rsp + 16], xmm7

    vpaddd          xmm8, xmm8, [rsp + 160]
    vpaddd          xmm9, xmm9, [rsp + 176]
    vpunpckldq      xmm6, xmm8, xmm9
    vpunpckhdq      xmm9, xmm8, xmm9
    vpaddd          xmm10, xmm10, [rsp + 192]
    vpaddd          xmm11, xmm11, [rsp + 208]
    vpunpckhdq      xmm7, xmm10, xmm11
    vpunpckldq      xmm10, xmm10, xmm11
    vpunpcklqdq     xmm8, xmm6, xmm10
    vpunpckhqdq     xmm10, xmm6, xmm10
    vpunpckhqdq     xmm11, xmm9, xmm7
    vpunpcklqdq     xmm9, xmm9, xmm7
    vpaddd          xmm12, xmm12, [rsp + 224]
    vpaddd          xmm13, xmm13, [rsp + 240]
    vpunpckldq      xmm6, xmm12, xmm13
    vpunpckhdq      xmm13, xmm12, xmm13
    vpaddd          xmm14, xmm14, [rsp + 256]
    vpaddd          xmm15, xmm15, [rsp + 272]
    vpunpckhdq      xmm7, xmm14, xmm15
    vpunpckldq      xmm14, xmm14, xmm15
    vpunpcklqdq     xmm12, xmm6, xmm14
    vpunpckhqdq     xmm14, xmm6, xmm14
    vpunpckhqdq     xmm15, xmm13, xmm7
    vpunpcklqdq     xmm13, xmm13, xmm7

    vmovdqa     xmm6, [rsp]
    vmovdqa     xmm7, [rsp + 16]

    ; Skip branch conditions that only apply to the final batch.

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

    ; Spill the last block to [rdx].

.ls:
    cmp     rbx, 4
    jb      .ls3

.ls4:
    vmovdqu     [rdx + 48], xmm15
    vmovdqu     [rdx + 32], xmm11
    vmovdqu     [rdx + 16], xmm7
    vmovdqu     [rdx], xmm3

    mov     r11, 192
    test    rsi, rsi
    jnz     .lx3
    jmp     .lm3

.ls3:
    vmovdqu     [rdx + 48], xmm13
    vmovdqu     [rdx + 32], xmm9
    vmovdqu     [rdx + 16], xmm5
    vmovdqu     [rdx], xmm1

    mov     r11, 128
    test    rsi, rsi
    jnz     .lx2
    jmp     .lm2

    ; Write 3 or 4 whole blocks (mov).

.lm:
    cmp     rbx, 4
    jb      .lm3

.lm4:
    vmovdqu     [rdi + 240], xmm15
    vmovdqu     [rdi + 224], xmm11
    vmovdqu     [rdi + 208], xmm7
    vmovdqu     [rdi + 192], xmm3
.lm3:
    vmovdqu     [rdi + 176], xmm13
    vmovdqu     [rdi + 160], xmm9
    vmovdqu     [rdi + 144], xmm5
    vmovdqu     [rdi + 128], xmm1
.lm2:
    vmovdqu     [rdi + 112], xmm14
    vmovdqu     [rdi + 96], xmm10
    vmovdqu     [rdi + 80], xmm6
    vmovdqu     [rdi + 64], xmm2
.lm1:
    vmovdqu     [rdi + 48], xmm12
    vmovdqu     [rdi + 32], xmm8
    vmovdqu     [rdi + 16], xmm4
    vmovdqu     [rdi], xmm0

    cmp     rbx, 4
    jbe     .f

    add     rdi, 256
    sub     rbx, 4

    cmp     rbx, 2
    ja      .ll
    je      .m
    jmp     .s

    ; Write 3 or 4 whole blocks (xor).

.lx:
    cmp     rbx, 4
    jb      .lx3

.lx4:
    vpxor       xmm15, xmm15, [rsi + 240]
    vmovdqu     [rdi + 240], xmm15
    vpxor       xmm11, xmm11, [rsi + 224]
    vmovdqu     [rdi + 224], xmm11
    vpxor       xmm7, xmm7, [rsi + 208]
    vmovdqu     [rdi + 208], xmm7
    vpxor       xmm3, xmm3, [rsi + 192]
    vmovdqu     [rdi + 192], xmm3
.lx3:
    vpxor       xmm13, xmm13, [rsi + 176]
    vmovdqu     [rdi + 176], xmm13
    vpxor       xmm9, xmm9, [rsi + 160]
    vmovdqu     [rdi + 160], xmm9
    vpxor       xmm5, xmm5, [rsi + 144]
    vmovdqu     [rdi + 144], xmm5
    vpxor       xmm1, xmm1, [rsi + 128]
    vmovdqu     [rdi + 128], xmm1
.lx2:
    vpxor       xmm14, xmm14, [rsi + 112]
    vmovdqu     [rdi + 112], xmm14
    vpxor       xmm10, xmm10, [rsi + 96]
    vmovdqu     [rdi + 96], xmm10
    vpxor       xmm6, xmm6, [rsi + 80]
    vmovdqu     [rdi + 80], xmm6
    vpxor       xmm2, xmm2, [rsi + 64]
    vmovdqu     [rdi + 64], xmm2
.lx1:
    vpxor       xmm12, xmm12, [rsi + 48]
    vmovdqu     [rdi + 48], xmm12
    vpxor       xmm8, xmm8, [rsi + 32]
    vmovdqu     [rdi + 32], xmm8
    vpxor       xmm4, xmm4, [rsi + 16]
    vmovdqu     [rdi + 16], xmm4
    vpxor       xmm0, xmm0, [rsi]
    vmovdqu     [rdi], xmm0

    cmp     rbx, 4
    jbe     .f

    add     rdi, 256
    add     rsi, 256
    sub     rbx, 4

    cmp     rbx, 2
    ja      .ll
    je      .m

    ; One batch of 1 block.

.s:
    vmovdqu     xmm10, [r8]
    vmovdqu     xmm11, [r8 + 16]
    vmovdqu     xmm12, [r8 + 32]
    vmovdqu     xmm13, [r8 + 48]

    vmovdqa     xmm0, xmm10
    vmovdqa     xmm1, xmm11
    vmovdqa     xmm2, xmm12
    vmovdqa     xmm3, xmm13

    ; Bump the block counter.

    add     [r8 + 48], rbx

    ; Double-round loop.

.sr:
    sub     r9, 2
    jc      .sb

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

    jmp     .sr

    ; Finish the batch.

.sb:
    vpaddd      xmm0, xmm0, xmm10
    vpaddd      xmm1, xmm1, xmm11
    vpaddd      xmm2, xmm2, xmm12
    vpaddd      xmm3, xmm3, xmm13

    ; Reuse the .m path's output code.

    test    rcx, rcx
    jnz     .ms1
    test    rsi, rsi
    jnz     .mx1
    jmp     .mm1

    ; One batch of 2 blocks.

.m:
    vmovdqu     xmm10, [r8]
    vmovdqu     xmm11, [r8 + 16]
    vmovdqu     xmm12, [r8 + 32]
    vmovdqu     xmm13, [r8 + 48]

    vpaddq      xmm14, xmm13, [rel k1000]

    vmovdqa     xmm0, xmm10
    vmovdqa     xmm1, xmm11
    vmovdqa     xmm2, xmm12
    vmovdqa     xmm3, xmm13
    vmovdqa     xmm4, xmm10
    vmovdqa     xmm5, xmm11
    vmovdqa     xmm6, xmm12
    vmovdqa     xmm7, xmm14

    ; Bump the block counter.

    add     [r8 + 48], rbx

    ; Double-round loop.

.mr:
    sub     r9, 2
    jc      .mb

    vpaddd      xmm0, xmm0, xmm1
    vpaddd      xmm4, xmm4, xmm5
    vpxor       xmm3, xmm3, xmm0
    vpxor       xmm7, xmm7, xmm4
    vprotd      xmm3, xmm3, 16
    vprotd      xmm7, xmm7, 16
    vpaddd      xmm2, xmm2, xmm3
    vpaddd      xmm6, xmm6, xmm7
    vpxor       xmm1, xmm1, xmm2
    vpxor       xmm5, xmm5, xmm6
    vprotd      xmm1, xmm1, 12
    vprotd      xmm5, xmm5, 12
    vpaddd      xmm0, xmm0, xmm1
    vpaddd      xmm4, xmm4, xmm5
    vpxor       xmm3, xmm3, xmm0
    vpxor       xmm7, xmm7, xmm4
    vprotd      xmm3, xmm3, 8
    vprotd      xmm7, xmm7, 8
    vpaddd      xmm2, xmm2, xmm3
    vpaddd      xmm6, xmm6, xmm7
    vpshufd     xmm0, xmm0, 0x93
    vpshufd     xmm4, xmm4, 0x93
    vpxor       xmm1, xmm1, xmm2
    vpxor       xmm5, xmm5, xmm6
    vpshufd     xmm2, xmm2, 0x39
    vpshufd     xmm6, xmm6, 0x39
    vprotd      xmm1, xmm1, 7
    vprotd      xmm5, xmm5, 7
    vpshufd     xmm3, xmm3, 0x4e
    vpshufd     xmm7, xmm7, 0x4e

    vpaddd      xmm0, xmm0, xmm1
    vpaddd      xmm4, xmm4, xmm5
    vpxor       xmm3, xmm3, xmm0
    vpxor       xmm7, xmm7, xmm4
    vprotd      xmm3, xmm3, 16
    vprotd      xmm7, xmm7, 16
    vpaddd      xmm2, xmm2, xmm3
    vpaddd      xmm6, xmm6, xmm7
    vpxor       xmm1, xmm1, xmm2
    vpxor       xmm5, xmm5, xmm6
    vprotd      xmm1, xmm1, 12
    vprotd      xmm5, xmm5, 12
    vpaddd      xmm0, xmm0, xmm1
    vpaddd      xmm4, xmm4, xmm5
    vpxor       xmm3, xmm3, xmm0
    vpxor       xmm7, xmm7, xmm4
    vprotd      xmm3, xmm3, 8
    vprotd      xmm7, xmm7, 8
    vpaddd      xmm2, xmm2, xmm3
    vpaddd      xmm6, xmm6, xmm7
    vpshufd     xmm0, xmm0, 0x39
    vpshufd     xmm4, xmm4, 0x39
    vpxor       xmm1, xmm1, xmm2
    vpxor       xmm5, xmm5, xmm6
    vpshufd     xmm2, xmm2, 0x93
    vpshufd     xmm6, xmm6, 0x93
    vprotd      xmm1, xmm1, 7
    vprotd      xmm5, xmm5, 7
    vpshufd     xmm3, xmm3, 0x4e
    vpshufd     xmm7, xmm7, 0x4e

    jmp     .mr

    ; Finish the batch.

.mb:
    vpaddd      xmm0, xmm0, xmm10
    vpaddd      xmm1, xmm1, xmm11
    vpaddd      xmm2, xmm2, xmm12
    vpaddd      xmm3, xmm3, xmm13
    vpaddd      xmm4, xmm4, xmm10
    vpaddd      xmm5, xmm5, xmm11
    vpaddd      xmm6, xmm6, xmm12
    vpaddd      xmm7, xmm7, xmm14

    test    rcx, rcx
    jnz     .ms2
    test    rsi, rsi
    jnz     .mx2
    jmp     .mm2

    ; Spill the last block to [rdx].

.ms2:
    vmovdqu     [rdx + 48], xmm7
    vmovdqu     [rdx + 32], xmm6
    vmovdqu     [rdx + 16], xmm5
    vmovdqu     [rdx], xmm4

    mov     r11, 64
    test    rsi, rsi
    jnz     .mx1
    jmp     .mm1

.ms1:
    vmovdqu     [rdx + 48], xmm3
    vmovdqu     [rdx + 32], xmm2
    vmovdqu     [rdx + 16], xmm1
    vmovdqu     [rdx], xmm0

    xor     r11, r11
    jmp     .f

    ; Write 1 or 2 whole blocks (mov).

.mm2:
    vmovdqu     [rdi + 112], xmm7
    vmovdqu     [rdi + 96], xmm6
    vmovdqu     [rdi + 80], xmm5
    vmovdqu     [rdi + 64], xmm4
.mm1:
    vmovdqu     [rdi + 48], xmm3
    vmovdqu     [rdi + 32], xmm2
    vmovdqu     [rdi + 16], xmm1
    vmovdqu     [rdi], xmm0

    jmp     .f

    ; Write 1 or 2 whole blocks (xor).

.mx2:
    vpxor       xmm7, xmm7, [rsi + 112]
    vmovdqu     [rdi + 112], xmm7
    vpxor       xmm6, xmm6, [rsi + 96]
    vmovdqu     [rdi + 96], xmm6
    vpxor       xmm5, xmm5, [rsi + 80]
    vmovdqu     [rdi + 80], xmm5
    vpxor       xmm4, xmm4, [rsi + 64]
    vmovdqu     [rdi + 64], xmm4
.mx1:
    vpxor       xmm3, xmm3, [rsi + 48]
    vmovdqu     [rdi + 48], xmm3
    vpxor       xmm2, xmm2, [rsi + 32]
    vmovdqu     [rdi + 32], xmm2
    vpxor       xmm1, xmm1, [rsi + 16]
    vmovdqu     [rdi + 16], xmm1
    vpxor       xmm0, xmm0, [rsi]
    vmovdqu     [rdi], xmm0

    ; Deal with partial final blocks.

.f:
    test    rcx, rcx
    jz      .r
    test    rsi, rsi
    jnz     .fx

    ; Write the final 1 to 63 bytes (mov).

.fm:
    add     rdi, r11
    xor     rbx, rbx

    bt      rcx, 5
    jnc     .fm16

    vmovdqu     xmm1, [rdx + rbx + 16]
    vmovdqu     xmm0, [rdx + rbx]
    vmovdqu     [rdi + rbx + 16], xmm1
    vmovdqu     [rdi + rbx], xmm0
    add         rbx, 32

.fm16:
    bt      rcx, 4
    jnc     .fm8

    vmovdqu     xmm0, [rdx + rbx]
    vmovdqu     [rdi + rbx], xmm0
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

    ; Write the final 1 to 63 bytes (xor).

.fx:
    add     rdi, r11
    add     rsi, r11
    xor     rbx, rbx

    bt      rcx, 5
    jnc     .fx16

    vmovdqu     xmm1, [rdx + rbx + 16]
    vmovdqu     xmm0, [rdx + rbx]
    vpxor       xmm1, xmm1, [rsi + rbx + 16]
    vpxor       xmm0, xmm0, [rsi + rbx]
    vmovdqu     [rdi + rbx + 16], xmm1
    vmovdqu     [rdi + rbx], xmm0
    add         rbx, 32

.fx16:
    bt      rcx, 4
    jnc     .fx8

    vmovdqu     xmm0, [rdx + rbx]
    vpxor       xmm0, xmm0, [rsi + rbx]
    vmovdqu     [rdi + rbx], xmm0
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

    ; And we're done.

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
