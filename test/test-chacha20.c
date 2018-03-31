/* Copyright (c) 2018, Erik Lundin. */

#include <stdlib.h>
#include <string.h>

#include "include/chacha.h"
#include "test/utils.h"


/* We begin by defining a set of test vectors -- a number of rules which say
 * "given this particular key and nonce input, I expect the keystream from such
 * and such block counter offset onwards to look like *this*." Most of these
 * are based on already published test vectors.
 *
 * Next, we define a set of procedures for generating keystream data. One of
 * them might use a single call to xx_chacha20_xor, another might generate the
 * ouput one byte at a time and in reverse order. The point is to hit as many
 * different states as possible.
 *
 * The cartesian product of these two sets amounts to an enormous number of
 * states -- vastly more than I could ever be bothered to write by hand. */


struct chacha20_tv {
    const uint8_t * input;
    uint64_t counter;
    const char * stream;
};


static const uint8_t zeros[40] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
};

static const uint8_t ones[40] = {
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
};

static const uint8_t seq[40] = {
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
    0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff,
    0xff, 0xee, 0xdd, 0xcc, 0xbb, 0xaa, 0x99, 0x88,
    0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x00,
    0x0f, 0x1e, 0x2d, 0x3c, 0x4b, 0x59, 0x68, 0x77,
};

static const uint8_t noise[40] = {
    0xc4, 0x6e, 0xc1, 0xb1, 0x8c, 0xe8, 0xa8, 0x78,
    0x72, 0x5a, 0x37, 0xe7, 0x80, 0xdf, 0xb7, 0x35,
    0x1f, 0x68, 0xed, 0x2e, 0x19, 0x4c, 0x79, 0xfb,
    0xc6, 0xae, 0xbe, 0xe1, 0xa6, 0x67, 0x97, 0x5d,
    0x1a, 0xda, 0x31, 0xd5, 0xcf, 0x68, 0x82, 0x21,
};


