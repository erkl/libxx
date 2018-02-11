At some point this will become a small library of selected cryptographic
primitives, but for the time being it serves as a home for a very fast x86-64
assembly implementation of the ChaCha20 stream cipher.

It's called libxx because the placeholder stuck.


### Building

The Makefile will use gcc to compile C files and nasm to assemble x86-64 code,
but there's no reason clang and yasm wouldn't work just as well. To build and
test the static library (written to `build/libxx.a`):

    make build
    make test


### License

MIT — see the [LICENSE](LICENSE) file.
