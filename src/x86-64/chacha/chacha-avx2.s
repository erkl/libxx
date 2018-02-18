; Copyright (c) 2018, Erik Lundin.

    section .text align=64

    global  xx__chacha_avx2


; An optimized implementation of our core ChaCha function, targeting the AVX2
; instruction set extension.

xx__chacha_avx2:
    push    rbx
    push    rbp
    mov     rbp, rsp
    and     rsp, ~63
    sub     rsp, 576

    lea     rax, [rsp + 64]
    test    rdx, rdx
    cmovz   rdx, rax

    lea     rbx, [rcx + 63]
    shr     rbx, 6
    and     rcx, 63

    test    rbx, rbx
    jz      .r
    cmp     rbx, 2
    jbe     .s
    cmp     rbx, 4
    jbe     .m

    ; One or more batches of 5 to 8 blocks each.

.l:
    vpbroadcastd    ymm0, [r8]
    vpbroadcastd    ymm1, [r8 + 4]
    vpbroadcastd    ymm2, [r8 + 8]
    vpbroadcastd    ymm3, [r8 + 12]
    vpbroadcastd    ymm4, [r8 + 16]
    vpbroadcastd    ymm5, [r8 + 20]
    vpbroadcastd    ymm6, [r8 + 24]
    vpbroadcastd    ymm7, [r8 + 28]
    vpbroadcastd    ymm8, [r8 + 32]
    vpbroadcastd    ymm9, [r8 + 36]
    vpbroadcastd    ymm10, [r8 + 40]
    vpbroadcastd    ymm11, [r8 + 44]
    vpbroadcastd    ymm12, [r8 + 48]
    vpbroadcastd    ymm13, [r8 + 52]
    vpbroadcastd    ymm14, [r8 + 56]
    vpbroadcastd    ymm15, [r8 + 60]

    vmovdqa     [rsp + 64], ymm0
    vmovdqa     [rsp + 96], ymm1
    vmovdqa     [rsp + 128], ymm2
    vmovdqa     [rsp + 160], ymm3
    vmovdqa     [rsp + 192], ymm4
    vmovdqa     [rsp + 224], ymm5
    vmovdqa     [rsp + 256], ymm6
    vmovdqa     [rsp + 288], ymm7
    vmovdqa     [rsp + 320], ymm8
    vmovdqa     [rsp + 352], ymm9
    vmovdqa     [rsp + 384], ymm10
    vmovdqa     [rsp + 416], ymm11
    vmovdqa     [rsp + 512], ymm14
    vmovdqa     [rsp + 544], ymm15

    mov     r10, [r8 + 48]
    jmp     .li

    ; Outer loop jump target.

.ll:
    vpbroadcastd    ymm0, [r8]
    vpbroadcastd    ymm1, [r8 + 4]
    vpbroadcastd    ymm2, [r8 + 8]
    vpbroadcastd    ymm3, [r8 + 12]
    vpbroadcastd    ymm4, [r8 + 16]
    vpbroadcastd    ymm5, [r8 + 20]
    vpbroadcastd    ymm6, [r8 + 24]
    vpbroadcastd    ymm7, [r8 + 28]
    vpbroadcastd    ymm8, [r8 + 32]
    vpbroadcastd    ymm9, [r8 + 36]
    vpbroadcastd    ymm10, [r8 + 40]
    vpbroadcastd    ymm11, [r8 + 44]
    vpbroadcastd    ymm12, [r8 + 48]
    vpbroadcastd    ymm13, [r8 + 52]
    vpbroadcastd    ymm14, [r8 + 56]
    vpbroadcastd    ymm15, [r8 + 60]

    ; Bump the block counter.

.li:
    mov     rax, 8
    cmp     rax, rbx
    cmova   rax, rbx

    mov     r11, r10
    add     r10, rax
    mov     [r8 + 48], r10

    ; Propagate block counter carries.

    cmp     r10d, eax
    jae     .la

    lea         rax, [rel k000000n1]
    add         r11d, 8
    vpaddd      ymm13, ymm13, [rax + 4 * r11]

.la:
    vpaddd      ymm12, ymm12, [rel k01234567]
    vmovdqa     [rsp + 448], ymm12
    vmovdqa     [rsp + 480], ymm13

    ; Double-round loop.

    mov     rax, r9

