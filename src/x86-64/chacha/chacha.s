; Copyright (c) 2018, Erik Lundin.

    %include "src/x86-64/flags.inc"

    extern  xx__chacha_avx
    extern  xx__chacha_avx2
    extern  xx__chacha_sse2
    extern  xx__chacha_ssse3
    extern  xx__chacha_x64
    extern  xx__chacha_xop
    extern  xx__cpuid


    section .text align=64

    global  xx_chacha20_init
    global  xx_chacha20_seek
    global  xx_chacha20_xor


; Initialize a context struct using the given 256-bit key and 64-bit IV.

xx_chacha20_init:
    movdqa      xmm0, [rel sigma]
    movdqu      xmm1, [rsi]
    movdqu      [rdi], xmm0
    movdqu      [rdi + 16], xmm1

    movdqu      xmm2, [rsi + 16]
    movq        xmm3, [rdx]
    pshufd      xmm3, xmm3, 0x4e
    movdqu      [rdi + 32], xmm2
    movdqu      [rdi + 48], xmm3

    mov     byte [rdi + 128], 0
    ret


; Seek to a specific block counter + byte offset. This operation is lazy --
; we use a negative byte offset to signify the pending seek operation.

xx_chacha20_seek:
    mov     rax, rdx
    shr     rax, 6
    add     rsi, rax
    mov     [rdi + 48], rsi

    and     rdx, 63
    neg     rdx
    mov     [rdi + 128], dl
    ret


; Generate and output keystream data, optionally xor'd.

xx_chacha20_xor:
    test    rcx, rcx
    jz      .q

    mov     r8, rdi
    mov     rdi, rsi
    mov     rsi, rdx

    ; Branch off if we haven't picked a core function yet.

    mov     rax, [rel chacha]
    test    rax, rax
    jz      .s

    ; Load and check the context's offset field.

.i:
    movsx   r10, byte [r8 + 128]
    test    r10, r10
    js      .n
    jnz     .c

    ; Simple path: we're already aligned to a block boundary.

.j:
    mov     rdx, rcx
    and     rdx, 63
    mov     [r8 + 128], dl

    lea     rdx, [r8 + 64]
    mov     r9, 20
    jmp     rax

    ; Complex path: concretize a pending seek.

.n:
    push    rdi
    push    rsi
    push    rcx
    push    r8
    push    r10
    push    rax

    lea     rdi, [r8 + 64]
    xor     rsi, rsi
    mov     rcx, 64
    mov     r9, 20
    call    rax

    pop     rax
    pop     r10
    pop     r8
    pop     rcx
    pop     rsi
    pop     rdi

    neg     r10

    ; Use cached keystream data.

.c:
    mov     rdx, 64
    sub     rdx, r10
    cmp     rdx, rcx
    cmova   rdx, rcx

    lea     r10, [r8 + 64 + r10]
    xor     r11, r11

    test    rsi, rsi
    jnz     .cx

    ; Take up to 63 bytes from the cache (mov).

.cm:
    bt      rdx, 5
    jnc     .cm16

    movdqu      xmm1, [r10 + r11 + 16]
    movdqu      xmm0, [r10 + r11]
    movdqu      [rdi + r11 + 16], xmm1
    movdqu      [rdi + r11], xmm0
    add         r11, 32

.cm16:
    bt      rdx, 4
    jnc     .cm8

    movdqu      xmm0, [r10 + r11]
    movdqu      [rdi + r11], xmm0
    add         r11, 16

.cm8:
    bt      rdx, 3
    jnc     .cm4

    mov     r9, [r10 + r11]
    mov     [rdi + r11], r9
    add     r11, 8

.cm4:
    bt      rdx, 2
    jnc     .cm2

    mov     r9d, [r10 + r11]
    mov     [rdi + r11], r9d
    add     r11, 4

.cm2:
    bt      rdx, 1
    jnc     .cm1

    mov     r9w, [r10 + r11]
    mov     [rdi + r11], r9w
    add     r11, 2

