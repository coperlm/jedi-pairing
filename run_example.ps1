# JEDI Pairing Library Go 示例运行脚本
# 使用方法: .\run_example.ps1

Write-Host "=== JEDI Pairing Library Go 示例 ===" -ForegroundColor Green
Write-Host ""

# 检查 Go 是否安装
Write-Host "检查 Go 环境..." -ForegroundColor Yellow
try {
    $goVersion = go version
    Write-Host "✓ Go 已安装: $goVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Go 未安装或未在 PATH 中" -ForegroundColor Red
    Write-Host "请访问 https://golang.org/dl/ 下载安装 Go" -ForegroundColor Red
    exit 1
}

# 检查 GCC 是否安装 (CGO 需要)
Write-Host "检查 C 编译器..." -ForegroundColor Yellow
try {
    $gccVersion = gcc --version | Select-Object -First 1
    Write-Host "✓ GCC 已安装: $gccVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ GCC 未安装或未在 PATH 中" -ForegroundColor Red
    Write-Host "请安装 MinGW-w64 或 TDM-GCC" -ForegroundColor Red
    Write-Host "MinGW-w64: https://www.mingw-w64.org/downloads/" -ForegroundColor Red
    exit 1
}

# 切换到项目目录
$projectDir = $PSScriptRoot
Write-Host "项目目录: $projectDir" -ForegroundColor Cyan
Set-Location $projectDir

# 构建 C 库
Write-Host ""
Write-Host "构建 C 库..." -ForegroundColor Yellow
try {
    make clean 2>$null
    make
    if ($LASTEXITCODE -ne 0) {
        throw "Make 构建失败"
    }
    Write-Host "✓ C 库构建成功" -ForegroundColor Green
} catch {
    Write-Host "✗ C 库构建失败: $_" -ForegroundColor Red
    Write-Host "请确保安装了 make 工具和 C 编译器" -ForegroundColor Red
    exit 1
}

# 初始化 Go 模块
Write-Host ""
Write-Host "初始化 Go 模块..." -ForegroundColor Yellow
try {
    go mod tidy
    Write-Host "✓ Go 模块初始化成功" -ForegroundColor Green
} catch {
    Write-Host "✗ Go 模块初始化失败: $_" -ForegroundColor Red
    exit 1
}

# 切换到示例目录
Set-Location "$projectDir\example"

# 初始化示例模块
Write-Host ""
Write-Host "初始化示例模块..." -ForegroundColor Yellow
try {
    go mod tidy
    Write-Host "✓ 示例模块初始化成功" -ForegroundColor Green
} catch {
    Write-Host "✗ 示例模块初始化失败: $_" -ForegroundColor Red
    exit 1
}

# 设置 CGO 环境变量
$env:CGO_ENABLED = "1"

# 运行示例
Write-Host ""
Write-Host "运行示例程序..." -ForegroundColor Yellow
Write-Host ""

try {
    go run main.go
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ 示例程序运行成功!" -ForegroundColor Green
    } else {
        throw "程序退出码: $LASTEXITCODE"
    }
} catch {
    Write-Host ""
    Write-Host "✗ 示例程序运行失败: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "故障排除建议:" -ForegroundColor Yellow
    Write-Host "1. 确保所有依赖都已正确安装" -ForegroundColor White
    Write-Host "2. 检查 C 库是否正确构建" -ForegroundColor White
    Write-Host "3. 确保 CGO_ENABLED=1" -ForegroundColor White
    Write-Host "4. 检查 PATH 中是否包含 GCC" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "=== 运行完成 ===" -ForegroundColor Green
