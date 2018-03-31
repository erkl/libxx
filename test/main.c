/* Copyright (c) 2018, Erik Lundin. */

int xx__test_chacha20(void);
int xx__test_hchacha20(void);


int main(int argc, const char ** argv) {
    if (xx__test_chacha20() != 0)
        return 1;
    if (xx__test_hchacha20() != 0)
        return 2;

    return 0;
}