.lr:
    sub     rax, 2
    jc      .lb

    vpaddd      ymm0, ymm0, ymm4
    vpaddd      ymm1, ymm1, ymm5
    vpxor       ymm12, ymm12, ymm0
    vpxor       ymm13, ymm13, ymm1
    vpshufb     ymm12, ymm12, [rel rol16]
    vpshufb     ymm13, ymm13, [rel rol16]
    vpaddd      ymm2, ymm2, ymm6
    vpaddd      ymm3, ymm3, ymm7
    vpxor       ymm14, ymm14, ymm2
    vpxor       ymm15, ymm15, ymm3
    vpshufb     ymm14, ymm14, [rel rol16]
    vpshufb     ymm15, ymm15, [rel rol16]
    vmovdqa     [rsp], ymm0
    vmovdqa     [rsp + 32], ymm2
    vpaddd      ymm8, ymm8, ymm12
    vpaddd      ymm9, ymm9, ymm13
    vpxor       ymm4, ymm4, ymm8
    vpxor       ymm5, ymm5, ymm9
    vpslld      ymm0, ymm4, 12
    vpslld      ymm2, ymm5, 12
    vpsrld      ymm4, ymm4, 20
    vpsrld      ymm5, ymm5, 20
    vpxor       ymm4, ymm4, ymm0
    vpxor       ymm5, ymm5, ymm2
    vpaddd      ymm10, ymm10, ymm14
    vpaddd      ymm11, ymm11, ymm15
    vpxor       ymm6, ymm6, ymm10
    vpxor       ymm7, ymm7, ymm11
    vpslld      ymm0, ymm6, 12
    vpslld      ymm2, ymm7, 12
    vpsrld      ymm6, ymm6, 20
    vpsrld      ymm7, ymm7, 20
    vpxor       ymm6, ymm6, ymm0
    vpxor       ymm7, ymm7, ymm2
    vpaddd      ymm0, ymm4, [rsp]
    vpaddd      ymm1, ymm1, ymm5
    vpxor       ymm12, ymm12, ymm0
    vpxor       ymm13, ymm13, ymm1
    vpshufb     ymm12, ymm12, [rel rol8]
    vpshufb     ymm13, ymm13, [rel rol8]
    vpaddd      ymm2, ymm6, [rsp + 32]
    vpaddd      ymm3, ymm3, ymm7
    vpxor       ymm14, ymm14, ymm2
    vpxor       ymm15, ymm15, ymm3
    vpshufb     ymm14, ymm14, [rel rol8]
    vpshufb     ymm15, ymm15, [rel rol8]
    vmovdqa     [rsp], ymm2
    vpaddd      ymm8, ymm8, ymm12
    vpaddd      ymm9, ymm9, ymm13
    vpxor       ymm4, ymm4, ymm8
    vpxor       ymm5, ymm5, ymm9
    vpslld      ymm2, ymm4, 7
    vpsrld      ymm4, ymm4, 25
    vpxor       ymm4, ymm4, ymm2
    vpslld      ymm2, ymm5, 7
    vpsrld      ymm5, ymm5, 25
    vpxor       ymm5, ymm5, ymm2
    vpaddd      ymm10, ymm10, ymm14
    vpaddd      ymm11, ymm11, ymm15
    vpxor       ymm6, ymm6, ymm10
    vpxor       ymm7, ymm7, ymm11
    vpslld      ymm2, ymm6, 7
    vpsrld      ymm6, ymm6, 25
    vpxor       ymm6, ymm6, ymm2
    vpslld      ymm2, ymm7, 7
    vpsrld      ymm7, ymm7, 25
    vpxor       ymm7, ymm7, ymm2

    vpaddd      ymm0, ymm0, ymm5
    vpaddd      ymm3, ymm3, ymm4
    vpxor       ymm15, ymm15, ymm0
    vpxor       ymm14, ymm14, ymm3
    vpshufb     ymm15, ymm15, [rel rol16]
    vpshufb     ymm14, ymm14, [rel rol16]
    vpaddd      ymm1, ymm1, ymm6
    vpaddd      ymm2, ymm7, [rsp]
    vpxor       ymm12, ymm12, ymm1
    vpxor       ymm13, ymm13, ymm2
    vpshufb     ymm12, ymm12, [rel rol16]
    vpshufb     ymm13, ymm13, [rel rol16]
    vmovdqa     [rsp], ymm0
    vmovdqa     [rsp + 32], ymm2
    vpaddd      ymm10, ymm10, ymm15
    vpaddd      ymm9, ymm9, ymm14
    vpxor       ymm5, ymm5, ymm10
    vpxor       ymm4, ymm4, ymm9
    vpslld      ymm0, ymm5, 12
    vpslld      ymm2, ymm4, 12
    vpsrld      ymm5, ymm5, 20
    vpsrld      ymm4, ymm4, 20
    vpxor       ymm5, ymm5, ymm0
    vpxor       ymm4, ymm4, ymm2
    vpaddd      ymm11, ymm11, ymm12
    vpaddd      ymm8, ymm8, ymm13
    vpxor       ymm6, ymm6, ymm11
    vpxor       ymm7, ymm7, ymm8
    vpslld      ymm0, ymm6, 12
    vpslld      ymm2, ymm7, 12
    vpsrld      ymm6, ymm6, 20
    vpsrld      ymm7, ymm7, 20
    vpxor       ymm6, ymm6, ymm0
    vpxor       ymm7, ymm7, ymm2
    vpaddd      ymm0, ymm5, [rsp]
    vpaddd      ymm3, ymm3, ymm4
    vpxor       ymm15, ymm15, ymm0
    vpxor       ymm14, ymm14, ymm3
    vpshufb     ymm15, ymm15, [rel rol8]
    vpshufb     ymm14, ymm14, [rel rol8]
    vpaddd      ymm1, ymm1, ymm6
    vpaddd      ymm2, ymm7, [rsp + 32]
    vpxor       ymm12, ymm12, ymm1
    vpxor       ymm13, ymm13, ymm2
    vpshufb     ymm12, ymm12, [rel rol8]
    vpshufb     ymm13, ymm13, [rel rol8]
    vmovdqa     [rsp], ymm2
    vpaddd      ymm10, ymm10, ymm15
    vpaddd      ymm9, ymm9, ymm14
    vpxor       ymm5, ymm5, ymm10
    vpxor       ymm4, ymm4, ymm9
    vpslld      ymm2, ymm5, 7
    vpsrld      ymm5, ymm5, 25
    vpxor       ymm5, ymm5, ymm2
    vpslld      ymm2, ymm4, 7
    vpsrld      ymm4, ymm4, 25
    vpxor       ymm4, ymm4, ymm2
    vpaddd      ymm11, ymm11, ymm12
    vpaddd      ymm8, ymm8, ymm13
    vpxor       ymm6, ymm6, ymm11
    vpxor       ymm7, ymm7, ymm8
    vpslld      ymm2, ymm6, 7
    vpsrld      ymm6, ymm6, 25
    vpxor       ymm6, ymm6, ymm2
    vpslld      ymm2, ymm7, 7
    vpsrld      ymm7, ymm7, 25
    vpxor       ymm7, ymm7, ymm2
    vmovdqa     ymm2, [rsp]

    jmp     .lr

    ; Finish and transpose this batch.

