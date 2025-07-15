# jedi-pairing Windows 构建指南

## 项目简介

jedi-pairing 是一个高性能的配对密码学库，实现了 BLS12-381 椭圆曲线和相关的密码学算法。该库支持：

- **BLS12-381 椭圆曲线操作**
- **WKD-IBE (Wildcard Key-Derivation Identity-Based Encryption)**
- **LQIBE (Large-Universe Quantum-Safe Identity-Based Encryption)**
- **配对基础的数字签名**

## 架构说明

该项目采用三层语言架构：

1. **C++ 核心实现** (`src/` 目录)
   - 提供高性能的密码学原语
   - 包含架构特定的优化（x86_64, AArch64, ARMv6-M）
   - 实现有限域运算、椭圆曲线操作和配对计算

2. **C 语言兼容性包装** (`include/` 目录中的 `.h` 文件)
   - 为 C 语言项目提供接口
   - 保持与 C 语言的二进制兼容性

3. **Go 语言高级 API** (`lang/go/` 目录)
   - 提供更友好的 Go 语言接口
   - 包含序列化和反序列化功能
   - 适合应用层开发

## Windows 环境构建

### 前置要求

1. **MinGW-w64** 或其他 g++ 编译器
2. **make 工具** (可通过以下方式安装)：
   - MSYS2: `pacman -S make`
   - Chocolatey: `choco install make`
   - 或下载 GnuWin32 Make

### 构建步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/ucbrise/jedi-pairing.git
   cd jedi-pairing
   ```

2. **编译主库**
   ```bash
   make
   ```
   这将生成 `pairing.a` 静态库文件（约 490KB）。

3. **编译测试程序**
   ```bash
   cd tests
   make
   ```

### 当前状态

✅ **已完成功能**：
- 主库编译成功
- 平台兼容性修复（Windows API 支持）
- 基础工具函数（随机数生成、时间测量）
- Makefile Windows 适配

❌ **已知问题**：
- 完整测试程序链接失败（汇编优化依赖问题）
- 某些架构特定的汇编函数未能正确禁用

### 架构优化

项目包含以下架构的汇编优化：
- `src/core/arch/x86_64/` - x86_64 优化
- `src/core/arch/aarch64/` - ARM64 优化  
- `src/core/arch/armv6_m/` - ARM Cortex-M0+ 优化

**注意**：当前 Windows 构建中禁用了汇编优化 (`-DDISABLE_ASM`)，使用 C++ 回退实现。

## 使用示例

### 简单的平台测试

```cpp
#include <iostream>
#include <cstdint>

// 平台工具函数
extern "C" {
    void random_bytes(void* buffer, size_t len);
    uint64_t current_time_nanos(void);
}

int main() {
    // 生成随机字节
    unsigned char random_data[16];
    random_bytes(random_data, 16);
    
    // 时间测量
    uint64_t start = current_time_nanos();
    // ... 一些操作 ...
    uint64_t end = current_time_nanos();
    
    std::cout << "操作耗时: " << (end - start) << " 纳秒" << std::endl;
    return 0;
}
```

编译运行：
```bash
g++ -std=c++17 -I./include -Ofast -DDISABLE_ASM -o test main.cpp pairing.a -ladvapi32
./test.exe
```

### BLS12-381 基本操作（头文件引用）

```cpp
#include "bls12_381/bls12_381.h"
#include "bls12_381/fq.hpp"
#include "bls12_381/fr.hpp"
#include "bls12_381/curve.hpp"
#include "bls12_381/pairing.hpp"

// 使用 BLS12-381 曲线进行椭圆曲线操作
// 注意：完整示例需要解决汇编依赖问题
```

## 文件结构

```
jedi-pairing/
├── include/                 # 头文件
│   ├── bls12_381/          # BLS12-381 相关头文件
│   ├── core/               # 核心数学运算
│   ├── lqibe/              # LQIBE 算法
│   └── wkdibe/             # WKD-IBE 算法
├── src/                    # C++ 源代码
│   ├── bls12_381/          # BLS12-381 实现
│   ├── core/               # 核心实现
│   │   └── arch/           # 架构特定优化
│   ├── lqibe/              # LQIBE 实现
│   └── wkdibe/             # WKD-IBE 实现
├── lang/go/                # Go 语言绑定
├── tests/                  # 测试程序
├── Makefile               # 主构建文件
└── README_Windows.md      # 本文件
```

## 故障排除

### 编译错误

1. **"命令语法不正确"**
   - 确保使用的是兼容 Windows 的 make 工具
   - 检查 Makefile 中的路径分隔符

2. **汇编相关的未定义引用**
   - 确保使用了 `-DDISABLE_ASM` 标志
   - 如遇到问题，可能需要进一步修改源代码以完全禁用汇编

3. **链接错误 (advapi32)**
   - Windows 下需要链接 `advapi32.lib`：`-ladvapi32`

### 性能注意事项

- 当前 Windows 构建禁用了汇编优化，性能可能不如 Linux 版本
- 如需最佳性能，建议在支持的 Linux 环境下构建

## 开发状态

- **稳定性**: Beta 阶段
- **平台支持**: 
  - ✅ Linux (完全支持)
  - ⚠️ Windows (基础功能，汇编优化禁用)
  - ✅ 嵌入式 ARM (理论支持)

## 贡献

当前 Windows 适配的主要修改：
1. Makefile 跨平台兼容性
2. platform_utils.cpp Windows API 支持
3. 编译标志和依赖库调整

如需贡献代码或报告问题，请访问原项目仓库。

## 许可证

请参考项目根目录的 LICENSE.txt 文件。

---
**构建日期**: 2025年7月15日  
**测试环境**: Windows + MinGW-w64 + g++