.cm1:
    bt      rdx, 0
    jnc     .e

    mov     r9b, [r10 + r11]
    mov     [rdi + r11], r9b
    jmp     .e

    ; Take up to 63 bytes from the cache (xor).

.cx:
    bt      rdx, 5
    jnc     .cx16

    movdqu      xmm3, [r10 + r11 + 16]
    movdqu      xmm2, [r10 + r11]
    movdqu      xmm1, [rsi + r11 + 16]
    movdqu      xmm0, [rsi + r11]
    pxor        xmm1, xmm3
    pxor        xmm0, xmm2
    movdqu      [rdi + r11 + 16], xmm1
    movdqu      [rdi + r11], xmm0
    add         r11, 32

.cx16:
    bt      rdx, 4
    jnc     .cx8

    movdqu      xmm1, [r10 + r11]
    movdqu      xmm0, [rsi + r11]
    pxor        xmm0, xmm1
    movdqu      [rdi + r11], xmm0
    add         r11, 16

.cx8:
    bt      rdx, 3
    jnc     .cx4

    mov     r9, [r10 + r11]
    xor     r9, [rsi + r11]
    mov     [rdi + r11], r9
    add     r11, 8

.cx4:
    bt      rdx, 2
    jnc     .cx2

    mov     r9d, [r10 + r11]
    xor     r9d, [rsi + r11]
    mov     [rdi + r11], r9d
    add     r11, 4

.cx2:
    bt      rdx, 1
    jnc     .cx1

    mov     r9w, [r10 + r11]
    xor     r9w, [rsi + r11]
    mov     [rdi + r11], r9w
    add     r11, 2

.cx1:
    bt      rdx, 0
    jnc     .d

    mov     r9b, [r10 + r11]
    xor     r9b, [rsi + r11]
    mov     [rdi + r11], r9b

    ; Are we done or did we just run out of cached data?

.d:
    add     rsi, rdx
.e:
    add     rdi, rdx
    sub     rcx, rdx
    jnz     .j

    ; Commit the new byte offset and return.

    sub     r10, r8
    add     rdx, r10
    and     rdx, 63
    mov     [r8 + 128], dl

.q:
    ret

    ; Decide which core ChaCha function to use.

.s:
    push    rdi
    push    rsi
    push    rcx
    push    r8

    call    xx__select_chacha

    pop     r8
    pop     rcx
    pop     rsi
    pop     rdi

    mov     [rel chacha], rax
    jmp     .i


; Returns the best available core function given the instruction set extensions
; supported by the CPU.

xx__select_chacha:
    call    xx__cpuid

    ; AMD CPUs didn't get 128-bit wide SSE units until the K10 family, which
    ; introduced the SSE4a extension.

    test    eax, VENDOR_AMD
    jz      .d

    test    eax, HAVE_XOP
    jz      .a
    lea     rax, [rel xx__chacha_xop]
    ret

.a:
    test    eax, HAVE_AVX
    jz      .b
    lea     rax, [rel xx__chacha_avx]
    ret

.b:
    test    eax, HAVE_SSE4A
    jz      .c
    lea     rax, [rel xx__chacha_ssse3]
    ret

.c:
    lea     rax, [rel xx__chacha_x64]
    ret

    ; Intel SIMD didn't get fast enough until the Core family, which introduced
    ; the SSSE3 extension.

.d:
    test    eax, HAVE_AVX2
    jz      .e
    lea     rax, [rel xx__chacha_avx2]
    ret

.e:
    test    eax, HAVE_AVX
    jz      .f
    lea     rax, [rel xx__chacha_avx]
    ret

.f:
    test    eax, HAVE_SSSE3
    jz      .g
    lea     rax, [rel xx__chacha_ssse3]
    ret

.g:
    lea     rax, [rel xx__chacha_x64]
    ret


; Runtime-initialized core function pointer.

    section .data align=16

chacha:
    dq  0


; Initialization constant.

    section .rodata align=16

sigma:
    db  "expand 32-byte k"