.lb:
    vmovdqa     [rsp], ymm14
    vmovdqa     [rsp + 32], ymm15

    vpaddd          ymm0, ymm0, [rsp + 64]
    vpaddd          ymm1, ymm1, [rsp + 96]
    vpunpckldq      ymm14, ymm0, ymm1
    vpunpckhdq      ymm1, ymm0, ymm1
    vpaddd          ymm2, ymm2, [rsp + 128]
    vpaddd          ymm3, ymm3, [rsp + 160]
    vpunpckhdq      ymm15, ymm2, ymm3
    vpunpckldq      ymm2, ymm2, ymm3
    vpunpcklqdq     ymm0, ymm14, ymm2
    vpunpckhqdq     ymm2, ymm14, ymm2
    vpunpckhqdq     ymm3, ymm1, ymm15
    vpunpcklqdq     ymm1, ymm1, ymm15
    vpaddd          ymm4, ymm4, [rsp + 192]
    vpaddd          ymm5, ymm5, [rsp + 224]
    vpunpckldq      ymm14, ymm4, ymm5
    vpunpckhdq      ymm5, ymm4, ymm5
    vpaddd          ymm6, ymm6, [rsp + 256]
    vpaddd          ymm7, ymm7, [rsp + 288]
    vpunpckhdq      ymm15, ymm6, ymm7
    vpunpckldq      ymm6, ymm6, ymm7
    vpunpcklqdq     ymm4, ymm14, ymm6
    vpunpckhqdq     ymm6, ymm14, ymm6
    vpunpckhqdq     ymm7, ymm5, ymm15
    vpunpcklqdq     ymm5, ymm5, ymm15

    vmovdqa     ymm14, [rsp]
    vmovdqa     ymm15, [rsp + 32]
    vmovdqa     [rsp], ymm6
    vmovdqa     [rsp + 32], ymm7

    vpaddd          ymm8, ymm8, [rsp + 320]
    vpaddd          ymm9, ymm9, [rsp + 352]
    vpunpckldq      ymm6, ymm8, ymm9
    vpunpckhdq      ymm9, ymm8, ymm9
    vpaddd          ymm10, ymm10, [rsp + 384]
    vpaddd          ymm11, ymm11, [rsp + 416]
    vpunpckhdq      ymm7, ymm10, ymm11
    vpunpckldq      ymm10, ymm10, ymm11
    vpunpcklqdq     ymm8, ymm6, ymm10
    vpunpckhqdq     ymm10, ymm6, ymm10
    vpunpckhqdq     ymm11, ymm9, ymm7
    vpunpcklqdq     ymm9, ymm9, ymm7
    vpaddd          ymm12, ymm12, [rsp + 448]
    vpaddd          ymm13, ymm13, [rsp + 480]
    vpunpckldq      ymm6, ymm12, ymm13
    vpunpckhdq      ymm13, ymm12, ymm13
    vpaddd          ymm14, ymm14, [rsp + 512]
    vpaddd          ymm15, ymm15, [rsp + 544]
    vpunpckhdq      ymm7, ymm14, ymm15
    vpunpckldq      ymm14, ymm14, ymm15
    vpunpcklqdq     ymm12, ymm6, ymm14
    vpunpckhqdq     ymm14, ymm6, ymm14
    vpunpckhqdq     ymm15, ymm13, ymm7
    vpunpcklqdq     ymm13, ymm13, ymm7

    ; Skip branch conditions that only apply to the final batch.

    cmp     rbx, 8
    jbe     .lf

    test    rsi, rsi
    jnz     .lx8
    jmp     .lm8

