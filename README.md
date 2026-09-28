# lab1 — 32-bit Fibonacci Hardware Accelerator

A **VHDL-based Fibonacci number calculator** implemented as a hardware accelerator using a **Datapath + Finite State Machine (FSM)** architecture. Designed for the **Xilinx Zynq-7000** (Zybo board) using **Vivado 2021.1**.

## Overview

This project computes the **nth Fibonacci number** in hardware using a classic **FSMD (Finite State Machine with Datapath)** architecture. The design separates concerns into three layers:

1. **Datapath** — Handles all arithmetic, registers, and multiplexing
2. **FSM Controller** — Generates control signals based on state transitions
3. **FSMD (FSM + Datapath)** — Integrates both layers

The datapath implements a 32-bit computational unit with five registers (`n`, `i`, `x`, `y`, `result`), two adders, and multiplexers for data routing. The FSM orchestrates the computation through six states, managing loop control and termination.

## Architecture

### Datapath (`datapath.vhd`)

The datapath is a **32-bit synchronous circuit** that manages:

| Signal | Size | Purpose |
|--------|------|---------|
| `n` | 6-bit | Input: Fibonacci index (0–63) |
| `i` | 32-bit | Loop counter |
| `x` | 32-bit | Previous Fibonacci value (F(i-2)) |
| `y` | 32-bit | Current Fibonacci value (F(i-1)) |
| `result` | 32-bit | Final output |

**Control signals:**

| Control | Function |
|---------|----------|
| `n_en` / `x_en` / `y_en` / `i_en` / `result_en` | Register enable (load data) |
| `i_sel` | Select input for `i` register (incremented value or constant 2) |
| `x_sel` | Select input for `x` register (zero or value from `y`) |
| `y_sel` | Select input for `y` register (adder output or constant 1) |
| `result_sel` | Select output source (y register or zero) |

**Arithmetic units:**

- **i_adder**: `i + 1` (loop counter increment)
- **y_adder**: `x + y` (Fibonacci addition: F(i-2) + F(i-1))

**Comparison outputs:**

- `n_eq_0`: Asserted when input `n` is zero
- `i_le_n`: Asserted when loop counter ≤ input `n`

### FSM Controller (`fsm.vhd`)

A **three-process Mealy machine** with six states:

```
restart → start → init → if_cond → for_loop → complete → (back to restart)
```

| State | Description |
|-------|-------------|
| `restart` | Idle — waits for `go` signal to assert |
| `start` | Initial state — receives trigger, prepares for computation |
| `init` | Initializes registers: x=0, y=1, i=2 |
| `if_cond` | Checks if `n == 0` — if so, output x immediately |
| `for_loop` | Main loop: computes x+y, increments i, checks bounds |
| `complete` | Sets `done` signal, waits for `go` to deassert |

### FSMD Integration (`fib.vhd`)

Two architectures are provided:

1. **`fsmd`** — A single-process implementation combining FSM and datapath (with TODO comments for completion)
2. **`fsm_plus_d`** — A structured two-component approach that instantiates both `datapath` and `fsm` entities, connecting control and data signals

The `fsm_plus_d` architecture is the recommended implementation, demonstrating proper hardware modularity.

### Entity Interface

```vhdl
entity fib is
    port (
        clk    : in  std_logic;   -- Clock input
        rst    : in  std_logic;   -- Synchronous reset
        go     : in  std_logic;   -- Start computation trigger
        n      : in  std_logic_vector(5 downto 0);  -- Input: index
        result : out std_logic_vector(31 downto 0); -- Output: Fib(n)
        done   : out std_logic    -- Computation complete flag
    );
end fib;
```

### Computation Sequence

```
go='1' → n loaded → x=0, y=1, i=2
         ↓
    Check: n == 0? → Yes → result = x(=0), done='1'
         ↓ No
    Check: i > n? → Yes → result = y, done='1'
         ↓ No
    temp = x + y, x = y, i = i + 1
         ↓
    y = temp
         ↓
    (back to Check)
```

## Project Structure

```
lab1/
├── datapath.vhd   # 32-bit computational datapath with registers, adders, muxes
├── fib.vhd        # Top-level: FSMD and FSM+Datapath integrations
├── fsm.vhd        # FSM controller with 6 states
├── lab1.xpr       # Vivado 2021.1 project file
└── .gitignore     # Excludes Vivado build artifacts
```

## Building

### Prerequisites

- **Xilinx Vivado 2021.1** (or later)
- **VHDL-2008** language standard
- **Xilinx Zybo board** with **XC7Z020** FPGA (part: xc7z020clg484-1)

### Compilation Steps

1. Open Vivado and select **File → Open Project**
2. Open `lab1.xpr` from this directory
3. Select **Flow → Run Synthesis**
4. After synthesis, select **Flow → Run Implementation**
5. Generate bitstream with **Flow → Generate Bitstream**

### Device Configuration

| Parameter | Value |
|-----------|-------|
| Family | Artix-7 |
| Device | xc7z020clg484-1 |
| Package | CLG484 |
| Speed Grade | -1 |
| Vivado Version | 2021.1 |
| Top-level Entity | fib |

## Design Methodology

### FSMD Architecture

This project follows the **FSMD (Finite State Machine with Datapath)** design methodology, which is a standard approach in digital system design:

- **Control path** (FSM): Makes decisions, generates control signals
- **Data path**: Performs computations, stores state
- **Separation of concerns**: Makes the design modular, testable, and maintainable

### Register Transfer Level (RTL) Design

The implementation is fully **synchronous**, with all state changes occurring on the rising edge of the clock. Registers use **active-high enable** signals, and all arithmetic is performed using **unsigned** operations via `numeric_std`.

### Multiplexer Selection

Data flow through the datapath is controlled by **2:1 multiplexers** for each register, selected by control signals. This allows flexible data routing:

- `i_mux`: Choose between `i+1` (loop increment) or `2` (initialization)
- `x_mux`: Choose between `0` (reset) or `y` (Fibonacci swap)
- `y_mux`: Choose between `x+y` (Fibonacci sum) or `1` (initialization)
- `result_mux`: Choose between `y` (output) or `0` (zero)

## Fibonacci Sequence Reference

| n | Fib(n) |
|---|--------|
| 0 | 0 |
| 1 | 1 |
| 2 | 1 |
| 3 | 2 |
| 4 | 3 |
| 5 | 5 |
| 6 | 8 |
| 7 | 13 |
| 8 | 21 |
| 9 | 34 |
| 10 | 55 |
| 11 | 89 |
| 12 | 144 |
| 13 | 233 |
| 14 | 377 |
| 15 | 610 |
| 16 | 987 |

**Note:** The implementation computes `Fib(n)` for `n` in range [0, 63], but only 47 values fit in a 32-bit signed integer. Values beyond n=46 will overflow.

## VHDL Conventions

- **`ieee.std_logic_1164`** — Standard logic types
- **`ieee.numeric_std`** — Arithmetic operations (`unsigned`, `signed`)
- **Entity-architecture separation** — Clean interface specification
- **Signal naming** — `*_r` for register signals, `*_out` for mux outputs
- **State encoding** — Enumerated types (not binary) for readability

## References

- Xilinx Zynq-7000 SoC Technical Reference Manual
- IEEE 1076 VHDL Standard
- Vivado Design Suite User Guide
