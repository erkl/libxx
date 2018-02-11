/* Copyright (c) 2018, Erik Lundin. */

#ifndef xx__test_utils_h
#define xx__test_utils_h


static uint8_t dehex(char c) {
    if ('0' <= c && c <= '9')
        return (uint8_t) c - '0';
    if ('a' <= c && c <= 'f')
        return (uint8_t) c - 'a' + 10;
    if ('A' <= c && c <= 'F')
        return (uint8_t) c - 'A' + 10;

    return (uint8_t) -1;
}

static int hexcmp(const uint8_t * ptr, const char * hex, size_t len) {
    size_t i;

    for (i = 0; i < len; i++) {
        if (ptr[i] != (dehex(hex[2*i+0])<<4 | dehex(hex[2*i+1])))
            return -1;
    }

    return 0;
}


#endif