.lf:
    test    rcx, rcx
    jnz     .ls
    test    rsi, rsi
    jnz     .lx
    jmp     .lm

    ; Spill the last block to [rdx].

.ls:
    cmp     rbx, 6
    jb      .ls5
    je      .ls6
    cmp     rbx, 8
    jb      .ls7

.ls8:
    vperm2i128      ymm7, ymm11, ymm15, 0x31
    vperm2i128      ymm6, ymm3, [rsp + 32], 0x31
    vmovdqu         [rdx + 32], ymm7
    vmovdqu         [rdx], ymm6

    mov     r11, 448
    test    rsi, rsi
    jnz     .lx7
    jmp     .lm7

.ls7:
    vperm2i128      ymm7, ymm9, ymm13, 0x31
    vperm2i128      ymm6, ymm1, ymm5, 0x31
    vmovdqu         [rdx + 32], ymm7
    vmovdqu         [rdx], ymm6

    mov     r11, 384
    test    rsi, rsi
    jnz     .lx6
    jmp     .lm6

.ls6:
    vperm2i128      ymm7, ymm10, ymm14, 0x31
    vperm2i128      ymm6, ymm2, [rsp], 0x31
    vmovdqu         [rdx + 32], ymm7
    vmovdqu         [rdx], ymm6

    mov     r11, 320
    test    rsi, rsi
    jnz     .lx5
    jmp     .lm5

.ls5:
    vperm2i128      ymm7, ymm8, ymm12, 0x31
    vperm2i128      ymm6, ymm0, ymm4, 0x31
    vmovdqu         [rdx + 32], ymm7
    vmovdqu         [rdx], ymm6

    mov     r11, 256
    test    rsi, rsi
    jnz     .lx4
    jmp     .lm4

    ; Write 5 to 8 whole blocks (mov).

.lm:
    cmp     rbx, 6
    jb      .lm5
    je      .lm6
    cmp     rbx, 8
    jb      .lm7

.lm8:
    vperm2i128      ymm7, ymm11, ymm15, 0x31
    vperm2i128      ymm6, ymm3, [rsp + 32], 0x31
    vmovdqu         [rdi + 480], ymm7
    vmovdqu         [rdi + 448], ymm6
.lm7:
    vperm2i128      ymm7, ymm9, ymm13, 0x31
    vperm2i128      ymm6, ymm1, ymm5, 0x31
    vmovdqu         [rdi + 416], ymm7
    vmovdqu         [rdi + 384], ymm6
.lm6:
    vperm2i128      ymm7, ymm10, ymm14, 0x31
    vperm2i128      ymm6, ymm2, [rsp], 0x31
    vmovdqu         [rdi + 352], ymm7
    vmovdqu         [rdi + 320], ymm6
.lm5:
    vperm2i128      ymm7, ymm8, ymm12, 0x31
    vperm2i128      ymm6, ymm0, ymm4, 0x31
    vmovdqu         [rdi + 288], ymm7
    vmovdqu         [rdi + 256], ymm6
.lm4:
    vperm2i128      ymm7, ymm11, ymm15, 0x20
    vperm2i128      ymm6, ymm3, [rsp + 32], 0x20
    vmovdqu         [rdi + 224], ymm7
    vmovdqu         [rdi + 192], ymm6
.lm3:
    vperm2i128      ymm7, ymm9, ymm13, 0x20
    vperm2i128      ymm6, ymm1, ymm5, 0x20
    vmovdqu         [rdi + 160], ymm7
    vmovdqu         [rdi + 128], ymm6
.lm2:
    vperm2i128      ymm7, ymm10, ymm14, 0x20
    vperm2i128      ymm6, ymm2, [rsp], 0x20
    vmovdqu         [rdi + 96], ymm7
    vmovdqu         [rdi + 64], ymm6
