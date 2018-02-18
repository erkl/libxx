; Copyright (c) 2018, Erik Lundin.

    section .text align=64

    global  xx__chacha_x64


; The baseline x86-64 implementation of our core ChaCha function.

xx__chacha_x64:
    test    rcx, rcx
    jz      .q

    ; Spill just about every register.

    push    rbx
    push    rbp
    push    r12
    push    r13
    push    r14
    push    r15

    mov     rbp, rsp
    sub     rsp, 128
    and     rsp, ~64

    mov     [rsp + 16], rdi
    mov     [rsp + 24], rsi
    mov     [rsp + 32], rcx
    mov     [rsp + 40], rdx
    mov     [rsp + 48], rbp
    mov     [rsp + 56], r9

    ; Copy the input state, update its block counter.

    lea     r10, [rcx + 63]
    shr     r10, 6

    mov     rax, [r8 + 0]
    mov     rcx, [r8 + 8]
    mov     rdx, [r8 + 16]
    mov     rbx, [r8 + 24]
    mov     r12, [r8 + 32]
    mov     rbp, [r8 + 40]
    mov     rsi, [r8 + 48]
    mov     rdi, [r8 + 56]

    add     r10, rsi
    mov     [r8 + 48], r10

    mov     [rsp + 64], rax
    mov     [rsp + 72], rcx
    mov     [rsp + 80], rdx
    mov     [rsp + 88], rbx
    mov     [rsp + 96], r12
    mov     [rsp + 104], rbp
    mov     [rsp + 112], rsi
    mov     [rsp + 120], rdi

    ; Split 32-bit pairs into individual registers.

.l:
    mov     [rsp], r9

    mov     r8, rax
    mov     r9, rcx
    mov     r10, rdx
    mov     r11, rbx
    mov     [rsp + 8], r12d
    mov     r13, rbp
    mov     r14, rsi
    mov     r15, rdi

    shr     r8, 32
    shr     r9, 32
    shr     r10, 32
    shr     r11, 32
    shr     r12, 32
    shr     r13, 32
    shr     r14, 32
    shr     r15, 32

    ; Double-round loop.

.d:
    sub     qword [rsp], 2
    jc      .b

    add     r8d, r10d
    add     r9d, r11d
    xor     r14d, r8d
    xor     r15d, r9d
    rol     r14d, 16
    rol     r15d, 16
    add     r12d, r14d
    add     r13d, r15d
    xor     r10d, r12d
    xor     r11d, r13d
    rol     r10d, 12
    rol     r11d, 12
    add     r8d, r10d
    add     r9d, r11d
    xor     r14d, r8d
    xor     r15d, r9d
    rol     r14d, 8
    rol     r15d, 8
    add     r12d, r14d
    add     r13d, r15d
    xor     r10d, r12d
    xor     r11d, r13d
    rol     r10d, 7
    rol     r11d, 7

    mov     [rsp + 12], r12d
    mov     r12d, [rsp + 8]

    add     eax, edx
    add     ecx, ebx
    xor     esi, eax
    xor     edi, ecx
    rol     esi, 16
    rol     edi, 16
    add     r12d, esi
    add     ebp, edi
    xor     edx, r12d
    xor     ebx, ebp
    rol     edx, 12
    rol     ebx, 12
    add     eax, edx
    add     ecx, ebx
    xor     esi, eax
    xor     edi, ecx
    rol     esi, 8
    rol     edi, 8
    add     r12d, esi
    add     ebp, edi
    xor     edx, r12d
    xor     ebx, ebp
    rol     edx, 7
    rol     ebx, 7

    add     eax, r10d
    add     ecx, r11d
    xor     r15d, eax
    xor     r14d, ecx
    rol     r15d, 16
    rol     r14d, 16
    add     ebp, r15d
    add     r12d, r14d
    xor     r10d, ebp
    xor     r11d, r12d
    rol     r10d, 12
    rol     r11d, 12
    add     eax, r10d
    add     ecx, r11d
    xor     r15d, eax
    xor     r14d, ecx
    rol     r15d, 8
    rol     r14d, 8
    add     ebp, r15d
    add     r12d, r14d
    xor     r10d, ebp
    xor     r11d, r12d
    rol     r10d, 7
    rol     r11d, 7

    mov     [rsp + 8], r12d
    mov     r12d, [rsp + 12]

    add     r8d, ebx
    add     r9d, edx
    xor     esi, r8d
    xor     edi, r9d
    rol     esi, 16
    rol     edi, 16
    add     r13d, esi
    add     r12d, edi
    xor     ebx, r13d
    xor     edx, r12d
    rol     ebx, 12
    rol     edx, 12
    add     r8d, ebx
    add     r9d, edx
    xor     esi, r8d
    xor     edi, r9d
    rol     esi, 8
    rol     edi, 8
    add     r13d, esi
    add     r12d, edi
    xor     ebx, r13d
    xor     edx, r12d
    rol     ebx, 7
    rol     edx, 7

    jmp     .d

    ; Finish the batch and pair state fields again.

