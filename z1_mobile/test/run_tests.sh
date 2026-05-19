#!/bin/bash
# Flutter 测试运行脚本

set -e

echo "======================================"
echo "Z1 Mobile 测试套件"
echo "======================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 flutter 命令
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}错误: 未找到 flutter 命令${NC}"
    exit 1
fi

# 切换到项目目录
cd "$(dirname "$0")"

# 解析参数
TEST_TYPE="${1:-all}"
COVERAGE="${2:-false}"

run_unit_tests() {
    echo -e "\n${YELLOW}运行单元测试...${NC}"
    flutter test test/unit/ --reporter compact
}

run_widget_tests() {
    echo -e "\n${YELLOW}运行 Widget 测试...${NC}"
    flutter test test/widget/ --reporter compact
}

run_all_tests() {
    echo -e "\n${YELLOW}运行所有测试...${NC}"
    flutter test --reporter compact
}

generate_coverage() {
    echo -e "\n${YELLOW}生成覆盖率报告...${NC}"
    flutter test --coverage
    genhtml coverage/lcov.info -o coverage/html
    echo -e "${GREEN}覆盖率报告已生成: coverage/html/index.html${NC}"
    open coverage/html/index.html 2>/dev/null || true
}

# 根据参数执行测试
case $TEST_TYPE in
    unit)
        run_unit_tests
        ;;
    widget)
        run_widget_tests
        ;;
    coverage)
        run_all_tests
        generate_coverage
        ;;
    all|*)
        run_all_tests
        if [ "$COVERAGE" = "coverage" ]; then
            generate_coverage
        fi
        ;;
esac

echo -e "\n${GREEN}测试完成!${NC}"