static struct chacha20_tv tvs[] = {
    { zeros, 0x0000000000000000,
        "76b8e0ada0f13d90405d6ae55386bd28bdd219b8a08ded1aa836efcc8b770dc7"
        "da41597c5157488d7724e03fb8d84a376a43b8f41518a11cc387b669b2ee6586"
        "9f07e7be5551387a98ba977c732d080dcb0f29a048e3656912c6533e32ee7aed"
        "29b721769ce64e43d57133b074d839d531ed1f28510afb45ace10a1f4b794d6f"
        "2d09a0e663266ce1ae7ed1081968a0758e718e997bd362c6b0c34634a9a0b35d"
        "012737681f7b5d0f281e3afde458bc1e73d2d313c9cf94c05ff3716240a248f2"
        "1320a058d7b3566bd520daaa3ed2bf0ac5b8b120fb852773c3639734b45c91a4"
        "2dd4cb83f8840d2eedb158131062ac3f1f2cf8ff6dcd1856e86a1e6c3167167e"
        "e5a688742b47c5adfb59d4df76fd1db1e51ee03b1ca9f82aca173edb8b729347"
        "4ebe980f904d10c916442b4783a0e984860cb6c957b39c38ed8f51cffaa68a4d"
        "e01025a39c504546b9dc1406a7eb28151e5150d7b204baa719d4f091021217db"
        "5cf1b5c84c4fa71a879610a1a695ac527c5b56774a6b8a21aae88685868e094c"
        "f29ef4090af7a90cc07e8817aa528763797d3c332b67ca4bc110642c2151ec47"
        "ee84cb8c42d85f10e2a8cb18c3b7335f26e8c39a12b1bcc1707177b76138732e"
        "edaab74da1410fc055ea068c99e9260acbe337cf5d3e00e5b3230ffedb0b9907"
        "87d0c70e0bfe4198ea6758dd5a61fb5fec2df981f31befe153f81d17161784db"
        "1c8822d53cd1ee7db532364828bdf404b040a8dcc522f3d3d99aec4b8057edb8"
        "500931a2c42d2f0c570847100b5754dafc5fbdb894bbef1a2de1a07f8ba0c4b9"
        "19301066edbc056b7b481e7a0c46297bbb589d9da5b675a6723e152e5e63a4ce"
        "034e9e83e58a013af0e7352fb7908514e3b3d1040d0bb963b3954b636b5fd4bf"
        "6d0aadbaf8157d062acb2418c176a475511b35c3f6218a5668ea5bc6f54b8782"
        "f8b340f00ac1beba5e62cd632a7ce7809c725608aca5efbf7c41f237643f06c0"
        "997207171de867f9d697bf5ea6011abcce6c8cdb211394d2c02dd0fb60db5a2c"
        "17ac3dc85878a90bed3809dbb96eaa5426fc8eae0d2d65c42a479f088648be2d"
        "c801d82a366fddc0ef234263c0b6417d5f9da41817b88d68e5e67195c5c1ee30"
        "95e821f22524b20be41ceb590412e41dc648843fa9bfec7a3dcf61ab05415733"
        "16d3fa8151629303fe9741562ed065db4ebc0050ef558364ae81124a28f5c013"
        "13232fbc496dfd8a2568657b686d7214382a1a00903017dda969878442ba5aff"
        "f6613f553cbb233ce46d9aee93a7876cf5e9e82912b18cadf0b34327b2e0427e"
        "cf66b7ceb7c0918dc47bdff12a062adf07133009ce7a5e5c917e0168306109b7"
        "cb49653a6d2caef005de783a9a9bfe05381ed1348d94ec65886f9c0b619c52c5"
        "533800b16c836172b95182dbc5eec042b89e22f11a085b739a3611cd8d836018"
        "c4fff0b86c02ed662d2d2522647a1f09a7b2f9eea56e7e20b1f06ccdd9cec37e"
        "3b2d20812df369978636c22646603675804104745d2997e28df5d8242aad19c8"
        "120ca4142fb6019fccecf9fadb04ade03b341e3fc77201b3dc957a8097ab2f61"
        "5aff142ab753811d5f32e75bc8825b456555f3d179ffabcf35f6ae61365851f3"
        "f681a2e86e8078b064976646186394cb9064767750dad4e336b8f1d20fe2c13c"
        "6248d3d73d4d66d9c8587ac68a7976a3bbb8b5808320607400dbdb1918e3d3b9"
        "0cfc38c4ddfade990a213d208fbf7898334f4deed7e5830fd266751315435ae1"
        "9bb94f4d3dc92652f243dd1f96f3595ab473d2356d8fa8f6d64cc4f64b12ca99"
        "ecdd1962572e6add609d9c619aab678b3fc298bc2f0f81feb4f0d3ebad7e850a"
        "8bcb52ca467e649de2db913bfda001294c49dc369f7d14cc25c5fa65d4d5af6a"
        "436d22bd2839be23dd3c57825033fecdce2ded6c511dbeaf4df2b4cbb7af8215"
        "bb48a550f57d02750e599298f512b1ec1829722fc10a5acf9537e392a7284559"
        "05d3ab4837dece4b63fdfd5dd07a2b76a8c82566df1a2167dae5e125b6aa0e76"
        "b9d99ca84664f50eeea54e449f0e587039137f57543d89205483141c933166b6"
        "1990a706aca07f467d22bc34c6552f5bba91cb1fc21db51d03dfff6523a5e1b4"
        "285d54c47660eda1b290e4087b30651b542305a714e98a8233577d2afb383e40"
        "2f6b9fd214b194c738886bd2289cc5f997951910994b0a6104092fbc9b385639"
        "343cf26c9faf845e7a98cb1f2c9306e8200185d95de059f83ad17c4b97f8c62c"
        "f6c347dc6eb5f2b1f4bf2dd328130d4500ca39beba2d4281a3d8ceb4cb1ecde3"
        "78b20029fb6a4c543312e41013915c57016e5da681944cc277f9c7e75f4a654a"
        "b2e5dc646ada242b6223aacc63674f9702146723360811adbdf2bb938b595bf4"
        "c688a8a844130d9da3f0efe3650c2283640b342f8922fb6dd10b8bbe35c7aebe"
        "ba416cb0180fb7d2b171149018f8d880463ac26202c2b72f9a7cf83a917ad261"
        "83f8e74cd418e3b63459f7ad59849ee43cac6df3bb63fceec1abe8e9e0b64b23"
        "3a43aac54f9ba0998d2219b3baca111940d524b7cf94677d6c557750fa4db9e1"
        "077eedb5ba6e33c104ae25443c86bf1583353addf6fddd19a4ff491188e3d487"
        "8769611b36427c8f4c705cf42338475c3185c123919b79b3a4887243b924509c"
        "9a4e7a3fff0517021e51642d9b4526c28a0cf86fb254be7eab18701ca5919b75"
        "4ec2506eccc087ac6141b4c3a661a3d1a89e0d4dd2df52caa5b3402d0026b3c6"
        "43fa7126e8ed101a94188a048b34ab61e1182d6be76e2e9e6acf401443ed0d99"
        "7dd5ae67346cb1e189791102900225e6b955cd7c9e39fc7255021045fe7ecd40"
        "e2c68486a4c2fbcdbc53e847790dafe5b2cbdca09bf09de327076c79f2a339a9"
    },
    { zeros, 0xfffffffffffffff8,
        "790f974ac2ca092a8aa2ae3edf015a1686e653678764864be317badd0345d6ac"
        "f22da399fd095b31e3b614fec25900361b855dc667ead49278178aae0fabf5d9"
        "7b56f6e5c3186253d3106307a5168a7081d6bd9e370cce25791d4eddaec69de5"
        "e0d79e5daa76fb7808ce2f87676415697de91103b6a06f8dd7e291479164f6dd"
        "98f5b9534797dcedbe7305d26ce4ea759f0520c0cd8b364ef6b252420de97d0f"
        "e949868ab534870d22e2e7dbc13d0b3da35d23b508d94ea9388cc2a499686ed4"
        "ae150d487fd39152554d1b7202dba2da807a122db370ec9dc5a50ff396a06c9c"
        "2b8a387167450c99f549a331df1534a670b5ed2f012615710731d29d2f92ff1e"
        "511e406405b4d634e470f421d32734bfab85aa5ab9ac29d68ceb7fbf84bec305"
        "860084dcb5e56f23399def9c5223970ee39ff9c1dde203966b28e70489c96d01"
        "964c3bbe189b6d24b6e06b9bd63fd4c2c30e77ed6030de773ab12ad5b915f05b"
        "d4b0643cbadce70bb7727215479f9c9049fc35566b8e1c5efc60bc8d399c619d"
        "83226f1fa702aaf28ea76f23999a26323090f141b3d3ec9ddc8535e4dea3415d"
        "1ada0f9ea3b859bff3a9c403a2445258b98fe972aca5caf053752c355c7520b8"
        "d7918cd8620cf832532652c04c01a553092cfb32e7b3f2f5467ae9674a2e9eec"
        "17368ec8027a357c0c51e6ea747121fec45284be0f099d2b3328845607b17689"
        "76b8e0ada0f13d90405d6ae55386bd28bdd219b8a08ded1aa836efcc8b770dc7"
        "da41597c5157488d7724e03fb8d84a376a43b8f41518a11cc387b669b2ee6586"
        "9f07e7be5551387a98ba977c732d080dcb0f29a048e3656912c6533e32ee7aed"
        "29b721769ce64e43d57133b074d839d531ed1f28510afb45ace10a1f4b794d6f"
        "2d09a0e663266ce1ae7ed1081968a0758e718e997bd362c6b0c34634a9a0b35d"
        "012737681f7b5d0f281e3afde458bc1e73d2d313c9cf94c05ff3716240a248f2"
        "1320a058d7b3566bd520daaa3ed2bf0ac5b8b120fb852773c3639734b45c91a4"
        "2dd4cb83f8840d2eedb158131062ac3f1f2cf8ff6dcd1856e86a1e6c3167167e"
        "e5a688742b47c5adfb59d4df76fd1db1e51ee03b1ca9f82aca173edb8b729347"
        "4ebe980f904d10c916442b4783a0e984860cb6c957b39c38ed8f51cffaa68a4d"
        "e01025a39c504546b9dc1406a7eb28151e5150d7b204baa719d4f091021217db"
        "5cf1b5c84c4fa71a879610a1a695ac527c5b56774a6b8a21aae88685868e094c"
        "f29ef4090af7a90cc07e8817aa528763797d3c332b67ca4bc110642c2151ec47"
        "ee84cb8c42d85f10e2a8cb18c3b7335f26e8c39a12b1bcc1707177b76138732e"
        "edaab74da1410fc055ea068c99e9260acbe337cf5d3e00e5b3230ffedb0b9907"
        "87d0c70e0bfe4198ea6758dd5a61fb5fec2df981f31befe153f81d17161784db"
    },
    { zeros, 0x00000000fffffff8,
        "7035102b0f813905c4339ff8f0dc621ca2bc76f6a99163e0751be6f7968d9c22"
        "863a2161de3126abb102fca8ad47a035ea71358f1c418d2ba8af1afcb8ceb20d"
        "fe012d699b31d5f22828772a13a076f789b4b582e9736cdfa48e317ab1ff5443"
        "60745f9eff11847eb86365dc0ab980231b0accd8da22e33867a6c2314d56688e"
        "17f6ec119b6ad7fe0a639f07ee6f7c0b5b88e8d0c97ec901636a7b62202d40d9"
        "176cf64365065ee642430787db981190a249b7771759157ba8aa3a253c48338c"
        "9e01be363682292bb181a75a51c2eeb3069951075dc92cfe58e695ab35364667"
        "1336be145fe90b8c75982d565762f7c48b505b19868f36a6c3633450cb9e165e"
        "98e5e54215c14f994e957fd3dd6a0309dfc3512cf12937f859a58725f16e9d4c"
        "3bfba511be065c2ae7452da187096671731a9954137ba780b808f9e93c919871"
        "582cb23e8f29e3b966b29d19e01a01debb32a8635cf49a1b178c3cd53cbf3ec5"
        "12dd6174690da38fda7c125351035f99e61042c5dcfa0c312e002f0dc99962dc"
        "032cc123482c31711f94c941af5ab1f4155784332ed5348fe79aec5ead4c06c3"
        "f13c280d8cc49925e4a6a5922ec80e13a4cdfa840c70a1427a3cb699166991a5"
        "ace4cd09e294d1912d4ad205d06f95d9c2f2bfcf453e8753f128765b62215f4d"
        "92c74f2f626c6a640c0b1284d839ec81f1696281dafc3e684593937023b58b1d"
        "3db41d3aa0d329285de6f225e6e24bd59c9a17006943d5c9b680e3873bdc683a"
        "5819469899989690c281cd17c96159af0682b5b903468a61f50228cf09622b5a"
        "46f0f6efee15c8f1b198cb49d92b990867905159440cc723916dc00128269810"
        "39ce1766aa2542b05db3bd809ab142489d5dbfe1273e7399637b4b3213768aaa"
        "89b1889375e99fe2442c4f68adf54158f4b8135713d00999b92b38e3aafe5ff4"
        "959b1834be3dc54fc36aa9d32eb121e0f688b90e7c7e2649f4aaef407bdd2b94"
        "09efec03114cb5d4ffd1788e0fe1897bd176c1311e368368c657a5ee55c9ca03"
        "cc71744f030822d53a0486a97b9d98240274fadeaf262bd81b58bce3dfa98414"
        "c24b5bc517fd91993a6b2e6232b0502125c6f48a6921e2dda8eb6b3c4ecf2aae"
        "889602ad90b5d2537ff45df525c67b983b51dbd23e1280aa656eae85b63cc42d"
        "e8c70e7c19c1d66e3f902bea9d1acfd3326b5985ad7c8cabd431acbc62976ce5"
        "23c938ea447d4af0f560dc52b0ab1d7d66a42ab8272e2c40bd66470fe6f68846"
        "12a11d899a0b7eb54907bbedd6483efced1f15621d4673ff928c5aab5f465257"
        "123679ef17c39648c537e150108e0f6608732e9f5b240689eeb5402fa04ccb89"
        "b7ca9649a361c526b41ed110402d9497715b03441118bc4953fcbef395267570"
        "bd43ec0eef7b6167f14fed205eb812907d0c134dc49fa5b18f5a3a3a9bd0a71b"
    },
    { ones, 0x0000000000000000,
        "d9bf3f6bce6ed0b54254557767fb57443dd4778911b606055c39cc25e674b836"
        "3feabc57fde54f790c52c8ae43240b79d49042b777bfd6cb80e931270b7f50eb"
        "5bac2acd86a836c5dc98c116c1217ec31d3a63a9451319f097f3b4d6dab07787"
        "19477d24d24b403a12241d7cca064f790f1d51ccaff6b1667d4bbca1958c4306"
        "2d83c32143f7d743a87f710c3202af7d30046775865f3934958597bb38ffe32c"
        "7c5b456e3e5457d203bb45d304d014d46709ea4db71a935efc388cefa5b894e5"
        "d1076a95ec7791ab0ad55c2a2fac3c61e35bae153036763326d632c9e004bc6d"
        "a45d5fc9486c29f002e40a7ab619ddca1a660765f853c77e1ff44c2a4f49344f"
        "7530dc05190bd9a256fe38cede7daa540904135bec993088e712276467166a63"
        "04f1fc26c9dda89cee93d15441c88fc15e143db941bbb42424a36e5c8f5aaa49"
        "2bfeed0ba93348aa786f40114f4895a6b21a11db8937a510b2a099f75c1e03e7"
        "a6e3e281ec9c66d400f36c232798c6496048028c8d7320f43e97a56d6c4d1183"
        "8fd5dd8f45df7de235225b5f1c41c3afed4ec0526ab38dcb8597770803f1261c"
        "d22cfeaec86612e53defc29848c055053c6b1d462a3cf09b228e47211afba0af"
        "4e4c2b336e6ee2f471823808523f073c1bc8785d258ac2bd580209a82a875273"
        "93df828b6a6728abd7aad0485bff5ce92c8db78b1e63929fc76a905e8c7af310"
    },
    { seq, 0x0000000000000000,
        "87fa92061043ca5e631fedd88e8bfb84ad6b213bdee4bc806e2764935fb89097"
        "218a897b7aead10e1b17f6802b2abdd95594903083735613d6b3531b9e0d1b67"
        "47908c74f018f6e182138b991b9c5a957c69f23c26c8a2fbb8b0acf8e64222cc"
        "251281a61cff673608de6490b41ca1b9f4ab754474f9afc7c35dcd65de3d745f"
        "a0ba20a980dbe527cd4910bea0eb59284aa47a95fe27e34ea723b35438526790"
        "57646d89de5db2da9ecd601d20e5851debcdf199452cdf5f2d84689aafad7658"
        "ca51ae08656ff40ba04793ab53a8ecef984fda1ced21b05276c4e9732fe6b255"
        "ceadbedd124955bb39bfc6176a8f2393dc0e0d1acf2e611e0698145627a500f3"
        "486210fe7bb75c8f54a8b436ba8e03d71e5f4baedba80eb371e12a37b5611ef4"
        "653e85af99cc966117431aeed5a8af8655db9ad1a4342f6ce9028e918f2c5c6f"
        "76d6ca3c707c08846f6f7d230a37b03029a2bcac08c899ba7f98a5049d23ca55"
        "0e4da532dd38c89c3143d7f6c9d9f1f6c4b744c434738e2bf6a2906c6685504a"
        "26971320d2cdd2da8257e1a88fb6c50b1ce594efe5fe57a081555db0a20b57f6"
        "3d6f38ff1d2adba4ffecef138a846dc0214ed5e6f32fe5756b4db3073e4f8cc7"
        "2e57cdf4907f0141f536de7c2cea790eb394ba73ae140f7730611f4b01a4cac2"
        "8fdfa4796b9a792c5460572864ca22e56531dd7ff4100faa2498b9373c644f6f"
    },
    { noise, 0x0000000000000000,
        "f63a89b75c2271f9368816542ba52f06ed49241792302b00b5e8f80ae9a473af"
        "c25b218f519af0fdd406362e8d69de7f54c604a6e00f353f110f771bdca8ab92"
        "e5fbc34e60a1d9a9db17345b0a402736853bf910b060bdf1f897b6290f01d138"
        "ae2c4c90225ba9ea14d518f55929dea098ca7a6ccfe61227053c84e49a4a3332"
    },
};