.b:
    add     eax, [rsp + 64]
    add     r8d, [rsp + 68]
    shl     r8, 32
    or      r8, rax

    add     ecx, [rsp + 72]
    add     r9d, [rsp + 76]
    shl     r9, 32
    or      r9, rcx

    add     edx, [rsp + 80]
    add     r10d, [rsp + 84]
    shl     r10, 32
    or      r10, rdx

    add     ebx, [rsp + 88]
    add     r11d, [rsp + 92]
    shl     r11, 32
    or      r11, rbx

    mov     eax, [rsp + 8]

    add     eax, [rsp + 96]
    add     r12d, [rsp + 100]
    shl     r12, 32
    or      r12, rax

    add     ebp, [rsp + 104]
    add     r13d, [rsp + 108]
    shl     r13, 32
    or      r13, rbp

    add     esi, [rsp + 112]
    add     r14d, [rsp + 116]
    shl     r14, 32
    or      r14, rsi

    add     edi, [rsp + 120]
    add     r15d, [rsp + 124]
    shl     r15, 32
    or      r15, rdi

    ; Reload the output parameters.

    mov     rdi, [rsp + 16]
    mov     rsi, [rsp + 24]
    mov     rcx, [rsp + 32]

    cmp     rcx, 64
    jb      .f

    ; Fast path: output a whole 64-byte keystream block.

    test    rsi, rsi
    jz      .n

    xor     r8, [rsi + 0]
    xor     r9, [rsi + 8]
    xor     r10, [rsi + 16]
    xor     r11, [rsi + 24]
    xor     r12, [rsi + 32]
    xor     r13, [rsi + 40]
    xor     r14, [rsi + 48]
    xor     r15, [rsi + 56]

    add     rsi, 64

.n:
    mov     [rdi + 0], r8
    mov     [rdi + 8], r9
    mov     [rdi + 16], r10
    mov     [rdi + 24], r11
    mov     [rdi + 32], r12
    mov     [rdi + 40], r13
    mov     [rdi + 48], r14
    mov     [rdi + 56], r15

    add     rdi, 64

    ; Prepare for the next block.

    sub     rcx, 64
    jz      .r

    mov     [rsp + 16], rdi
    mov     [rsp + 24], rsi
    mov     [rsp + 32], rcx

    mov     r9, [rsp + 56]

    mov     rax, [rsp + 64]
    mov     rcx, [rsp + 72]
    mov     rdx, [rsp + 80]
    mov     rbx, [rsp + 88]
    mov     r12, [rsp + 96]
    mov     rbp, [rsp + 104]
    mov     rsi, [rsp + 112]
    mov     rdi, [rsp + 120]

    inc     rsi
    mov     [rsp + 112], rsi

    jmp     .l

    ; Deal with partial final blocks.

.f:
    mov     rdx, [rsp + 40]
    test    rdx, rdx
    jz      .u

    mov     [rdx + 0], r8
    mov     [rdx + 8], r9
    mov     [rdx + 16], r10
    mov     [rdx + 24], r11
    mov     [rdx + 32], r12
    mov     [rdx + 40], r13
    mov     [rdx + 48], r14
    mov     [rdx + 56], r15

    ; Move the final 0 to 7 keystream bytes to r15.

.u:
    mov     rbx, rcx
    and     rbx, ~7
    shr     rbx, 1

    lea     rax, [rel .s]
    add     rax, rbx
    jmp     rax

