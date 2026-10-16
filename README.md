# Fibonacci Hardware Accelerator — 32-bit FSMD on Zynq-7000

VHDL implementation of a hardware accelerator computing Fibonacci numbers using a Finite State Machine Datapath (FSMD) architecture. Built for Xilinx Zynq-7000.

## Overview

This project implements a complete Fibonacci number calculator in hardware using a dataflow approach with explicit state control. The accelerator accepts a 32-bit index input and produces the corresponding Fibonacci number via a datapath with a 13-state control FSM.

## Project Structure

| File | Description |
|------|-------------|
| `datapath.vhd` | Arithmetic datapath: 32-bit adders, registers, and shifters |
| `fsm.vhd` | 13-state control FSM managing dataflow sequencing |

## Hardware

- **Device:** Xilinx Zynq-7000 XC7Z020 (xc7z020clg484-1)
- **Tool:** Vivado 2021.1
- **Language:** VHDL-2008

## Architecture

The design uses a classic FSMD (Finite State Machine Datapath) approach:

- The **datapath** contains three 32-bit registers (A, B, i), a 32-bit adder, and a shifter
- The **FSM** controls register load/select operations through 13 states: initialization, iteration loop, result capture, and output
- Fibonacci computation: F(n) = F(n-1) + F(n-2), computed iteratively in hardware

## Building

1. Open `lab1.xpr` in Vivado
2. Add constraints file (XDC) for the ZedBoard pinout
3. Run Synthesis and Implementation
4. Generate bitstream and download to ZedBoard
