#!/bin/bash

# 檢查是否提供了參數
if [ $# -eq 0 ]; then
    echo "請提供一個代號來替換 'sw'。"
    exit 1
fi

# 變數設定
SW_PART=$1
VCD_PATH="/mnt/c/zichen/ca/lab2/lab2/tests/build/vmh/riscv-$SW_PART.vcd"
STATS_FLAG=1
VCD_FLAG=1
DISASM_FLAG=1

# 執行測試命令
gtkwave VCD_PATH
