@echo off
echo === JEDI Pairing Library Go 示例 ===
echo.

echo 检查 Go 环境...
go version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: Go 未安装或未在 PATH 中
    echo 请访问 https://golang.org/dl/ 下载安装 Go
    pause
    exit /b 1
)
echo ✓ Go 已安装

echo 检查 C++ 编译器...
c++ --version >nul 2>&1
if %errorlevel% neq 0 (
    gcc --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo 错误: C++ 编译器未安装或未在 PATH 中
        echo 请安装 MinGW-w64 或 TDM-GCC
        pause
        exit /b 1
    )
    echo ✓ GCC 已安装
) else (
    echo ✓ C++ 编译器已安装
)

echo.
echo 检查 C 库...
if exist pairing.a (
    echo ✓ 发现预构建的 C 库
    echo 复制库文件到 Go 包目录...
    copy pairing.a lang\go\bls12381\pairing.a >nul
    copy pairing.a lang\go\lqibe\pairing.a >nul
    copy pairing.a lang\go\wkdibe\pairing.a >nul
    copy pairing.a lang\go\internal\pairing.a >nul
    copy pairing.a lang\go\cryptutils\pairing.a >nul
    echo ✓ 库文件复制完成
) else (
    echo 构建 C 库...
    echo 创建构建目录...
    if not exist "bin\src\bls12_381" mkdir "bin\src\bls12_381"
    if not exist "bin\src\lqibe" mkdir "bin\src\lqibe"
    if not exist "bin\src\wkdibe" mkdir "bin\src\wkdibe"
    if not exist "bin\src\core\arch\x86_64" mkdir "bin\src\core\arch\x86_64"

    echo 编译 BLS12-381 源文件...
    for %%f in (src\bls12_381\*.cpp) do (
        echo 编译 %%f...
        c++ -std=c++17 -I./include -O2 -c "%%f" -o "bin\%%~nf.o"
        if %errorlevel% neq 0 (
            echo 错误: 编译 %%f 失败
            pause
            exit /b 1
        )
    )

    echo 编译 LQIBE 源文件...
    for %%f in (src\lqibe\*.cpp) do (
        echo 编译 %%f...
        c++ -std=c++17 -I./include -O2 -c "%%f" -o "bin\%%~nf.o"
        if %errorlevel% neq 0 (
            echo 错误: 编译 %%f 失败
            pause
            exit /b 1
        )
    )

    echo 编译 WKDIBE 源文件...
    for %%f in (src\wkdibe\*.cpp) do (
        echo 编译 %%f...
        c++ -std=c++17 -I./include -O2 -c "%%f" -o "bin\%%~nf.o"
        if %errorlevel% neq 0 (
            echo 错误: 编译 %%f 失败
            pause
            exit /b 1
        )
    )

    echo 编译 x86_64 架构相关源文件...
    if exist src\core\arch\x86_64\*.cpp (
        for %%f in (src\core\arch\x86_64\*.cpp) do (
            echo 编译 %%f...
            c++ -std=c++17 -I./include -O2 -c "%%f" -o "bin\%%~nf.o"
            if %errorlevel% neq 0 (
                echo 错误: 编译 %%f 失败
                pause
                exit /b 1
            )
        )
    )

    echo 创建静态库...
    ar rcs pairing.a bin\*.o
    if %errorlevel% neq 0 (
        echo 错误: 创建静态库失败
        pause
        exit /b 1
    )
    
    echo 复制库文件到 Go 包目录...
    copy pairing.a lang\go\bls12381\pairing.a >nul
    copy pairing.a lang\go\lqibe\pairing.a >nul
    copy pairing.a lang\go\wkdibe\pairing.a >nul
    copy pairing.a lang\go\internal\pairing.a >nul
    copy pairing.a lang\go\cryptutils\pairing.a >nul
    echo ✓ C 库构建成功
)

echo.
echo 初始化 Go 模块...
go mod tidy
if %errorlevel% neq 0 (
    echo 错误: Go 模块初始化失败
    pause
    exit /b 1
)
echo ✓ Go 模块初始化成功

echo.
echo 切换到示例目录...
cd example

echo 初始化示例模块...
go mod tidy
if %errorlevel% neq 0 (
    echo 错误: 示例模块初始化失败
    pause
    exit /b 1
)
echo ✓ 示例模块初始化成功

echo.
echo 运行示例程序...
echo.

set CGO_ENABLED=1
go run main.go

if %errorlevel% equ 0 (
    echo.
    echo ^> Example program ran successfully!
    echo.
    echo Features demonstrated:
    echo 1. BLS12-381 bilinear pairing operations
    echo 2. Identity-Based Encryption (LQ-IBE)
    echo 3. Wildcarded Key-Derivation Identity-Based Encryption (WKD-IBE)
) else (
    echo.
    echo ^> Example program failed
    echo.
    echo Troubleshooting suggestions:
    echo 1. Ensure all dependencies are correctly installed
    echo 2. Check if C library was built correctly
    echo 3. Make sure CGO_ENABLED=1
    echo 4. Check if C++ compiler is in PATH
)

echo.
echo === Example completed ===
pause
