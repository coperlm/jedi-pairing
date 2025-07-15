#include <iostream>
#include <cstdint>

#ifdef _WIN32
#include <windows.h>
#include <wincrypt.h>
#else
#include <unistd.h>
#include <sys/syscall.h>
#include <time.h>
#endif

extern "C" {
    void random_bytes(void* buffer, size_t len);
    uint64_t current_time_nanos(void);
}

void random_bytes(void* buffer, size_t len) {
#ifdef _WIN32
    HCRYPTPROV hProv;
    if (CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT)) {
        CryptGenRandom(hProv, (DWORD)len, (BYTE*)buffer);
        CryptReleaseContext(hProv, 0);
    }
#else
    syscall(SYS_getrandom, buffer, len, 0);
#endif
}

uint64_t current_time_nanos(void) {
#ifdef _WIN32
    LARGE_INTEGER frequency, counter;
    QueryPerformanceFrequency(&frequency);
    QueryPerformanceCounter(&counter);
    return (uint64_t)((double)counter.QuadPart * 1000000000.0 / frequency.QuadPart);
#else
    struct timespec tp;
    clock_gettime(CLOCK_MONOTONIC, &tp);

    uint64_t ts = ((uint64_t) 1000000000) * ((uint64_t) tp.tv_sec);
    ts += tp.tv_nsec;
    return ts;
#endif
}

int main() {
    std::cout << "jedi-pairing 库测试程序" << std::endl;
    
    // Test random number generation
    unsigned char random_bytes_buffer[16];
    random_bytes(random_bytes_buffer, 16);
    
    std::cout << "随机字节: ";
    for (int i = 0; i < 16; i++) {
        printf("%02x", random_bytes_buffer[i]);
    }
    std::cout << std::endl;
    
    // Test timing
    uint64_t start_time = current_time_nanos();
    uint64_t end_time = current_time_nanos();
    
    std::cout << "时间测试: " << (end_time - start_time) << " 纳秒" << std::endl;
    
    std::cout << "平台工具测试成功！" << std::endl;
    
    return 0;
}
