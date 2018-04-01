; Copyright (c) 2018, Erik Lundin.

    section .text align=64

    global  xx__hchacha_x64


; The baseline x86-64 implementation of our core HChaCha function.

xx__hchacha_x64:
    push    rbx
    push    rbp
    push    r12
    push    r13
    push    r14
    push    r15

    sub     rsp, 24
    mov     [rsp + 16], rdi
    mov     [rsp], rcx

    ; Initialize working state.

    mov     eax, 0x61707865  ; "expa"
    mov     r8d, 0x3320646e  ; "nd 3"
    mov     ecx, 0x79622d32  ; "2-by"
    mov     r9d, 0x6b206574  ; "te k"

    mov     r10, [rsi]
    mov     r11, [rsi + 8]
    mov     r12, [rsi + 16]
    mov     r13, [rsi + 24]
    mov     r14, [rdx]
    mov     r15, [rdx + 8]

    mov     rdx, r10
    mov     rbx, r11
    mov     [rsp + 8], r12d
    mov     rbp, r13
    mov     rsi, r14
    mov     rdi, r15

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
    rol     r14d, 16
    xor     r15d, r9d
    rol     r15d, 16
    add     r12d, r14d
    add     r13d, r15d
    xor     r10d, r12d
    rol     r10d, 12
    xor     r11d, r13d
    rol     r11d, 12
    add     r8d, r10d
    add     r9d, r11d
    xor     r14d, r8d
    rol     r14d, 8
    xor     r15d, r9d
    rol     r15d, 8
    add     r12d, r14d
    add     r13d, r15d
    xor     r10d, r12d
    rol     r10d, 7
    xor     r11d, r13d
    rol     r11d, 7

    mov     [rsp + 12], r12d

    add     eax, edx
    add     ecx, ebx
    xor     esi, eax
    rol     esi, 16
    mov     r12d, [rsp + 8]
    xor     edi, ecx
    rol     edi, 16
    add     r12d, esi
    add     ebp, edi
    xor     edx, r12d
    rol     edx, 12
    xor     ebx, ebp
    rol     ebx, 12
    add     eax, edx
    add     ecx, ebx
    xor     esi, eax
    rol     esi, 8
    xor     edi, ecx
    rol     edi, 8
    add     r12d, esi
    add     ebp, edi
    xor     edx, r12d
    rol     edx, 7
    xor     ebx, ebp
    rol     ebx, 7

    add     eax, r10d
    add     ecx, r11d
    xor     r15d, eax
    rol     r15d, 16
    xor     r14d, ecx
    rol     r14d, 16
    add     ebp, r15d
    add     r12d, r14d
    xor     r10d, ebp
    rol     r10d, 12
    xor     r11d, r12d
    rol     r11d, 12
    add     eax, r10d
    add     ecx, r11d
    xor     r15d, eax
    rol     r15d, 8
    xor     r14d, ecx
    rol     r14d, 8
    add     ebp, r15d
    add     r12d, r14d
    xor     r10d, ebp
    rol     r10d, 7
    xor     r11d, r12d
    rol     r11d, 7

    mov     [rsp + 8], r12d

    add     r8d, ebx
    add     r9d, edx
    xor     esi, r8d
    rol     esi, 16
    mov     r12d, [rsp + 12]
    xor     edi, r9d
    rol     edi, 16
    add     r13d, esi
    add     r12d, edi
    xor     ebx, r13d
    rol     ebx, 12
    xor     edx, r12d
    rol     edx, 12
    add     r8d, ebx
    add     r9d, edx
    xor     esi, r8d
    rol     esi, 8
    xor     edi, r9d
    rol     edi, 8
    add     r13d, esi
    add     r12d, edi
    xor     ebx, r13d
    rol     ebx, 7
    xor     edx, r12d
    rol     edx, 7

    jmp     .d

    ; Output the 32-byte hash.

.b:
    mov     rdx, [rsp + 16]
    add     rsp, 24

    shl     r8, 32
    or      r8, rax
    mov     [rdx], r8

    shl     r9, 32
    or      r9, rcx
    mov     [rdx + 8], r9

    shl     r14, 32
    or      r14, rsi
    mov     [rdx + 16], r14

    shl     r15, 32
    or      r15, rdi
    mov     [rdx + 24], r15

    ; Restore callee-saved registers.

    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbp
    pop     rbx

.q:
    ret
