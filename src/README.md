# SRC DIR: SPI RTL and UVM Testbench

## Overview

This directory contains both the RTL (Register Transfer Level) design and the UVM (Universal Verification Methodology) testbench for a SPI (Serial Peripheral Interface) module.

- **RTL Module**: The SPI DUT (Design Under Test) is implemented in SystemVerilog, designed to support both Master and Slave modes of SPI communication.
- **UVM Testbench**: A UVM-based testbench environment to verify the functionality of the SPI module. The testbench covers the verification of various features of the SPI, such as data transmission, clock synchronization, and master/slave modes.

## SPI RTL Design

The SPI RTL design implements the following functionality:

- **SPI Master Mode**: The DUT generates the clock signal (`sclk`), drives data to the slave via the `mosi` line, and reads data from the slave via the `miso` line.
- **SPI Slave Mode**: The DUT listens for a clock signal (`sclk`), shifts in data via `mosi`, and sends data via the `miso` line to the master.
- **Register Interface**: Includes control, status, data input/output, and clock divider registers for configuring and monitoring the SPI communication.

### SPI Signals

- **clk**: The clock signal that drives the operation of the SPI interface.
- **reset_n**: Active-low reset signal for initializing the DUT.
- **cs_n**: Chip Select (CS) signal, active-low, used to select the slave device.
- **mosi**: Master Out Slave In. Used to send data from the master to the slave.
- **miso**: Master In Slave Out. Used to send data from the slave to the master.
- **sclk**: Serial Clock signal. Generated by the master and synchronizes data transmission.
- **mode**: Selects whether the DUT operates as a master (1) or slave (0).
- **reg_addr**: The register address for reading or writing SPI registers.
- **reg_write**: Active-high signal indicating a register write operation.
- **reg_wdata**: Data to write to the register.
- **reg_rdata**: Data read from the register.
- **ready**: Indicates whether the DUT is ready for the next operation (active-high).

## UVM Testbench

The UVM testbench is designed to verify the SPI functionality by simulating various communication scenarios between the master and slave modes. The testbench includes the following components:

- **UVM Environment**: Instantiates all the necessary verification components, including the SPI interface and UVM test.
- **UVM Test**: The main test that runs the verification sequences, applying stimuli and checking results.
- **UVM Scoreboard**: Compares the expected and actual behavior of the SPI DUT.
- **UVM Sequencer**: Generates and drives sequences of transactions for the SPI communication.

The testbench verifies multiple aspects of the SPI communication, including:
- Correct data transmission between the master and slave.
- Synchronization of data using the clock signal.
- Mode switching between master and slave.
- Error handling in the SPI protocol.

## Testbench Structure

The UVM testbench for SPI includes the following major blocks:

1. **SPI Interface**: Connects the DUT to the testbench components and encapsulates the SPI signals.
2. **UVM Environment**: Contains the setup for the test components, such as the UVM test, scoreboard, and sequencer.
3. **UVM Test**: Drives the verification by applying stimulus to the DUT and checking the results.
4. **UVM Scoreboard**: Checks that the SPI communication works as expected by comparing the received and expected data.

### Example of the Testbench Flow

- The UVM test generates sequences that drive the SPI signals, testing data transmission from master to slave and vice versa.
- The scoreboard ensures that the DUT produces the correct output, based on the data received and transmitted.
- Functional coverage is tracked to measure the completeness of the verification.

## Diagram of UVM Testbench

Below is a diagram illustrating the structure of the UVM testbench for the SPI verification:

# Top-Level Testbench Documentation

## Overview
This module serves as the root of the verification environment, integrating:
- Clock/Reset generation
- DUT instantiation
- UVM test harness
- Simulation control

## Architecture
```mermaid
graph TB
    TOP[tb_top] --> DUT[SPI Device]
    TOP --> UVM[UVM Environment]
    TOP --> CLK[Clock/Reset]
    UVM -->|Virtual Interface| DUT
```

## Conclusion

The SPI RTL module and its UVM testbench are designed to cover a comprehensive set of SPI functionality, including master/slave modes, data transmission, and clock synchronization. This testbench ensures that the SPI DUT behaves correctly and reliably, providing a solid foundation for verifying SPI communication in real-world designs.

