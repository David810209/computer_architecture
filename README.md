
# Computer Architecture Labs

This repository contains the source code and lab reports for two key labs in computer architecture: a **5-Stage Pipelined RISC-V Processor with Bypassing** and an **Iterative Integer Multiply/Divide Unit**.

## Lab 1: Integer Multiply/Divide Unit

### Introduction
Lab 1 focuses on the design of an iterative integer multiply/divide unit that processes two 32-bit operands to produce a 64-bit result. This lab involves implementing both the multiplier and divider using an iterative approach, separating the control and datapath into distinct modules.

### Key Concepts
- Iterative algorithms for multiplication and division.
- Signed and unsigned operations.
- The val/rdy interface for latency-insensitive design.
- Unit testing and waveform analysis using `gtkwave`.

### Files
- `imuldiv-IntMulIterative.v`: Iterative multiplier.
- `imuldiv-IntDivIterative.v`: Iterative divider.
- `imuldiv-IntMulDivIterative.v`: Combined multiply/divide unit.
- Unit tests for each module in `*.t.v` files.

### How to Run
1. Extract the lab materials:
   ```bash
   tar -xf lab1.tar
   cd lab1
   export LAB1_ROOT=$PWD
   ```
2. Build the project:
   ```bash
   cd $LAB1_ROOT/build
   make
   ```
3. Run the simulators:
   ```bash
   ./imuldiv-singcyc-sim +op=mul +a=fe +b=9
   ./imuldiv-iterative-sim +op=div +a=fe +b=9
   ```
4. View the waveform:
   ```bash
   gtkwave imuldiv-IntMulDivSingleCycle.vcd &
   ```

## Lab 2: Pipelined RISC-V Processor with Bypassing

### Introduction
Lab 2 extends the concepts learned in Lab 1 by implementing a 5-stage pipelined RISC-V processor. The focus of this lab is to improve the base processor by adding bypassing mechanisms and integrating a pipelined multiply/divide unit.

### Key Concepts
- Pipelining and control hazards.
- Bypassing to improve pipeline performance.
- Stalling mechanisms and data forwarding.
- Integration of a pipelined multiply/divide unit.

### Files
- `riscvstall`: Pipelined RISC-V processor with stalling.
- `riscvbyp`: Pipelined RISC-V processor with bypassing.
- `riscvlong`: Pipelined processor with a pipelined multiply/divide unit.

### How to Run
1. Extract the lab materials:
   ```bash
   tar -xf lab2.tar
   cd lab2
   export LAB2_ROOT=$PWD
   ```
2. Build the project:
   ```bash
   cd $LAB2_ROOT/build
   make
   ```
3. Run assembly tests:
   ```bash
   make check-asm-riscvstall
   make check-asm-riscvbyp
   make check-asm-riscvlong
   ```

4. Compile and run benchmarks:
   ```bash
   make run-bmark-riscvstall
   ```
