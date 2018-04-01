# Hard-coding this kind of configuration is considered bad practice,
# but the alternatives are just terrible.

CC := gcc
AS := nasm
AR := ar
LD := gcc

CFLAGS  := -O3 -std=c89 -Wall -Wextra -Wno-unused-parameter -Wno-unused-function
ASFLAGS := -f elf64
ARFLAGS := rcs
LDFLAGS := -O3


# Prefix symbols when targeting macOS.
ifeq ($(shell uname -s), Darwin)
	ASFLAGS := -f macho64 --prefix _
endif


ifeq ($(shell uname -m), x86_64)
	LIB_OBJS := \
		build/src/x86-64/chacha/chacha-avx.o \
		build/src/x86-64/chacha/chacha-avx2.o \
		build/src/x86-64/chacha/chacha-sse2.o \
		build/src/x86-64/chacha/chacha-ssse3.o \
		build/src/x86-64/chacha/chacha-x64.o \
		build/src/x86-64/chacha/chacha-xop.o \
		build/src/x86-64/chacha/chacha.o \
		build/src/x86-64/chacha/hchacha-sse2.o \
		build/src/x86-64/chacha/hchacha-ssse3.o \
		build/src/x86-64/chacha/hchacha-x64.o \
		build/src/x86-64/chacha/hchacha-xop.o \
		build/src/x86-64/chacha/hchacha.o \
		build/src/x86-64/cpuid.o
else
	LIB_OBJS := \
		build/src/chacha.o
endif

TEST_OBJS := \
	build/test/test-chacha20.o \
	build/test/test-hchacha20.o \
	build/test/main.o


build: build/libxx.a
	@:

test: build/libxx-test
	@./build/libxx-test

install: build/libxx.a
	@cp -R include /usr/local/include/xx
	@cp build/libxx.a /usr/local/lib/libxx.a

clean:
	@rm -rf build/*

.PHONY: build test install clean


# If the Makefile changes, reset everything.
build/make-tag: Makefile
	@mkdir -p $(shell dirname $@)
	@rm -rf build/*
	@touch $@


build/libxx.a: build/make-tag $(LIB_OBJS)
	@$(AR) $(ARFLAGS) $@ $(LIB_OBJS)

build/libxx-test: build/make-tag build/libxx.a $(TEST_OBJS)
	@mkdir -p $(shell dirname $@)
	@$(LD) $(LDFLAGS) -o $@ $(TEST_OBJS) build/libxx.a

build/src/x86-64/%.o: src/x86-64/%.s
	@mkdir -p $(shell dirname $@)
	@$(AS) $(ASFLAGS) -MD $(@:.o=.d) -I. -o $@ $<

build/%.o: %.c
	@mkdir -p $(shell dirname $@)
	@$(CC) $(CFLAGS) -MMD -MF $(@:.o=.d) -I. -c -o $@ $<


-include $(LIB_OBJS:%.o=%.d)
-include $(TEST_OBJS:%.o=%.d)