.lm1:
    vperm2i128      ymm7, ymm8, ymm12, 0x20
    vperm2i128      ymm6, ymm0, ymm4, 0x20
    vmovdqu         [rdi + 32], ymm7
    vmovdqu         [rdi], ymm6

    cmp     rbx, 8
    jbe     .f

    add     rdi, 512
    sub     rbx, 8

    cmp     rbx, 4
    ja      .ll
    cmp     rbx, 2
    ja      .m
    jmp     .s

    ; Write 5 to 8 whole blocks (xor).

.lx:
    cmp     rbx, 6
    jb      .lx5
    je      .lx6
    cmp     rbx, 8
    jb      .lx7

.lx8:
    vperm2i128      ymm7, ymm11, ymm15, 0x31
    vperm2i128      ymm6, ymm3, [rsp + 32], 0x31
    vpxor           ymm7, ymm7, [rsi + 480]
    vpxor           ymm6, ymm6, [rsi + 448]
    vmovdqu         [rdi + 480], ymm7
    vmovdqu         [rdi + 448], ymm6
.lx7:
    vperm2i128      ymm7, ymm9, ymm13, 0x31
    vperm2i128      ymm6, ymm1, ymm5, 0x31
    vpxor           ymm7, ymm7, [rsi + 416]
    vpxor           ymm6, ymm6, [rsi + 384]
    vmovdqu         [rdi + 416], ymm7
    vmovdqu         [rdi + 384], ymm6
.lx6:
    vperm2i128      ymm7, ymm10, ymm14, 0x31
    vperm2i128      ymm6, ymm2, [rsp], 0x31
    vpxor           ymm7, ymm7, [rsi + 352]
    vpxor           ymm6, ymm6, [rsi + 320]
    vmovdqu         [rdi + 352], ymm7
    vmovdqu         [rdi + 320], ymm6
.lx5:
    vperm2i128      ymm7, ymm8, ymm12, 0x31
    vperm2i128      ymm6, ymm0, ymm4, 0x31
    vpxor           ymm7, ymm7, [rsi + 288]
    vpxor           ymm6, ymm6, [rsi + 256]
    vmovdqu         [rdi + 288], ymm7
    vmovdqu         [rdi + 256], ymm6
.lx4:
    vperm2i128      ymm7, ymm11, ymm15, 0x20
    vperm2i128      ymm6, ymm3, [rsp + 32], 0x20
    vpxor           ymm7, ymm7, [rsi + 224]
    vpxor           ymm6, ymm6, [rsi + 192]
    vmovdqu         [rdi + 224], ymm7
    vmovdqu         [rdi + 192], ymm6
.lx3:
    vperm2i128      ymm7, ymm9, ymm13, 0x20
    vperm2i128      ymm6, ymm1, ymm5, 0x20
    vpxor           ymm7, ymm7, [rsi + 160]
    vpxor           ymm6, ymm6, [rsi + 128]
    vmovdqu         [rdi + 160], ymm7
    vmovdqu         [rdi + 128], ymm6
.lx2:
    vperm2i128      ymm7, ymm10, ymm14, 0x20
    vperm2i128      ymm6, ymm2, [rsp], 0x20
    vpxor           ymm7, ymm7, [rsi + 96]
    vpxor           ymm6, ymm6, [rsi + 64]
    vmovdqu         [rdi + 96], ymm7
    vmovdqu         [rdi + 64], ymm6
.lx1:
    vperm2i128      ymm7, ymm8, ymm12, 0x20
    vperm2i128      ymm6, ymm0, ymm4, 0x20
    vpxor           ymm7, ymm7, [rsi + 32]
    vpxor           ymm6, ymm6, [rsi]
    vmovdqu         [rdi + 32], ymm7
    vmovdqu         [rdi], ymm6

    cmp     rbx, 8
    jbe     .f

    add     rdi, 512
    add     rsi, 512
    sub     rbx, 8

    cmp     rbx, 4
    ja      .ll
    cmp     rbx, 2
    ja      .m

    ; One batch of 1 or 2 blocks.

.s:
    vbroadcasti128    ymm10, [r8]
    vbroadcasti128    ymm11, [r8 + 16]
    vbroadcasti128    ymm12, [r8 + 32]
    vbroadcasti128    ymm13, [r8 + 48]

    vpaddq      ymm13, ymm13, [rel k00001000]

    vmovdqa     ymm0, ymm10
    vmovdqa     ymm1, ymm11
    vmovdqa     ymm2, ymm12
    vmovdqa     ymm3, ymm13

    ; Bump the block counter.

    add     [r8 + 48], rbx

    ; Double-round loop.

