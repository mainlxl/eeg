#!/bin/bash

# 上肢运动-认知协同康复训练及评估系统 - macOS DMG 构建脚本
# 作者: AI助手
# 创建时间: $(date)

echo "========================================"
echo "上肢运动-认知协同康复训练及评估系统"
echo "macOS DMG 构建脚本"
echo "========================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "命令 '$1' 未安装，请先安装"
        return 1
    fi
    return 0
}

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    # 检查Flutter
    if ! check_command "flutter"; then
        log_error "Flutter 未安装，请先安装Flutter"
        return 1
    fi
    
    # 检查create-dmg
    if ! check_command "create-dmg"; then
        log_error "create-dmg 未安装，请使用以下命令安装:"
        echo "brew install create-dmg"
        return 1
    fi
    
    log_success "所有依赖检查通过"
    return 0
}

# 清理之前的构建
clean_previous_build() {
    log_info "清理之前的构建文件..."
    clean_previous_build_dmg
    # 清理Flutter构建缓存
    flutter clean
    log_success "构建缓存清理完成"
}

clean_previous_build_dmg() {
    # 删除所有带版本号的DMG文件
    local dmg_files=$(find . -name "上肢运动-认知协同康复训练及评估系统-v*.dmg" -type f)
    if [ -n "$dmg_files" ]; then
        log_info "找到以下DMG文件需要清理:"
        echo "$dmg_files"
        rm $dmg_files
        log_success "已删除所有旧的DMG文件"
    else
        log_info "未找到需要清理的DMG文件"
    fi

    # 清理不带版本号的旧DMG文件（兼容旧版本）
    if [ -f "上肢运动-认知协同康复训练及评估系统.dmg" ]; then
        rm "上肢运动-认知协同康复训练及评估系统.dmg"
        log_info "已删除不带版本号的旧DMG文件"
    fi
}
# 构建Flutter应用
build_flutter_app() {
    log_info "构建Flutter macOS应用..."
    
    if flutter build macos --release; then
        log_success "Flutter应用构建成功"
        return 0
    else
        log_error "Flutter应用构建失败"
        return 1
    fi
}

# 获取版本号
get_version() {
    local version=$(grep -E "version: " pubspec.yaml | sed 's/version: //' | tr -d ' ')
    echo "$version"
}

# 创建DMG文件
create_dmg_file() {
    log_info "创建DMG安装包..."
    local version=$(get_version)
    local app_path="build/macos/Build/Products/Release/上肢运动-认知协同康复训练及评估系统.app"
    local dmg_name="上肢运动-认知协同康复训练及评估系统-v${version}.dmg"
    
    # 检查应用文件是否存在
    if [ ! -d "$app_path" ]; then
        log_error "应用文件不存在: $app_path"
        return 1
    fi
    
    # 检查图标文件是否存在
    if [ ! -f "macos/Runner/Runner.icns" ]; then
        log_warning "图标文件不存在，使用默认设置"
        local volicon_option=""
    else
        local volicon_option="--volicon macos/Runner/Runner.icns"
    fi
    
    # 检查背景图片是否存在
    if [ ! -f "images/background/login.png" ]; then
        log_warning "背景图片不存在，使用默认设置"
        local background_option=""
    else
        local background_option="--background images/background/login.png"
    fi
    
    # 创建DMG文件
    create-dmg \
        --volname "上肢运动-认知协同康复训练及评估系统 v${version}" \
        $volicon_option \
        $background_option \
        --window-pos 200 120 \
        --window-size 720 406 \
        --no-internet-enable \
        --hdiutil-quiet \
        --icon-size 100 \
        --icon "上肢运动-认知协同康复训练及评估系统.app" 200 190 \
        --hide-extension "上肢运动-认知协同康复训练及评估系统.app" \
        --app-drop-link 600 185 \
        "$dmg_name" \
        "$app_path"
    
    if [ $? -eq 0 ] && [ -f "$dmg_name" ]; then
        log_success "DMG文件创建成功: $dmg_name"
        
        # 显示DMG文件信息
        local dmg_size=$(du -h "$dmg_name" | cut -f1)
        log_info "DMG文件大小: $dmg_size"
        
        return 0
    else
        log_error "DMG文件创建失败"
        return 1
    fi
}

# 仅创建DMG文件（不重新构建应用）
create_dmg_only() {
    log_info "仅创建DMG文件（跳过应用构建）..."
    
    # 检查依赖
    if ! check_dependencies; then
        return 1
    fi
    
    # 创建DMG
    if ! create_dmg_file; then
        return 1
    fi
    
    log_success "DMG创建完成！"
}

# 主构建函数
main() {
    log_info "开始构建流程..."
    local version=$(get_version)
    
    # 显示版本信息
    log_info "当前版本: $version"
    
    # 检查依赖
    if ! check_dependencies; then
        return 1
    fi

    # 清理构建
    clean_previous_build

    # 构建应用
    if ! build_flutter_app; then
        return 1
    fi

    # 创建DMG
    if ! create_dmg_file; then
        return 1
    fi
    
    log_success "构建流程完成！"
    echo ""
    echo "========================================"
    echo "构建结果:"
    echo "- 版本号: $version"
    echo "- DMG文件: 上肢运动-认知协同康复训练及评估系统-v${version}.dmg"
    echo "- 应用路径: build/macos/Build/Products/Release/"
    echo "========================================"
}

# 显示版本信息
show_version() {
    local version=$(get_version)
    echo "上肢运动-认知协同康复训练及评估系统"
    echo "版本: $version"
}

# 处理命令行参数
case "${1:-}" in
    "--help" | "-h")
        echo "用法: $0 [选项]"
        echo ""
        echo "选项:"
        echo "  --help, -h         显示此帮助信息"
        echo "  --version, -v     显示版本信息"
        echo "  --clean-only       仅清理构建缓存"
        echo "  --build-only       仅构建Flutter应用（不创建DMG）"
        echo "  --dmg-only         仅创建DMG文件（不重新构建应用）"
        echo ""
        echo "示例:"
        echo "  $0                完整构建流程"
        echo "  $0 --dmg-only     仅创建DMG（快速打包）"
        echo "  $0 --build-only   仅构建应用"
        echo "  $0 --clean-only   仅清理缓存"
        echo ""
        exit 0
        ;;
    "--version" | "-v")
        show_version
        ;;
    "--clean-only")
        clean_previous_build
        ;;
    "--build-only")
        check_dependencies && build_flutter_app
        ;;
    "--dmg-only")
        clean_previous_build_dmg && create_dmg_only
        ;;
    *)
        # 完整构建流程
        main
        ;;
esac