static void do_simple_mov(const uint8_t * input, uint64_t counter, uint8_t * buf, size_t len) {
    struct xx_chacha20 cx;

    xx_chacha20_init(&cx, input, input + 32);
    xx_chacha20_seek(&cx, counter, 0);
    xx_chacha20_xor(&cx, buf, NULL, len);
}

static void do_simple_xor(const uint8_t * input, uint64_t counter, uint8_t * buf, size_t len) {
    struct xx_chacha20 cx;
    size_t i;

    for (i = 0; i < len; i++)
        buf[i] = (uint8_t) (i + 1);

    xx_chacha20_init(&cx, input, input + 32);
    xx_chacha20_seek(&cx, counter, 0);
    xx_chacha20_xor(&cx, buf, buf, len);

    for (i = 0; i < len; i++)
        buf[i] ^= (uint8_t) (i + 1);
}

static void do_piecemeal_mov(const uint8_t * input, uint64_t counter, uint8_t * buf, size_t len) {
    struct xx_chacha20 cx;
    size_t i;

    xx_chacha20_init(&cx, input, input + 32);
    xx_chacha20_seek(&cx, counter, 0);

    for (i = 0; i < len; i++)
        xx_chacha20_xor(&cx, buf + i, NULL, 1);
}

static void do_piecemeal_xor(const uint8_t * input, uint64_t counter, uint8_t * buf, size_t len) {
    struct xx_chacha20 cx;
    size_t i;

    for (i = 0; i < len; i++)
        buf[i] = (uint8_t) (i + 3);

    xx_chacha20_init(&cx, input, input + 32);
    xx_chacha20_seek(&cx, counter, 0);

    for (i = 0; i < len; i++)
        xx_chacha20_xor(&cx, buf + i, buf + i, 1);

    for (i = 0; i < len; i++)
        buf[i] ^= (uint8_t) (i + 3);
}

