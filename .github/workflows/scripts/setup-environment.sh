#!/bin/bash
# GitHub Actions环境设置脚本

set -e

echo "Setting up build environment for $RUNNER_OS..."

case "$RUNNER_OS" in
    "Linux")
        sudo apt-get update
        sudo apt-get install -y build-essential make gcc
        ;;
    "macOS")
        brew update
        brew install make gcc
        ;;
    "Windows")
        # Windows通常已包含必要的构建工具
        echo "Windows environment - assuming build tools are available"
        ;;
esac

echo "Environment setup completed"