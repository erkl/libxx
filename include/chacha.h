/* Copyright (c) 2018, Erik Lundin. */

#ifndef xx__chacha_h
#define xx__chacha_h

#include <stddef.h>
#include <stdint.h>


struct xx_chacha20 {
    uint32_t state[16];
    uint32_t cache[16];
    int8_t offset;
};

void xx_chacha20_init(struct xx_chacha20 * cx, const uint8_t key[32], const uint8_t iv[8]);
void xx_chacha20_seek(struct xx_chacha20 * cx, uint64_t counter, size_t offset);
void xx_chacha20_xor(struct xx_chacha20 * cx, uint8_t * dst, const uint8_t * src, size_t len);

void xx_hchacha20(uint8_t hash[32], const uint8_t key[32], const uint8_t iv[16]);


#endif