static void do_seeking_mov(const uint8_t * input, uint64_t counter, uint8_t * buf, size_t len) {
    struct xx_chacha20 cx;
    size_t i;

    xx_chacha20_init(&cx, input, input + 32);

    for (i = 0; i < len; i++) {
        xx_chacha20_seek(&cx, counter, i);
        xx_chacha20_xor(&cx, buf + i, NULL, 1);
    }
}

static void do_seeking_xor(const uint8_t * input, uint64_t counter, uint8_t * buf, size_t len) {
    struct xx_chacha20 cx;
    size_t i;

    for (i = 0; i < len; i++)
        buf[i] = (uint8_t) (i + 5);

    xx_chacha20_init(&cx, input, input + 32);

    for (i = 0; i < len; i++) {
        xx_chacha20_seek(&cx, counter, i);
        xx_chacha20_xor(&cx, buf + i, buf + i, 1);
    }

    for (i = 0; i < len; i++)
        buf[i] ^= (uint8_t) (i + 5);
}

static void do_vertical_mov(const uint8_t * input, uint64_t counter, uint8_t * buf, size_t len) {
    struct xx_chacha20 cx;
    size_t i, j, k;

    xx_chacha20_init(&cx, input, input + 32);

    for (i = 0; i < 64; i++) {
        for (j = 0; j < len; j += 64) {
            k = j + 63 - i;
            if (k < len) {
                xx_chacha20_seek(&cx, counter + (uint64_t) j / 64, 63 - i);
                xx_chacha20_xor(&cx, buf + k, NULL, 1);
            }
        }
    }
}

