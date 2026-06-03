# APB Slave Verification Using UVM

## Overview

This project implements the verification of an AMBA APB (Advanced Peripheral Bus) Slave using the Universal Verification Methodology (UVM). The objective is to verify APB protocol functionality through constrained-random stimulus generation, functional coverage, protocol checking, and scoreboard-based data validation.

## Project Objectives

* Verify APB write transactions.
* Verify APB read transactions.
* Check APB protocol compliance.
* Validate DUT functionality using a scoreboard.
* Measure verification completeness using functional coverage.

## APB Protocol

The APB protocol consists of three states:

### IDLE State

* PSEL = 0
* PENABLE = 0

### SETUP State

* PSEL = 1
* PENABLE = 0

### ACCESS State

* PSEL = 1
* PENABLE = 1
* Data transfer occurs.
* PREADY indicates transfer completion.

## Verification Environment Architecture

The UVM testbench consists of the following components:

### APB Transaction

Represents APB transfer information including:

* Address
* Write/Read Control
* Write Data
* Read Data
* Error Information

### APB Sequence

Generates:

* Write Transactions
* Read Transactions

### APB Sequencer

Controls the flow of sequence items to the driver.

### APB Driver

Drives APB protocol signals to the DUT through the virtual interface.

### APB Monitor

Observes DUT activity and converts pin-level activity into transaction-level objects.

### APB Agent

Contains:

* Driver
* Sequencer
* Monitor

### APB Scoreboard

Performs:

* Expected Data Generation
* Read/Write Data Comparison
* Error Detection

### APB Coverage

Collects:

* State Coverage
* Read/Write Coverage
* Address Coverage
* Data Coverage
* Cross Coverage

### APB Environment

Integrates:

* Agent
* Scoreboard
* Coverage

### APB Test

Creates and executes:

* Write Sequences
* Read Sequences

## DUT Features

The APB Slave DUT supports:

* 32-bit Address Bus
* 32-bit Data Bus
* Memory Array
* Read Operations
* Write Operations
* PREADY Generation
* PSLVERR Support

## Functional Coverage

Coverage includes:

### APB States

| State  | PSEL | PENABLE |
| ------ | ---- | ------- |
| IDLE   | 0    | 0       |
| SETUP  | 1    | 0       |
| ACCESS | 1    | 1       |

### Read/Write Operations

* Read Transactions
* Write Transactions

### Address Coverage

* Valid Address Space Coverage

### Data Coverage

* Data Pattern Coverage

### Cross Coverage

* State × Read/Write
* Address × Operation

## Simulation Flow

1. Sequence generates transactions.
2. Sequencer forwards transactions to driver.
3. Driver drives APB signals.
4. DUT processes requests.
5. Monitor captures APB activity.
6. Scoreboard validates results.
7. Coverage collector records protocol activity.

## Project Directory Structure

```text
project/
│
├── rtl/
│   └── AMBA_APB.sv
│
├── interface/
│   └── apb_inf.sv
│
├── transaction/
│   └── apb_transaction.sv
│
├── sequences/
│   ├── apb_write_sequence.sv
│   └── apb_read_sequence.sv
│
├── agent/
│   ├── apb_driver.sv
│   ├── apb_monitor.sv
│   ├── apb_sequencer.sv
│   └── apb_agent.sv
│
├── scoreboard/
│   └── apb_scoreboard.sv
│
├── coverage/
│   └── apb_coverage.sv
│
├── env/
│   └── apb_env.sv
│
├── tests/
│   └── apb_test.sv
│
└── top/
    └── top.sv
```

## Verification Features

* UVM 1.2 Based Testbench
* Constrained Random Verification
* Functional Coverage
* Protocol Monitoring
* Scoreboard Checking
* Reusable Verification Components
* APB Read/Write Verification

## Future Enhancements

* APB Error Injection
* APB Wait-State Verification
* APB Protocol Assertions (SVA)
* APB Coverage Closure Analysis
* APB-to-AHB Bridge Verification
* APB-to-AXI Bridge Verification

## Tools Used

* SystemVerilog
* UVM 1.2
* Synopsys VCS
* EDA Playground
* Verdi (Waveform Debug)

## Author

Madan Mohan

RTL Design and Verification Engineer

Focused on RTL Design, UVM Verification, AMBA Protocols, and RISC-V Verification.
