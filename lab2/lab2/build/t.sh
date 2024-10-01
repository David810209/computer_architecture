#!/bin/bash

# 檢查是否提供了參數
if [ $# -eq 0 ]; then
    echo "請提供一個代號來替換 'sw'。"
    exit 1
fi

# 變數設定
SW_PART=$1
VMH_FILE="riscv-$SW_PART.vmh"
STATS_FLAG=1
VCD_FLAG=1
DISASM_FLAG=1

# 執行測試命令
./riscvbyp-sim +stats=$STATS_FLAG +vcd=$VCD_FLAG +exe=../tests/build/vmh/$VMH_FILE +disasm=$DISASM_FLAG
