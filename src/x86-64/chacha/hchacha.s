; Copyright (c) 2018, Erik Lundin.

    %include "src/x86-64/flags.inc"

    extern  xx__hchacha_sse2
    extern  xx__hchacha_ssse3
    extern  xx__hchacha_x64
    extern  xx__hchacha_xop
    extern  xx__cpuid


    section .text align=64

    global  xx_hchacha20


; Calculate the HChaCha20 hash of the given 32-byte key and 16-byte IV.

xx_hchacha20:
    mov     rax, [rel hchacha]
    test    rax, rax
    jz      .s

.i:
    mov     rcx, 20
    jmp     rax

    ; Pick the best available HChaCHa core function.

.s:
    push    rdi
    push    rsi
    push    rdx

    call    xx__select_hchacha

    pop     rdx
    pop     rsi
    pop     rdi

    mov     [rel hchacha], rax
    jmp     .i


; Returns the best available core function given the instruction set extensions
; supported by the CPU.

xx__select_hchacha:
    call    xx__cpuid

    ; AMD CPUs didn't get 128-bit wide SSE units until the K10 family (which
    ; also introduced the SSE4a extension).

    test    eax, VENDOR_AMD
    jz      .c

    test    eax, HAVE_XOP
    jz      .a
    lea     rax, [rel xx__hchacha_xop]
    ret

.a:
    test    eax, HAVE_SSE4A
    jz      .b
    lea     rax, [rel xx__hchacha_ssse3]
    ret

.b:
    lea     rax, [rel xx__hchacha_x64]
    ret

    ; Intel SIMD didn't get fast enough until the Core family (which also
    ; introduced the SSSE3 extension).

.c:
    test    eax, HAVE_SSSE3
    jz      .d
    lea     rax, [rel xx__hchacha_ssse3]
    ret

.d:
    lea     rax, [rel xx__hchacha_x64]
    ret


; Runtime-initialized core function pointers.

    section .data align=16

hchacha:
    dq  0