.s:
    db  0x4d, 0x4d, 0x89, 0xc1      ;   mov    r9, r8
    db  0x4d, 0x4d, 0x89, 0xca      ;   mov    r10, r9
    db  0x4d, 0x4d, 0x89, 0xd3      ;   mov    r11, r10
    db  0x4d, 0x4d, 0x89, 0xdc      ;   mov    r12, r11
    db  0x4d, 0x4d, 0x89, 0xe5      ;   mov    r13, r12
    db  0x4d, 0x4d, 0x89, 0xee      ;   mov    r14, r13
    db  0x4d, 0x4d, 0x89, 0xf7      ;   mov    r15, r14

    test    rsi, rsi
    jnz     .x

    ; Write the final 1 to 63 bytes (mov).

.m:
    mov     rbx, rcx
    and     rbx, ~7
    shr     rbx, 1

    lea     rax, [rel .m4]
    sub     rax, rbx
    jmp     rax

    db  0x4c, 0x89, 0x77, 0x30      ;   mov     [rdi + 48], r14
    db  0x4c, 0x89, 0x6f, 0x28      ;   mov     [rdi + 40], r13
    db  0x4c, 0x89, 0x67, 0x20      ;   mov     [rdi + 32], r12
    db  0x4c, 0x89, 0x5f, 0x18      ;   mov     [rdi + 24], r11
    db  0x4c, 0x89, 0x57, 0x10      ;   mov     [rdi + 16], r10
    db  0x4c, 0x89, 0x4f, 0x08      ;   mov     [rdi + 8], r9
    db  0x4c, 0x89, 0x47, 0x00      ;   mov     [rdi + 0], r8

.m4:
    bt      rcx, 2
    jnc     .m2

    mov     [rdi + 2 * rbx], r15d
    shr     r15, 32
    add     rbx, 2

.m2:
    bt      rcx, 1
    jnc     .m1

    mov     [rdi + 2 * rbx], r15w
    shr     r15, 16
    inc     rbx

.m1:
    bt      rcx, 0
    jnc     .r

    mov     [rdi + 2 * rbx], r15b
    jmp     .r

    ; Write the final 1 to 63 bytes (xor).

.x:
    mov     rbx, rcx
    and     rbx, ~7

    lea     rax, [rel .x4]
    sub     rax, rbx
    jmp     rax

    db  0x4c, 0x33, 0x76, 0x30      ;   xor     r14, [rsi + 48]
    db  0x4c, 0x89, 0x77, 0x30      ;   mov     [rdi + 48], r14
    db  0x4c, 0x33, 0x6e, 0x28      ;   xor     r13, [rsi + 40]
    db  0x4c, 0x89, 0x6f, 0x28      ;   mov     [rdi + 40], r13
    db  0x4c, 0x33, 0x66, 0x20      ;   xor     r12, [rsi + 32]
    db  0x4c, 0x89, 0x67, 0x20      ;   mov     [rdi + 32], r12
    db  0x4c, 0x33, 0x5e, 0x18      ;   xor     r11, [rsi + 24]
    db  0x4c, 0x89, 0x5f, 0x18      ;   mov     [rdi + 24], r11
    db  0x4c, 0x33, 0x56, 0x10      ;   xor     r10, [rsi + 16]
    db  0x4c, 0x89, 0x57, 0x10      ;   mov     [rdi + 16], r10
    db  0x4c, 0x33, 0x4e, 0x08      ;   xor     r9, [rsi + 8]
    db  0x4c, 0x89, 0x4f, 0x08      ;   mov     [rdi + 8], r9
    db  0x4c, 0x33, 0x46, 0x00      ;   xor     r8, [rsi + 0]
    db  0x4c, 0x89, 0x47, 0x00      ;   mov     [rdi + 0], r8

.x4:
    bt      rcx, 2
    jnc     .x2

    mov     eax, [rsi + rbx]
    xor     eax, r15d
    mov     [rdi + rbx], eax
    add     rbx, 4
    shr     r15, 32

.x2:
    bt      rcx, 1
    jnc     .x1

    mov     ax, [rsi + rbx]
    xor     ax, r15w
    mov     [rdi + rbx], ax
    add     rbx, 2
    shr     r15, 16

.x1:
    bt      rcx, 0
    jnc     .r

    xor     r15b, [rsi + rbx]
    mov     [rdi + rbx], r15b

    ; Restore callee-saved registers.

.r:
    mov     rsp, [rsp + 48]

    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbp
    pop     rbx

.q:
    ret
