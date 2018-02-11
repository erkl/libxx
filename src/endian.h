/* Copyright (c) 2018, Erik Lundin. */

#ifndef xx__endian_h
#define xx__endian_h

#include <stdint.h>


#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
    #define le32swap(x)  ((uint32_t) (x))
#elif __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
    static uint32_t le32swap(uint32_t x) {
        return (x & 0xff000000) >> 24
             | (x & 0x00ff0000) >> 8
             | (x & 0x0000ff00) << 8
             | (x & 0x000000ff) << 24;
    }
#endif


static void le32enc(uint8_t b[4], uint32_t x) {
    b[0] = (uint8_t) (x);
    b[1] = (uint8_t) (x >> 8);
    b[2] = (uint8_t) (x >> 16);
    b[3] = (uint8_t) (x >> 24);
}

static uint32_t le32dec(const uint8_t b[4]) {
    return (uint32_t) b[0]
         | (uint32_t) b[1] << 8
         | (uint32_t) b[2] << 16
         | (uint32_t) b[3] << 24;
}


#endif
