# Washing Machine Controller - VHDL Implementation

## Problem Statement

Design a washing machine controller with four operational states that cycle automatically. The system must use precise timing control with a 20 Hz clock and provide visual feedback through LED outputs.

### Requirements

**States and Timing:**
- FILL: 3 seconds
- WASH: 5 seconds  
- RINSE: 2 seconds
- SPIN: 4 seconds

**Inputs:**
- Clock: 20 Hz (50ms period)
- Reset: Active low asynchronous reset
- Enable: Active high clock enable

**Outputs:**
- 4 LEDs indicating current state (one LED per state)

## Solution Design

### Architecture Overview

The design implements a finite state machine with the following components:

**State Machine Logic:**
- Four states with automatic progression: FILL → WASH → RINSE → SPIN → FILL
- Counter-based timing using clock cycles (20 Hz = 20 cycles per second)
- Synchronous state transitions with asynchronous reset

**Timing Implementation:**
- FILL state: 60 clock cycles (3 sec × 20 Hz)
- WASH state: 100 clock cycles (5 sec × 20 Hz)
- RINSE state: 40 clock cycles (2 sec × 20 Hz)
- SPIN state: 80 clock cycles (4 sec × 20 Hz)

**Output Encoding:**
- FILL: LEDs = 0001 (LED0 active)
- WASH: LEDs = 0010 (LED1 active)
- RINSE: LEDs = 0100 (LED2 active)
- SPIN: LEDs = 1000 (LED3 active)

### Key Design Features

**Counter Management:**
The internal counter increments on each clock cycle when enabled. When a state's time limit is reached, the state machine transitions to the next state and resets the counter to zero.

**Reset Behavior:**
The active-low asynchronous reset immediately places the system in FILL state regardless of current operation, ensuring a known starting point.

**Clock Enable:**
When the enable signal is low, the state machine freezes in its current state. This allows external control of the washing cycle without losing state information.

## Testbench Verification

The testbench performs comprehensive verification of all system requirements:

**Test Coverage:**
- Reset functionality verification
- State duration timing checks  
- State transition validation
- LED output correctness
- Clock enable functionality
- Full cycle completion (return to FILL after SPIN)

**Test Methodology:**
Self-checking assertions automatically verify correct behavior at each stage. The testbench reports pass/fail status for each test case with detailed feedback.

## Implementation Files

**washing_machine_controller.vhd** - Main design entity implementing the state machine, counter logic, and output generation.

**washing_machine_tb.vhd** - Comprehensive testbench with automated verification and detailed reporting of test results.

## Simulation Instructions

### Using GHDL (Recommended)

GHDL is a free, open-source VHDL simulator that requires no licensing.

**Installation:**
```bash
sudo apt-get install ghdl gtkwave
```

**Compilation and Simulation:**
```bash
# Compile design files
ghdl -a washing_machine_controller.vhd
ghdl -a washing_machine_tb.vhd

# Elaborate testbench
ghdl -e washing_machine_tb

# Run simulation
ghdl -r washing_machine_tb

# Generate waveform file
ghdl -r washing_machine_tb --vcd=waveform.vcd

# View waveform
gtkwave waveform.vcd
```

### Using ModelSim/Questa

If you have access to ModelSim or Questa with proper licensing:

**Simple One-Command Simulation:**
```bash
# Run everything with DO script
vsim -do run_sim.do
```

This will automatically compile files, start simulation, add waveforms, and run for 15 seconds.

**Manual Compilation and Simulation:**
```bash
# Create work library
vlib work

# Compile source files
vcom washing_machine_controller.vhd
vcom washing_machine_tb.vhd

# Run simulation (command line)
vsim -c work.washing_machine_tb -do "run 15 sec; quit"

# Run simulation (GUI)
vsim work.washing_machine_tb
# In GUI: add wave *, run 15 sec
```

## Expected Results

**Console Output:**
The testbench reports detailed test results including:
- Reset test verification
- Individual state timing verification
- Transition correctness
- Clock enable functionality
- Overall test summary

**Waveform Verification Points:**
- LEDs change at correct time intervals
- Counter resets on state transitions
- System returns to FILL after completing SPIN
- Enable signal properly controls state machine
- Reset immediately returns to FILL state

## Design Validation

The solution meets all laboratory requirements:
- Correct state durations with 20 Hz clock
- Proper LED indication for each state
- Active-low asynchronous reset functionality
- Active-high clock enable control
- Automatic cycling through all states
- Comprehensive self-checking testbench

Total cycle time is 14 seconds (3+5+2+4), after which the system automatically returns to FILL state to begin a new washing cycle.
