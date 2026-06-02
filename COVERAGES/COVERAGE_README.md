# APB Protocol Coverage Documentation

## Overview
This document describes the comprehensive coverage implementation for the APB (Advanced Peripheral Bus) protocol in your UVM testbench. Three complementary coverage classes have been created to ensure thorough verification of the APB protocol.

## Coverage Files

### 1. **apb_coverage.sv** - Signal-Level Coverage
This file contains signal-level and basic functional coverage for all APB protocol signals.

#### Covergroups:

- **cg_apb_address**
  - Covers address values across the full range (0-31)
  - Divides range into 4 bins: low (0-7), mid (8-15), high (16-23), top (24-31)

- **cg_apb_write_read**
  - Covers write operations (P_write = 1)
  - Covers read operations (P_write = 0)

- **cg_apb_wdata**
  - Covers write data patterns including:
    - All zeros (0x00000000)
    - All ones (0xFFFFFFFF)
    - Byte-level patterns
    - Word-level patterns
    - Random data

- **cg_apb_ready**
  - Covers P_ready signal high and low states

- **cg_apb_slverr**
  - Covers P_slverr signal for normal and error responses

- **cg_apb_states**
  - IDLE State: P_selx=0, P_enable=0
  - SETUP State: P_selx=1, P_enable=0
  - ACCESS State: P_selx=1, P_enable=1

- **cg_apb_addr_rw**
  - Cross coverage of address ranges with read/write operations

- **cg_apb_response**
  - Cross coverage of P_ready signal with read/write operations

- **cg_apb_data_patterns**
  - Covers specific data patterns:
    - Alternating patterns (0xAAAAAAAA, 0x55555555)
    - High/low byte patterns
    - Random patterns

- **cg_apb_addr_range_write**
  - Cross coverage of address ranges with write/read operations

### 2. **apb_functional_coverage.sv** - Functional Coverage
This file covers protocol phases, timing, and functional behaviors.

#### Covergroups:

- **cg_idle_phase**
  - Verifies IDLE phase occurs (P_selx=0, P_enable=0)

- **cg_setup_phase**
  - Verifies SETUP phase occurs (P_selx=1, P_enable=0)

- **cg_access_phase**
  - Verifies ACCESS phase occurs (P_selx=1, P_enable=1)
  - Crosses with write/read operations
  - Crosses with P_ready signal states

- **cg_reset_behavior**
  - Covers reset signal activation and deactivation

- **cg_slave_error**
  - Covers slave error response behavior

- **cg_transaction_timing**
  - Tracks consecutive ready signals
  - Bins: single transaction, double transaction, multiple transactions

- **cg_addr_stability**
  - Verifies address remains stable across cycles

- **cg_data_validity**
  - Covers valid read data when P_ready is asserted
  - Covers write data during write operations

- **cg_stimulus_space**
  - Comprehensive address × data pattern coverage
  - Includes all address ranges with multiple data patterns
  - Ignores read-only transactions

### 3. **apb_protocol_coverage.sv** - Protocol Requirements Coverage
This file covers APB protocol specifications and rules.

#### Protocol Rules Covered:

- **cg_apb_rule_1**: Device selection low in IDLE state
- **cg_apb_rule_3**: Address stability during SETUP and ACCESS phases
- **cg_apb_rule_4**: Write data valid during write transactions
- **cg_apb_rule_5**: Read data valid only when READY asserted
- **cg_apb_rule_6**: PSLVERR response (OK/ERROR)
- **cg_apb_rule_7**: Minimum 2-cycle operation (SETUP + ACCESS)

#### Additional Coverage:

- **cg_write_operations**
  - Write operations across all address ranges
  - Different write data patterns

- **cg_read_operations**
  - Read operations across all address ranges

- **cg_write_read_sequence**
  - Write followed by read to same address

- **cg_write_sequence**
  - Multiple writes to same address

- **cg_back_to_back**
  - Back-to-back transactions coverage

- **cg_signal_transitions**
  - All state transitions (0→0, 0→1, 1→0, 1→1)
  - For P_selx, P_enable, and P_ready signals

## Integration with Testbench

The coverage components are integrated in **Env.sv.sv**:

1. **apb_coverage** - Receives transactions from monitor
2. **apb_functional_coverage** - Monitors clock domain directly
3. **apb_protocol_coverage** - Receives transactions and monitors clock domain

Connection in Environment:
```systemverilog
agent.mon.mon_ap.connect(cov.ap_export);
agent.mon.mon_ap.connect(prot_cov.ap_export);
```

## Coverage Goals

### Recommended Coverage Targets:
- **100%** of signal bins coverage
- **100%** of state machine transitions
- **100%** of protocol rules
- **100%** of basic address ranges
- **95%+** of cross-functional coverage

## Running Coverage Collection

1. **Compile** all coverage files with your testbench
2. **Run** your test cases with coverage enabled
3. **Generate** coverage reports using your simulator:
   - VCS: `urg`, `dvecmp`, `dvemerge`
   - IUS: `iccr`, `icc`
   - Questasim: `vcover`

## Coverage Metrics to Monitor

### From apb_coverage.sv:
- Total address coverage
- Write vs Read operation balance
- Data pattern diversity

### From apb_functional_coverage.sv:
- Phase transition completeness
- Reset behavior verification
- Address stability confirmation

### From apb_protocol_coverage.sv:
- Protocol rule compliance (Rules 1-7)
- Transaction sequence diversity
- Signal timing verification

## Test Recommendations

To achieve high coverage, ensure your test sequences include:

1. **Address Coverage**
   - Access all address ranges (0-31)
   - Mix high and low addresses

2. **Data Patterns**
   - 0x00000000 (all zeros)
   - 0xFFFFFFFF (all ones)
   - 0xAAAAAAAA, 0x55555555 (alternating)
   - Random patterns

3. **Protocol Sequences**
   - Single read/write transactions
   - Back-to-back transactions
   - Write followed by read to same address
   - Multiple writes to same address

4. **Timing Variations**
   - 2-cycle transactions (minimum)
   - Longer transactions with wait states
   - Consecutive ready signals

5. **Error Conditions**
   - Slave error responses
   - Reset during transaction
   - Various abort scenarios

## Coverage Viewing

After simulation:
- Check coverage database (`.db` file)
- View coverage reports in HTML format
- Identify uncovered bins
- Create targeted tests to close coverage gaps

## Notes

- All covergroups use `option.per_instance = 1` for individual sampling
- Coverage is automatically collected during simulation
- No modifications needed to driver or monitor
- Coverage components run passively alongside scoreboard

---
**Version**: 1.0  
**Date**: June 2, 2026  
**Protocol**: APB v2