static void do_vertical_xor(const uint8_t * input, uint64_t counter, uint8_t * buf, size_t len) {
    struct xx_chacha20 cx;
    size_t i, j, k;

    for (i = 0; i < len; i++)
        buf[i] = (uint8_t) (i + 7);

    xx_chacha20_init(&cx, input, input + 32);

    for (i = 0; i < 64; i++) {
        for (j = 0; j < len; j += 64) {
            k = j + 63 - i;
            if (k < len) {
                xx_chacha20_seek(&cx, counter + (uint64_t) j / 64, 63 - i);
                xx_chacha20_xor(&cx, buf + k, buf + k, 1);
            }
        }
    }

    for (i = 0; i < len; i++)
        buf[i] ^= (uint8_t) (i + 7);
}

static void do_scaling_mov(const uint8_t * input, uint64_t counter, uint8_t * buf, size_t len) {
    struct xx_chacha20 cx;
    size_t i, j;

    xx_chacha20_init(&cx, input, input + 32);
    xx_chacha20_seek(&cx, counter, 0);

    for (i = 0, j = 0; i < len; i += j, j += 1)
        xx_chacha20_xor(&cx, buf+i, NULL, (j < len-i ? j : len-i));
}

static void do_scaling_xor(const uint8_t * input, uint64_t counter, uint8_t * buf, size_t len) {
    struct xx_chacha20 cx;
    size_t i, j;

    for (i = 0; i < len; i++)
        buf[i] = (uint8_t) (i + 11);

    xx_chacha20_init(&cx, input, input + 32);
    xx_chacha20_seek(&cx, counter, 0);

    for (i = 0, j = 0; i < len; i += j, j += 1)
        xx_chacha20_xor(&cx, buf + i, buf + i, (j < len-i ? j : len-i));

    for (i = 0; i < len; i++)
        buf[i] ^= (uint8_t) (i + 11);
}


static void (*methods[])(const uint8_t *, uint64_t, uint8_t *, size_t) = {
    do_simple_mov,
    do_simple_xor,
    do_piecemeal_mov,
    do_piecemeal_xor,
    do_seeking_mov,
    do_seeking_xor,
    do_vertical_mov,
    do_vertical_xor,
    do_scaling_mov,
    do_scaling_xor,
};


int xx__test_chacha20(void) {
    static uint8_t buf[4096];
    size_t len, i, j;

    for (i = 0; i < sizeof(tvs) / sizeof(tvs[0]); i++) {
        len = strlen(tvs[i].stream) / 2;

        for (j = 0; j < sizeof(methods) / sizeof(methods[0]); j++) {
            memset(buf, 0, len);
            methods[j](tvs[i].input, tvs[i].counter, buf, len);

            if (hexcmp(buf, tvs[i].stream, len) != 0)
                return -1;
        }
    }

    return 0;
}
