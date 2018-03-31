/* Copyright (c) 2018, Erik Lundin. */

#include "include/chacha.h"
#include "src/endian.h"


#define DOUBLE_ROUND(x)                                                        \
    do {                                                                       \
        QUARTER_ROUND(x[ 0], x[ 4], x[ 8], x[12]);                             \
        QUARTER_ROUND(x[ 1], x[ 5], x[ 9], x[13]);                             \
        QUARTER_ROUND(x[ 2], x[ 6], x[10], x[14]);                             \
        QUARTER_ROUND(x[ 3], x[ 7], x[11], x[15]);                             \
                                                                               \
        QUARTER_ROUND(x[ 0], x[ 5], x[10], x[15]);                             \
        QUARTER_ROUND(x[ 1], x[ 6], x[11], x[12]);                             \
        QUARTER_ROUND(x[ 2], x[ 7], x[ 8], x[13]);                             \
        QUARTER_ROUND(x[ 3], x[ 4], x[ 9], x[14]);                             \
    } while (0)

#define QUARTER_ROUND(a, b, c, d)                                              \
    do {                                                                       \
        a += b;  d ^= a;  d = (d << 16) | (d >> 16);                           \
        c += d;  b ^= c;  b = (b << 12) | (b >> 20);                           \
        a += b;  d ^= a;  d = (d <<  8) | (d >> 24);                           \
        c += d;  b ^= c;  b = (b <<  7) | (b >> 25);                           \
    } while (0)


void xx_chacha20_init(struct xx_chacha20 * cx, const uint8_t key[32], const uint8_t iv[8]) {
    cx->state[ 0] = 0x61707865;  /* "expa" */
    cx->state[ 1] = 0x3320646e;  /* "nd 3" */
    cx->state[ 2] = 0x79622d32;  /* "2-by" */
    cx->state[ 3] = 0x6b206574;  /* "te k" */

    cx->state[ 4] = le32dec(&key[ 0]);
    cx->state[ 5] = le32dec(&key[ 4]);
    cx->state[ 6] = le32dec(&key[ 8]);
    cx->state[ 7] = le32dec(&key[12]);
    cx->state[ 8] = le32dec(&key[16]);
    cx->state[ 9] = le32dec(&key[20]);
    cx->state[10] = le32dec(&key[24]);
    cx->state[11] = le32dec(&key[28]);

    cx->state[12] = 0;
    cx->state[13] = 0;
    cx->state[14] = le32dec(&iv[0]);
    cx->state[15] = le32dec(&iv[4]);

    cx->offset = 0;
}


void xx_chacha20_seek(struct xx_chacha20 * cx, uint64_t counter, size_t offset) {
    counter += (uint64_t) (offset >> 6);

    cx->state[12] = (uint32_t) (counter & 0xffffffff);
    cx->state[13] = (uint32_t) (counter >> 32);

    cx->offset = -(int8_t) (offset & 63);
}


void xx_chacha20_xor(struct xx_chacha20 * cx, uint8_t * dst, const uint8_t * src, size_t len) {
    size_t i, seek, num, off = 0;
    const uint8_t * stream;
    uint32_t x[16];

    if (len == 0)
        return;

    if (cx->offset <= 0) {
        seek = (size_t) -cx->offset;
    } else {
        seek = (size_t) cx->offset;
        goto cached;
    }

    for (;;) {
        for (i = 0; i < 16; i++)
            x[i] = cx->state[i];
        for (i = 0; i < 10; i++)
            DOUBLE_ROUND(x);
        for (i = 0; i < 16; i++)
            cx->cache[i] = le32conv(x[i] + cx->state[i]);

        cx->state[12] += 1;
        cx->state[13] += cx->state[12] == 0 ? 1 : 0;

cached:
        stream = ((const uint8_t *) cx->cache) + seek;
        num = len < 64-seek ? len : 64-seek;

        if (src != NULL) {
            for (i = 0; i < num; i++)
                dst[off+i] = stream[i] ^ src[off+i];
        } else {
            for (i = 0; i < num; i++)
                dst[off+i] = stream[i];
        }

        if (len <= num)
            break;

        off += num;
        len -= num;
        seek = 0;
    }

    cx->offset = (int8_t) (seek + len) & 63;
}


void xx_hchacha20(uint8_t hash[32], const uint8_t key[32], const uint8_t iv[16]) {
    uint32_t x[16];
    int i;

    x[ 0] = 0x61707865;  /* "expa" */
    x[ 1] = 0x3320646e;  /* "nd 3" */
    x[ 2] = 0x79622d32;  /* "2-by" */
    x[ 3] = 0x6b206574;  /* "te k" */

    x[ 4] = le32dec(&key[ 0]);
    x[ 5] = le32dec(&key[ 4]);
    x[ 6] = le32dec(&key[ 8]);
    x[ 7] = le32dec(&key[12]);
    x[ 8] = le32dec(&key[16]);
    x[ 9] = le32dec(&key[20]);
    x[10] = le32dec(&key[24]);
    x[11] = le32dec(&key[28]);

    x[12] = le32dec(&iv[ 0]);
    x[13] = le32dec(&iv[ 4]);
    x[14] = le32dec(&iv[ 8]);
    x[15] = le32dec(&iv[12]);

    for (i = 0; i < 10; i++)
        DOUBLE_ROUND(x);

    le32enc(&hash[ 0], x[ 0]);
    le32enc(&hash[ 4], x[ 1]);
    le32enc(&hash[ 8], x[ 2]);
    le32enc(&hash[12], x[ 3]);

    le32enc(&hash[16], x[12]);
    le32enc(&hash[20], x[13]);
    le32enc(&hash[24], x[14]);
    le32enc(&hash[28], x[15]);
}