.sr:
    sub     r9, 2
    jc      .sb

    vpaddd      ymm0, ymm0, ymm1
    vpxor       ymm3, ymm3, ymm0
    vpshufb     ymm3, ymm3, [rel rol16]
    vpaddd      ymm2, ymm2, ymm3
    vpxor       ymm1, ymm1, ymm2
    vpslld      ymm8, ymm1, 12
    vpsrld      ymm1, ymm1, 20
    vpxor       ymm1, ymm1, ymm8
    vpaddd      ymm0, ymm0, ymm1
    vpxor       ymm3, ymm3, ymm0
    vpshufb     ymm3, ymm3, [rel rol8]
    vpaddd      ymm2, ymm2, ymm3
    vpxor       ymm1, ymm1, ymm2
    vpslld      ymm8, ymm1, 7
    vpsrld      ymm1, ymm1, 25
    vpxor       ymm1, ymm1, ymm8
    vpshufd     ymm0, ymm0, 0x93
    vpshufd     ymm2, ymm2, 0x39
    vpshufd     ymm3, ymm3, 0x4e

    vpaddd      ymm0, ymm0, ymm1
    vpxor       ymm3, ymm3, ymm0
    vpshufb     ymm3, ymm3, [rel rol16]
    vpaddd      ymm2, ymm2, ymm3
    vpxor       ymm1, ymm1, ymm2
    vpslld      ymm8, ymm1, 12
    vpsrld      ymm1, ymm1, 20
    vpxor       ymm1, ymm1, ymm8
    vpaddd      ymm0, ymm0, ymm1
    vpxor       ymm3, ymm3, ymm0
    vpshufb     ymm3, ymm3, [rel rol8]
    vpaddd      ymm2, ymm2, ymm3
    vpxor       ymm1, ymm1, ymm2
    vpslld      ymm8, ymm1, 7
    vpsrld      ymm1, ymm1, 25
    vpxor       ymm1, ymm1, ymm8
    vpshufd     ymm0, ymm0, 0x39
    vpshufd     ymm2, ymm2, 0x93
    vpshufd     ymm3, ymm3, 0x4e

    jmp     .sr

    ; Finish the batch.

.sb:
    vpaddd      ymm0, ymm0, ymm10
    vpaddd      ymm1, ymm1, ymm11
    vpaddd      ymm2, ymm2, ymm12
    vpaddd      ymm3, ymm3, ymm13

    ; Reuse the .m path's output code.

    test    rcx, rcx
    jnz     .ss
    test    rsi, rsi
    jnz     .sx
    jmp     .sm

.ss:
    cmp     rbx, 2
    jb      .ms1
    jmp     .ms2

.sm:
    cmp     rbx, 2
    jb      .mm1
    jmp     .mm2

.sx:
    cmp     rbx, 2
    jb      .mx1
    jmp     .mx2

    ; One batch of 3 or 4 blocks.

.m:
    vbroadcasti128    ymm10, [r8]
    vbroadcasti128    ymm11, [r8 + 16]
    vbroadcasti128    ymm12, [r8 + 32]
    vbroadcasti128    ymm14, [r8 + 48]

    vpaddq      ymm13, ymm14, [rel k00001000]
    vpaddq      ymm14, ymm14, [rel k20003000]

    vmovdqa     ymm0, ymm10
    vmovdqa     ymm1, ymm11
    vmovdqa     ymm2, ymm12
    vmovdqa     ymm3, ymm13
    vmovdqa     ymm4, ymm10
    vmovdqa     ymm5, ymm11
    vmovdqa     ymm6, ymm12
    vmovdqa     ymm7, ymm14

    ; Bump the block counter.

    add     [r8 + 48], rbx

    ; Double-round loop.

