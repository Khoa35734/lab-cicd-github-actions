#include <assert.h>
#include <limits.h>
#include <stdio.h>

int is_prime(int n);

int main(void)
{
    assert(is_prime(1) == 0);
    assert(is_prime(2) == 1);
    assert(is_prime(3) == 1);
    assert(is_prime(4) == 0);
    assert(is_prime(5) == 1);
    assert(INT_MAX == 2147483647);
    assert(is_prime(INT_MAX) == 1);

    printf("TẤT CẢ CÁC BÀI UNIT TEST ĐÃ VƯỢT QUA SẠCH LỖI!\n");
    return 0;
}
