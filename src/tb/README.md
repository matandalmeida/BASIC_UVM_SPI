# SPI UVM Testbench

## Overview

This repository contains a UVM (Universal Verification Methodology) Testbench for verifying the SPI (Serial Peripheral Interface) Design Under Test (DUT) implemented in SystemVerilog. The goal of this Testbench is to provide a comprehensive verification environment that ensures the DUT's functionality in both Master and Slave modes. The UVM TB will automate the process of testing the SPI interface, validate its behavior, and ensure compliance with the SPI protocol as described in the DUT specifications.

## UVM Testbench Architecture

The UVM Testbench will consist of various components, including:

- **Test**: The top-level UVM component that coordinates the execution of the test.
- **Environment (env)**: Contains the test environment components, such as the agent and scoreboard.
- **Agent**: Responsible for driving and monitoring the SPI signals for both the Master and Slave.
- **Driver**: Drives the SPI signals (MOSI, SCLK, CS_N, etc.) to the DUT.
- **Monitor**: Observes the DUT's output signals (MISO, etc.) and checks the correctness of the SPI transactions.
- **Scoreboard**: Collects transaction data and performs result checking against the expected behavior.
- **Sequencer**: Generates sequences of SPI transactions for the DUT in a master-slave communication setup.
- **Sequence Items**: Represents the individual SPI transaction items (e.g., read/write operations).
- **Coverage**: Provides functional and code coverage to ensure that the testbenches adequately test all aspects of the DUT.

## Testbench Functionality

The UVM testbench will verify the SPI DUT across different scenarios, ensuring that the following functionalities are tested:

### 1. **SPI Master Mode**
- Verify that the DUT can properly generate the clock (`SCLK`) and send data to the slave (`MOSI`).
- Ensure that the DUT can receive data from the slave through the `MISO` line.
- Verify that the clock speed (`clk_div`) can be adjusted to different values and that the DUT correctly generates the clock at the specified frequency.
- Test multiple transactions with varying data, ensuring correct transmission and reception of bits.

### 2. **SPI Slave Mode**
- Ensure that the DUT can properly receive data from the master through the `MOSI` line and transmit data through the `MISO` line.
- Verify that the DUT responds correctly to the master's clock (`SCLK`), shifting data in and out as required.
- Test the DUT’s ability to handle multiple transactions and ensure correct data transmission in slave mode.

### 3. **Register Read/Write Operations**
- Verify that the DUT correctly handles read and write operations for its control and data registers (`ctrl_reg`, `data_in_reg`, `data_out_reg`, `clk_div_reg`).
- Ensure the DUT correctly updates its internal registers when writing data and returns the correct data when read.

### 4. **Edge Case Testing**
- Test edge cases such as:
  - Chip select (`CS_N`) being asserted and deasserted at different times.
  - Data transmission with corner cases, such as 0 or 255 values.
  - Handling of unexpected states, such as invalid register writes or simultaneous writes to multiple registers.
  
### 5. **SPI Protocol Compliance**
- Ensure that the DUT complies with the SPI protocol specifications:
  - Data transmission order (MSB first or LSB first, as specified).
  - Proper synchronization between the `SCLK` and `MOSI` signals.
  - Correct response on the `MISO` line when `CS_N` is active.
  
## Test Scenarios

The UVM Testbench will include multiple test scenarios to ensure thorough verification:

- **Basic Master to Slave Communication**: Simple communication where the master sends data to the slave and receives a response.
- **Slave to Master Communication**: Communication where the slave sends data to the master and receives a response.
- **Register Write/Read**: Verify that register values can be written and read correctly.
- **Clock Speed Variation**: Test the DUT with different clock speeds controlled by `clk_div_reg`.
- **Error Conditions**: Simulate errors such as invalid register addresses and incorrect data.

## Required UVM Components

To properly test the SPI DUT, the UVM Testbench will include the following components:

1. **SPI Agent**: This component will be responsible for both the master and slave behavior:
   - **Master Driver**: Will drive the SPI signals for the master.
   - **Slave Driver**: Will monitor and respond to SPI signals for the slave.
   
2. **Monitor**: A component that will observe the DUT's output signals and check the correctness of the SPI transactions. It will also report any errors and mismatches between expected and actual values.

3. **Scoreboard**: A scoreboard will track the transmitted and received data to ensure that the DUT is behaving correctly. It will compare the actual output against the expected values and report any discrepancies.

4. **Sequencer**: The sequencer will generate SPI transaction sequences for both the master and slave communication paths. It will ensure the DUT is tested across various valid and edge-case scenarios.

5. **Coverage Model**: A coverage model will track which parts of the DUT have been exercised during simulation, helping to ensure that all aspects of the SPI protocol are tested.

## Conclusion

This UVM Testbench will provide an effective and automated verification environment for the SPI DUT. The goal is to ensure that the DUT behaves as expected in both master and slave modes, handles various register operations correctly, and complies with the SPI protocol specifications. The TB will use UVM's powerful features, such as object-oriented programming, transaction-level modeling, and automated test generation, to provide comprehensive coverage and validation for the SPI interface.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