.mr:
    sub     r9, 2
    jc      .mb

    vpaddd      ymm0, ymm0, ymm1
    vpaddd      ymm4, ymm4, ymm5
    vpxor       ymm3, ymm3, ymm0
    vpxor       ymm7, ymm7, ymm4
    vpshufb     ymm3, ymm3, [rel rol16]
    vpshufb     ymm7, ymm7, [rel rol16]
    vpaddd      ymm2, ymm2, ymm3
    vpaddd      ymm6, ymm6, ymm7
    vpxor       ymm1, ymm1, ymm2
    vpxor       ymm5, ymm5, ymm6
    vpslld      ymm8, ymm1, 12
    vpsrld      ymm1, ymm1, 20
    vpslld      ymm9, ymm5, 12
    vpsrld      ymm5, ymm5, 20
    vpxor       ymm1, ymm1, ymm8
    vpxor       ymm5, ymm5, ymm9
    vpaddd      ymm0, ymm0, ymm1
    vpaddd      ymm4, ymm4, ymm5
    vpxor       ymm3, ymm3, ymm0
    vpxor       ymm7, ymm7, ymm4
    vpshufb     ymm3, ymm3, [rel rol8]
    vpshufb     ymm7, ymm7, [rel rol8]
    vpaddd      ymm2, ymm2, ymm3
    vpaddd      ymm6, ymm6, ymm7
    vpxor       ymm1, ymm1, ymm2
    vpxor       ymm5, ymm5, ymm6
    vpshufd     ymm0, ymm0, 0x93
    vpshufd     ymm4, ymm4, 0x93
    vpslld      ymm8, ymm1, 7
    vpsrld      ymm1, ymm1, 25
    vpshufd     ymm2, ymm2, 0x39
    vpshufd     ymm6, ymm6, 0x39
    vpslld      ymm9, ymm5, 7
    vpsrld      ymm5, ymm5, 25
    vpshufd     ymm3, ymm3, 0x4e
    vpshufd     ymm7, ymm7, 0x4e
    vpxor       ymm1, ymm1, ymm8
    vpxor       ymm5, ymm5, ymm9

    vpaddd      ymm0, ymm0, ymm1
    vpaddd      ymm4, ymm4, ymm5
    vpxor       ymm3, ymm3, ymm0
    vpxor       ymm7, ymm7, ymm4
    vpshufb     ymm3, ymm3, [rel rol16]
    vpshufb     ymm7, ymm7, [rel rol16]
    vpaddd      ymm2, ymm2, ymm3
    vpaddd      ymm6, ymm6, ymm7
    vpxor       ymm1, ymm1, ymm2
    vpxor       ymm5, ymm5, ymm6
    vpslld      ymm8, ymm1, 12
    vpsrld      ymm1, ymm1, 20
    vpslld      ymm9, ymm5, 12
    vpsrld      ymm5, ymm5, 20
    vpxor       ymm1, ymm1, ymm8
    vpxor       ymm5, ymm5, ymm9
    vpaddd      ymm0, ymm0, ymm1
    vpaddd      ymm4, ymm4, ymm5
    vpxor       ymm3, ymm3, ymm0
    vpxor       ymm7, ymm7, ymm4
    vpshufb     ymm3, ymm3, [rel rol8]
    vpshufb     ymm7, ymm7, [rel rol8]
    vpaddd      ymm2, ymm2, ymm3
    vpaddd      ymm6, ymm6, ymm7
    vpxor       ymm1, ymm1, ymm2
    vpxor       ymm5, ymm5, ymm6
    vpshufd     ymm0, ymm0, 0x39
    vpshufd     ymm4, ymm4, 0x39
    vpslld      ymm8, ymm1, 7
    vpsrld      ymm1, ymm1, 25
    vpshufd     ymm2, ymm2, 0x93
    vpshufd     ymm6, ymm6, 0x93
    vpslld      ymm9, ymm5, 7
    vpsrld      ymm5, ymm5, 25
    vpshufd     ymm3, ymm3, 0x4e
    vpshufd     ymm7, ymm7, 0x4e
    vpxor       ymm1, ymm1, ymm8
    vpxor       ymm5, ymm5, ymm9

    jmp     .mr

    ; Finish the batch.

.mb:
    vpaddd      ymm0, ymm0, ymm10
    vpaddd      ymm1, ymm1, ymm11
    vpaddd      ymm2, ymm2, ymm12
    vpaddd      ymm3, ymm3, ymm13
    vpaddd      ymm4, ymm4, ymm10
    vpaddd      ymm5, ymm5, ymm11
    vpaddd      ymm6, ymm6, ymm12
    vpaddd      ymm7, ymm7, ymm14

    test    rcx, rcx
    jnz     .ms
    test    rsi, rsi
    jnz     .mx
    jmp     .mm

    ; Spill the last block to [rdx].

.ms:
    cmp     rbx, 4
    jb      .ms3

.ms4:
    vperm2i128      ymm9, ymm6, ymm7, 0x31
    vperm2i128      ymm8, ymm4, ymm5, 0x31
    vmovdqu         [rdx + 32], ymm9
    vmovdqu         [rdx], ymm8

    mov     r11, 192
    test    rsi, rsi
    jnz     .mx3
    jmp     .mm3

.ms3:
    vperm2i128      ymm9, ymm6, ymm7, 0x20
    vperm2i128      ymm8, ymm4, ymm5, 0x20
    vmovdqu         [rdx + 32], ymm9
    vmovdqu         [rdx], ymm8

    mov     r11, 128
    test    rsi, rsi
    jnz     .mx2
    jmp     .mm2

