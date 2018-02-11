; Copyright (c) 2018, Erik Lundin.

%define VENDOR_AMD      (1 << 31)
%define VENDOR_INTEL    (1 << 30)

%define HAVE_SSE        (1 <<  0)
%define HAVE_SSE2       (1 <<  1)
%define HAVE_SSE3       (1 <<  2)
%define HAVE_SSSE3      (1 <<  3)
%define HAVE_SSE41      (1 <<  4)
%define HAVE_SSE42      (1 <<  5)
%define HAVE_SSE4A      (1 <<  6)
%define HAVE_AVX        (1 <<  7)
%define HAVE_XOP        (1 <<  8)
%define HAVE_AVX2       (1 <<  9)
%define HAVE_AVX512F    (1 << 10)
%define HAVE_AVX512VL   (1 << 11)

%define MASK_AVX        (HAVE_AVX | HAVE_XOP | HAVE_AVX2)
%define MASK_AVX512     (HAVE_AVX512F | HAVE_AVX512VL)
