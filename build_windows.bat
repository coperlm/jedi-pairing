@echo off
echo ====================================
echo   jedi-pairing Windows 构建脚本
echo ====================================
echo.

echo [1/4] 清理之前的构建文件...
if exist pairing.a del pairing.a
if exist bin rmdir /s /q bin 2>nul

echo [2/4] 创建构建目录...
mkdir bin\src\core\arch\x86_64 >nul 2>&1
mkdir bin\src\bls12_381 >nul 2>&1
mkdir bin\src\wkdibe >nul 2>&1
mkdir bin\src\lqibe >nul 2>&1

echo [3/4] 编译主库...
make
if %errorlevel% neq 0 (
    echo 错误: 主库编译失败！
    pause
    exit /b 1
)

echo [4/4] 检查生成的库文件...
if exist pairing.a (
    echo 成功! pairing.a 已生成
    dir pairing.a
) else (
    echo 错误: pairing.a 未生成
    pause
    exit /b 1
)

echo.
echo ====================================
echo   构建完成！
echo ====================================
echo.
echo 生成的文件:
echo   - pairing.a (主库文件)
echo.
echo 下一步:
echo   1. cd tests
echo   2. 编译测试程序: g++ -std=c++17 -I../include -Ofast -DDISABLE_ASM -o simple_main.exe simple_main.cpp -ladvapi32
echo   3. 运行测试: .\simple_main.exe
echo.
pause
