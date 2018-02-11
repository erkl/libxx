; Copyright (c) 2018, Erik Lundin.

    %include "src/x86-64/flags.inc"


    section .text align=64

    global  xx__cpuid


; This function collects processor feature information using the cpuid
; instruction. The findings are condensed to a series of bit flags.

xx__cpuid:
    xor     edi, edi
    xor     r8d, r8d
    mov     r9, rbx

    ; Find the highest supported cpuid leaf id. Also, try to recognize the
    ; vendor string.

    xor     eax, eax
    cpuid

    cmp     ebx, 0x756e6547     ; "Genu"
    jne     .a
    cmp     edx, 0x49656e69     ; "ineI"
    jne     .a
    cmp     ecx, 0x6c65746e     ; "ntel"
    jne     .a

    or      edi, VENDOR_INTEL
    jmp     .b

.a:
    cmp     ebx, 0x68747541     ; "Auth"
    jne     .b
    cmp     edx, 0x69746e65     ; "enti"
    jne     .b
    cmp     ecx, 0x444d4163     ; "cAMD"
    jne     .b

    or      edi, VENDOR_AMD

.b:
    test    eax, eax
    jz      .r
    cmp     eax, 7
    jb      .d

    ; Parse the 0x7 cpuid leaf.

.c:
    mov     eax, 7
    xor     ecx, ecx
    cpuid

    bt      ebx, 5
    lea     esi, [edi + HAVE_AVX2]
    cmovc   edi, esi
    bt      ebx, 16
    lea     esi, [edi + HAVE_AVX512F]
    cmovc   edi, esi
    bt      ebx, 31
    lea     esi, [edi + HAVE_AVX512VL]
    cmovc   edi, esi

    ; Parse the 0x1 cpuid leaf.

.d:
    mov     eax, 1
    cpuid

    bt      edx, 25
    lea     esi, [edi + HAVE_SSE]
    cmovc   edi, esi
    bt      edx, 26
    lea     esi, [edi + HAVE_SSE2]
    cmovc   edi, esi
    bt      ecx, 0
    lea     esi, [edi + HAVE_SSE3]
    cmovc   edi, esi
    bt      ecx, 9
    lea     esi, [edi + HAVE_SSSE3]
    cmovc   edi, esi
    bt      ecx, 19
    lea     esi, [edi + HAVE_SSE41]
    cmovc   edi, esi
    bt      ecx, 20
    lea     esi, [edi + HAVE_SSE42]
    cmovc   edi, esi
    bt      ecx, 25
    lea     esi, [edi + HAVE_AVX]
    cmovc   edi, esi

    ; If the xgetbv instruction is available, load the XCR0 value's lower
    ; 32 bits into r8d (overwriting its current zero value).

    bt      ecx, 26     ; xsave
    jnc     .e
    bt      ecx, 27     ; osxsave
    jnc     .e

    xor     ecx, ecx
    xgetbv

    mov     r8d, eax

    ; Check for AMD-specific features.

.e:
    mov     eax, 0x80000000
    cpuid

    cmp     eax, 0x80000001
    jb      .f

    mov     eax, 0x80000001
    cpuid

    bt      ecx, 6
    lea     esi, [edi + HAVE_SSE4A]
    cmovc   edi, esi
    bt      ecx, 11
    lea     esi, [edi + HAVE_XOP]
    cmovc   edi, esi

    ; We can't use VEX or EVEX instructions unless the kernel has set the
    ; necessary XSAVE extension bits in XCR0.

.f:
    and     r8d, 0xe6
    cmp     r8d, 0xe6
    je      .r

    and     edi, ~MASK_AVX512

    and     r8d, 0x06
    cmp     r8d, 0x06
    je      .r

    and     edi, ~MASK_AVX

    ; And we're done.

.r:
    mov     eax, edi
    mov     rbx, r9
    ret
