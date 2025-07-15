@echo off
cd /d "%~dp0"

echo ====================================
echo   jedi-pairing 测试脚本
echo ====================================
echo.

echo [1/3] 检查主库是否存在...
if not exist "..\pairing.a" (
    echo 错误: pairing.a 不存在，请先运行主目录的 build_windows.bat
    pause
    exit /b 1
)

echo [2/3] 编译简单测试程序...
g++ -std=c++17 -I../include -Ofast -DDISABLE_ASM -o simple_main.exe simple_main.cpp -ladvapi32
if %errorlevel% neq 0 (
    echo 错误: 编译失败！
    pause
    exit /b 1
)

echo [3/3] 运行测试程序...
echo.
echo === 测试输出 ===
.\simple_main.exe
echo === 测试完成 ===
echo.

if exist simple_main.exe (
    echo 成功! 测试程序运行完毕
) else (
    echo 错误: 测试程序未生成
)

echo.
echo 如需测试完整的密码学功能，请解决汇编依赖问题后运行:
echo   make
echo   .\test.exe
echo.
pause