.ms2:
    vperm2i128      ymm9, ymm2, ymm3, 0x31
    vperm2i128      ymm8, ymm0, ymm1, 0x31
    vmovdqu         [rdx + 32], ymm9
    vmovdqu         [rdx], ymm8

    mov     r11, 64
    test    rsi, rsi
    jnz     .mx1
    jmp     .mm1

.ms1:
    vperm2i128      ymm9, ymm2, ymm3, 0x20
    vperm2i128      ymm8, ymm0, ymm1, 0x20
    vmovdqu         [rdx + 32], ymm9
    vmovdqu         [rdx], ymm8

    xor     r11, r11
    jmp     .f

    ; Write 1 to 4 whole blocks (mov).

.mm:
    cmp     rbx, 4
    jb      .mm3

.mm4:
    vperm2i128      ymm9, ymm6, ymm7, 0x31
    vperm2i128      ymm8, ymm4, ymm5, 0x31
    vmovdqu         [rdi + 224], ymm9
    vmovdqu         [rdi + 192], ymm8
.mm3:
    vperm2i128      ymm9, ymm6, ymm7, 0x20
    vperm2i128      ymm8, ymm4, ymm5, 0x20
    vmovdqu         [rdi + 160], ymm9
    vmovdqu         [rdi + 128], ymm8
.mm2:
    vperm2i128      ymm9, ymm2, ymm3, 0x31
    vperm2i128      ymm8, ymm0, ymm1, 0x31
    vmovdqu         [rdi + 96], ymm9
    vmovdqu         [rdi + 64], ymm8
.mm1:
    vperm2i128      ymm9, ymm2, ymm3, 0x20
    vperm2i128      ymm8, ymm0, ymm1, 0x20
    vmovdqu         [rdi + 32], ymm9
    vmovdqu         [rdi], ymm8

    jmp     .f

    ; Write 1 to 4 whole blocks (xor).

.mx:
    cmp     rbx, 4
    jb      .mx3

.mx4:
    vperm2i128      ymm9, ymm6, ymm7, 0x31
    vperm2i128      ymm8, ymm4, ymm5, 0x31
    vpxor           ymm9, ymm9, [rsi + 224]
    vpxor           ymm8, ymm8, [rsi + 192]
    vmovdqu         [rdi + 224], ymm9
    vmovdqu         [rdi + 192], ymm8
.mx3:
    vperm2i128      ymm9, ymm6, ymm7, 0x20
    vperm2i128      ymm8, ymm4, ymm5, 0x20
    vpxor           ymm9, ymm9, [rsi + 160]
    vpxor           ymm8, ymm8, [rsi + 128]
    vmovdqu         [rdi + 160], ymm9
    vmovdqu         [rdi + 128], ymm8
.mx2:
    vperm2i128      ymm9, ymm2, ymm3, 0x31
    vperm2i128      ymm8, ymm0, ymm1, 0x31
    vpxor           ymm9, ymm9, [rsi + 96]
    vpxor           ymm8, ymm8, [rsi + 64]
    vmovdqu         [rdi + 96], ymm9
    vmovdqu         [rdi + 64], ymm8
.mx1:
    vperm2i128      ymm9, ymm2, ymm3, 0x20
    vperm2i128      ymm8, ymm0, ymm1, 0x20
    vpxor           ymm9, ymm9, [rsi + 32]
    vpxor           ymm8, ymm8, [rsi]
    vmovdqu         [rdi + 32], ymm9
    vmovdqu         [rdi], ymm8

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

    vmovdqu     ymm0, [rdx + rbx]
    vmovdqu     [rdi + rbx], ymm0
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

    vmovdqu     ymm0, [rdx + rbx]
    vpxor       ymm0, ymm0, [rsi + rbx]
    vmovdqu     [rdi + rbx], ymm0
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
    vzeroupper

    mov     rsp, rbp
    pop     rbp
    pop     rbx
    ret


    section .rodata
    align   128
    times   96 db 0

k01234567:
    dd  0, 1, 2, 3, 4, 5, 6, 7

k000000n1:
    dd  0, 0, 0, 0, 0, 0, 0, 0
    dd  1, 1, 1, 1, 1, 1, 1, 1

k00001000:
    dd  0, 0, 0, 0, 1, 0, 0, 0

k20003000:
    dd  2, 0, 0, 0, 3, 0, 0, 0

rol8:
    db   3,  0,  1,  2,  7,  4,  5,  6
    db  11,  8,  9, 10, 15, 12, 13, 14
    db  19, 16, 17, 18, 23, 20, 21, 22
    db  27, 24, 25, 26, 31, 28, 29, 30

rol16:
    db   2,  3,  0,  1,  6,  7,  4,  5
    db  10, 11,  8,  9, 14, 15, 12, 13
    db  18, 19, 16, 17, 22, 23, 20, 21
    db  26, 27, 24, 25, 30, 31, 28, 29
