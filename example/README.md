# JEDI Pairing Library Go 示例

这个示例展示了如何使用 JEDI Pairing Library 的 Go 语言接口进行密码学运算。

## 功能演示

### 1. BLS12-381 双线性对运算
- 椭圆曲线群 G1、G2 运算
- 双线性对计算
- 群运算验证

### 2. 基于身份的加密 (LQ-IBE)
- 系统参数生成
- 基于身份的密钥提取
- 消息加密和解密

### 3. 弱密钥派生基于身份的加密 (WKD-IBE)
- 层次化身份加密
- 通配符匹配
- 属性基加密

## 环境要求

### Windows 系统要求
1. **Go 语言** (版本 1.21 或更高)
   - 下载地址: https://golang.org/dl/
   
2. **C 编译器** (支持 CGO)
   - 推荐: MinGW-w64
   - 下载地址: https://www.mingw-w64.org/downloads/
   - 或者 TDM-GCC: https://jmeubank.github.io/tdm-gcc/

3. **Make 工具**
   - 可以通过 MinGW-w64 或 Git Bash 获得

## 快速开始

### 方法 1: 使用 PowerShell 脚本

```powershell
# 在项目根目录执行
.\run_example.ps1
```

### 方法 2: 使用批处理文件

```cmd
# 在项目根目录执行
run_example.bat
```

### 方法 3: 手动执行

```powershell
# 1. 构建 C 库
make clean
make

# 2. 初始化 Go 模块
go mod tidy

# 3. 切换到示例目录
cd example
go mod tidy

# 4. 设置环境变量并运行
$env:CGO_ENABLED = "1"
go run main.go
```

## 示例输出

程序成功运行后，您将看到如下输出：

```
=== JEDI Pairing Library 示例 ===

1. BLS12-381 双线性对运算示例
随机标量1: 12345678901234567890...
随机标量2: 98765432109876543210...
✓ G1 群运算完成
✓ G2 群运算完成
✓ 双线性对运算完成
✓ 双线性对运算正确 (结果不相等，这是正常的)

2. 基于身份的加密 (LQ-IBE) 示例
✓ LQ-IBE 系统参数生成完成
用户身份: alice@example.com
✓ 用户私钥提取完成
原始消息: Hello, Identity-Based Encryption!
✓ 消息加密完成
解密消息: Hello, Identity-Based Encryption!
✓ LQ-IBE 加解密验证成功

3. 弱密钥派生基于身份的加密 (WKD-IBE) 示例
✓ WKD-IBE 系统参数生成完成
身份模式: [engineering security]
原始消息: Confidential: Project specifications
✓ WKD-IBE 消息加密完成
✓ WKD-IBE 私钥生成完成
解密消息: Confidential: Project specifications
✓ WKD-IBE 加解密验证成功

--- 通配符匹配演示 ---
✓ 通配符模式加密完成
通配符解密消息: Message for all engineering
```

## 故障排除

### 常见问题

1. **"go: cannot find module"**
   - 确保在正确的目录执行命令
   - 运行 `go mod tidy` 重新下载依赖

2. **"gcc: command not found"**
   - 安装 MinGW-w64 或 TDM-GCC
   - 确保 gcc 在 PATH 环境变量中

3. **"make: command not found"**
   - 通过 MinGW-w64 或 Git Bash 安装 make
   - 或者使用 PowerShell 中的 `mingw32-make`

4. **CGO 编译错误**
   - 确保设置 `CGO_ENABLED=1`
   - 检查 C 库是否正确构建
   - 验证头文件路径是否正确

5. **链接错误**
   - 确保 `pairing.a` 静态库已生成
   - 检查库文件路径是否正确

### 环境变量设置

在 PowerShell 中：
```powershell
$env:CGO_ENABLED = "1"
$env:PATH += ";C:\mingw64\bin"  # 根据实际安装路径调整
```

在 CMD 中：
```cmd
set CGO_ENABLED=1
set PATH=%PATH%;C:\mingw64\bin
```

## 代码结构说明

- `main.go` - 主示例程序
- `go.mod` - Go 模块依赖配置
- 依赖的包：
  - `github.com/ucbrise/jedi-pairing/lang/go/bls12381` - BLS12-381 双线性对
  - `github.com/ucbrise/jedi-pairing/lang/go/lqibe` - LQ-IBE 加密
  - `github.com/ucbrise/jedi-pairing/lang/go/wkdibe` - WKD-IBE 加密

## 更多信息

- BLS12-381 曲线: https://z.cash/blog/new-snark-curve/
- LQ-IBE 论文: http://cseweb.ucsd.edu/~mihir/cse208-06/libert-quisquater-ibe-acns-05.pdf
- WKD-IBE 论文: https://eprint.iacr.org/2007/221.pdf
