/* Copyright (c) 2018, Erik Lundin. */

#include <stdlib.h>
#include <string.h>

#include "include/chacha.h"
#include "test/utils.h"


struct hchacha20_tv {
    const uint8_t key[32];
    const uint8_t iv[16];
    const uint8_t hash[32];
};


static struct hchacha20_tv tvs[] = {
    {
        {
            0x24, 0xf1, 0x1c, 0xce, 0x8a, 0x1b, 0x3d, 0x61,
            0xe4, 0x41, 0x56, 0x1a, 0x69, 0x6c, 0x1c, 0x1b,
            0x7e, 0x17, 0x3d, 0x08, 0x4f, 0xd4, 0x81, 0x24,
            0x25, 0x43, 0x5a, 0x88, 0x96, 0xa0, 0x13, 0xdc,
        },
        {
            0xd9, 0x66, 0x0c, 0x59, 0x00, 0xae, 0x19, 0xdd,
            0xad, 0x28, 0xd6, 0xe0, 0x6e, 0x45, 0xfe, 0x5e,
        },
        {
            0x59, 0x66, 0xb3, 0xee, 0xc3, 0xbf, 0xf1, 0x18,
            0x9f, 0x83, 0x1f, 0x06, 0xaf, 0xe4, 0xd4, 0xe3,
            0xbe, 0x97, 0xfa, 0x92, 0x35, 0xec, 0x8c, 0x20,
            0xd0, 0x8a, 0xcf, 0xbb, 0xb4, 0xe8, 0x51, 0xe3,
        },
    },
    {
        {
            0x80, 0xa5, 0xf6, 0x27, 0x20, 0x31, 0xe1, 0x8b,
            0xb9, 0xbc, 0xd8, 0x4f, 0x33, 0x85, 0xda, 0x65,
            0xe7, 0x73, 0x1b, 0x70, 0x39, 0xf1, 0x3f, 0x5e,
            0x3d, 0x47, 0x53, 0x64, 0xcd, 0x4d, 0x42, 0xf7,
        },
        {
            0xc0, 0xec, 0xcc, 0x38, 0x4b, 0x44, 0xc8, 0x8e,
            0x92, 0xc5, 0x7e, 0xb2, 0xd5, 0xca, 0x4d, 0xfa,
        },
        {
            0x6e, 0xd1, 0x17, 0x41, 0xf7, 0x24, 0x00, 0x9a,
            0x64, 0x0a, 0x44, 0xfc, 0xe7, 0x32, 0x09, 0x54,
            0xc4, 0x6e, 0x18, 0xe0, 0xd7, 0xae, 0x06, 0x3b,
            0xdb, 0xc8, 0xd7, 0xcf, 0x37, 0x27, 0x09, 0xdf,
        },
    },
    {
        {
            0xcb, 0x1f, 0xc6, 0x86, 0xc0, 0xee, 0xc1, 0x1a,
            0x89, 0x43, 0x8b, 0x6f, 0x40, 0x13, 0xbf, 0x11,
            0x0e, 0x71, 0x71, 0xda, 0xce, 0x32, 0x97, 0xf3,
            0xa6, 0x57, 0xa3, 0x09, 0xb3, 0x19, 0x96, 0x29,
        },
        {
            0xfc, 0xd4, 0x9b, 0x93, 0xe5, 0xf8, 0xf2, 0x99,
            0x22, 0x7e, 0x64, 0xd4, 0x0d, 0xc8, 0x64, 0xa3,
        },
        {
            0x84, 0xb7, 0xe9, 0x69, 0x37, 0xa1, 0xa0, 0xa4,
            0x06, 0xbb, 0x71, 0x62, 0xee, 0xaa, 0xd3, 0x43,
            0x08, 0xd4, 0x9d, 0xe6, 0x0f, 0xd2, 0xf7, 0xec,
            0x9d, 0xc6, 0xa7, 0x9c, 0xba, 0xb2, 0xca, 0x34,
        },
    },
    {
        {
            0x66, 0x40, 0xf4, 0xd8, 0x0a, 0xf5, 0x49, 0x6c,
            0xa1, 0xbc, 0x2c, 0xff, 0xf1, 0xfe, 0xfb, 0xe9,
            0x96, 0x38, 0xdb, 0xce, 0xaa, 0xbd, 0x7d, 0x0a,
            0xde, 0x11, 0x89, 0x99, 0xd4, 0x5f, 0x05, 0x3d,
        },
        {
            0x31, 0xf5, 0x9c, 0xee, 0xea, 0xfd, 0xbf, 0xe8,
            0xca, 0xe7, 0x91, 0x4c, 0xae, 0xba, 0x90, 0xd6,
        },
        {
            0x9a, 0xf4, 0x69, 0x7d, 0x2f, 0x55, 0x74, 0xa4,
            0x48, 0x34, 0xa2, 0xc2, 0xae, 0x1a, 0x05, 0x05,
            0xaf, 0x9f, 0x5d, 0x86, 0x9d, 0xbe, 0x38, 0x1a,
            0x99, 0x4a, 0x18, 0xeb, 0x37, 0x4c, 0x36, 0xa0,
        },
    },
    {
        {
            0x06, 0x93, 0xff, 0x36, 0xd9, 0x71, 0x22, 0x5a,
            0x44, 0xac, 0x92, 0xc0, 0x92, 0xc6, 0x0b, 0x39,
            0x9e, 0x67, 0x2e, 0x4c, 0xc5, 0xaa, 0xfd, 0x5e,
            0x31, 0x42, 0x6f, 0x12, 0x37, 0x87, 0xac, 0x27,
        },
        {
            0x3a, 0x62, 0x93, 0xda, 0x06, 0x1d, 0xa4, 0x05,
            0xdb, 0x45, 0xbe, 0x17, 0x31, 0xd5, 0xfc, 0x4d,
        },
        {
            0xf8, 0x7b, 0x38, 0x60, 0x91, 0x42, 0xc0, 0x10,
            0x95, 0xbf, 0xc4, 0x25, 0x57, 0x3b, 0xb3, 0xc6,
            0x98, 0xf9, 0xae, 0x86, 0x6b, 0x7e, 0x42, 0x16,
            0x84, 0x0b, 0x9c, 0x4c, 0xaf, 0x3b, 0x08, 0x65,
        },
    },
    {
        {
            0x80, 0x95, 0x39, 0xbd, 0x26, 0x39, 0xa2, 0x3b,
            0xf8, 0x35, 0x78, 0x70, 0x0f, 0x05, 0x5f, 0x31,
            0x35, 0x61, 0xc7, 0x78, 0x5a, 0x4a, 0x19, 0xfc,
            0x91, 0x14, 0x08, 0x69, 0x15, 0xee, 0xe5, 0x51,
        },
        {
            0x78, 0x0c, 0x65, 0xd6, 0xa3, 0x31, 0x8e, 0x47,
            0x9c, 0x02, 0x14, 0x1d, 0x3f, 0x0b, 0x39, 0x18,
        },
        {
            0x90, 0x2e, 0xa8, 0xce, 0x46, 0x80, 0xc0, 0x93,
            0x95, 0xce, 0x71, 0x87, 0x4d, 0x24, 0x2f, 0x84,
            0x27, 0x42, 0x43, 0xa1, 0x56, 0x93, 0x8a, 0xaa,
            0x2d, 0xd3, 0x7a, 0xc5, 0xbe, 0x38, 0x2b, 0x42,
        },
    },
    {
        {
            0x1a, 0x17, 0x0d, 0xdf, 0x25, 0xa4, 0xfd, 0x69,
            0xb6, 0x48, 0x92, 0x6e, 0x6d, 0x79, 0x4e, 0x73,
            0x40, 0x88, 0x05, 0x83, 0x5c, 0x64, 0xb2, 0xc7,
            0x0e, 0xfd, 0xdd, 0x8c, 0xd1, 0xc5, 0x6c, 0xe0,
        },
        {
            0x05, 0xdb, 0xee, 0x10, 0xde, 0x87, 0xeb, 0x0c,
            0x5a, 0xcb, 0x2b, 0x66, 0xeb, 0xbe, 0x67, 0xd3,
        },
        {
            0xa4, 0xe2, 0x0b, 0x63, 0x4c, 0x77, 0xd7, 0xdb,
            0x90, 0x8d, 0x38, 0x7b, 0x48, 0xec, 0x2b, 0x37,
            0x00, 0x59, 0xdb, 0x91, 0x6e, 0x8e, 0xa7, 0x71,
            0x6d, 0xc0, 0x72, 0x38, 0x53, 0x2d, 0x59, 0x81,
        },
    },
    {
        {
            0x3b, 0x35, 0x4e, 0x4b, 0xb6, 0x9b, 0x5b, 0x4a,
            0x11, 0x26, 0xf5, 0x09, 0xe8, 0x4c, 0xad, 0x49,
            0xf1, 0x8c, 0x9f, 0x5f, 0x29, 0xf0, 0xbe, 0x0c,
            0x82, 0x13, 0x16, 0xa6, 0x98, 0x6e, 0x15, 0xa6,
        },
        {
            0xd8, 0xa8, 0x9a, 0xf0, 0x2f, 0x4b, 0x8b, 0x29,
            0x01, 0xd8, 0x32, 0x17, 0x96, 0x38, 0x8b, 0x6c,
        },
        {
            0x98, 0x16, 0xcb, 0x1a, 0x5b, 0x61, 0x99, 0x37,
            0x35, 0xa4, 0xb1, 0x61, 0xb5, 0x1e, 0xd2, 0x26,
            0x5b, 0x69, 0x6e, 0x7d, 0xed, 0x53, 0x09, 0xc2,
            0x29, 0xa5, 0xa9, 0x9f, 0x53, 0x53, 0x4f, 0xbc,
        },
    },
    {
        {
            0x4b, 0x9a, 0x81, 0x88, 0x92, 0xe1, 0x5a, 0x53,
            0x0d, 0xb5, 0x0d, 0xd2, 0x83, 0x2e, 0x95, 0xee,
            0x19, 0x2e, 0x5e, 0xd6, 0xaf, 0xff, 0xb4, 0x08,
            0xbd, 0x62, 0x4a, 0x0c, 0x4e, 0x12, 0xa0, 0x81,
        },
        {
            0xa9, 0x07, 0x9c, 0x55, 0x1d, 0xe7, 0x05, 0x01,
            0xbe, 0x02, 0x86, 0xd1, 0xbc, 0x78, 0xb0, 0x45,
        },
        {
            0xeb, 0xc5, 0x22, 0x4c, 0xf4, 0x1e, 0xa9, 0x74,
            0x73, 0x68, 0x3b, 0x6c, 0x2f, 0x38, 0xa0, 0x84,
            0xbf, 0x6e, 0x1f, 0xea, 0xae, 0xff, 0x62, 0x67,
            0x6d, 0xb5, 0x9d, 0x5b, 0x71, 0x9d, 0x99, 0x9b,
        },
    },
    {
        {
            0xc4, 0x97, 0x58, 0xf0, 0x00, 0x03, 0x71, 0x4c,
            0x38, 0xf1, 0xd4, 0x97, 0x2b, 0xde, 0x57, 0xee,
            0x82, 0x71, 0xf5, 0x43, 0xb9, 0x1e, 0x07, 0xeb,
            0xce, 0x56, 0xb5, 0x54, 0xeb, 0x7f, 0xa6, 0xa7,
        },
        {
            0x31, 0xf0, 0x20, 0x4e, 0x10, 0xcf, 0x4f, 0x20,
            0x35, 0xf9, 0xe6, 0x2b, 0xb5, 0xba, 0x73, 0x03,
        },
        {
            0x0d, 0xd8, 0xcc, 0x40, 0x0f, 0x70, 0x2d, 0x2c,
            0x06, 0xed, 0x92, 0x0b, 0xe5, 0x20, 0x48, 0xa2,
            0x87, 0x07, 0x6b, 0x86, 0x48, 0x0a, 0xe2, 0x73,
            0xc6, 0xd5, 0x68, 0xa2, 0xe9, 0xe7, 0x51, 0x8c,
        },
    },
};


int xx__test_hchacha20(void) {
    uint8_t hash[32];
    size_t i;

    for (i = 0; i < sizeof(tvs) / sizeof(tvs[0]); i++) {
        xx_hchacha20(hash, tvs[i].key, tvs[i].iv);

        if (memcmp(hash, tvs[i].hash, 32) != 0)
            return -1;
    }

    return 0;
}