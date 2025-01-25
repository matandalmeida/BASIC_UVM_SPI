# SPI Verification Environment in UVM

## Introduction

This repository contains the UVM-based testbench environment for verifying the SPI (Serial Peripheral Interface) Design Under Test (DUT). The DUT implements both master and slave modes for SPI communication, and the testbench verifies its functionality using a SystemVerilog interface to model and connect the signals.

## What is an Interface in SystemVerilog?

An Interface in SystemVerilog is a way to encapsulate related signals into a block, providing a structured approach to managing multiple signals. Interfaces allow grouping signals together, simplifying the connection to the Design Under Test (DUT) and other components in the verification environment. This encapsulation enables reusability and improves modularity.

Interfaces define the communication links between components, and the signals within an interface are typically grouped based on their functionality. The use of interfaces enhances maintainability and scalability of verification environments by keeping signal groupings organized.

## Defining Signal Directions Using Modports

Interface signals can be utilized in both the DUT and verification components. To manage different signal directions (input, output), modports are used. Modports allow defining the direction for each signal in the interface based on the component interacting with it.

For instance, a modport is defined for master-mode signals, and a different modport for slave-mode signals. This enables clear separation of the signal direction and ensures that signals are passed correctly between the components.

## Creating and Connecting the Interface to the DUT

In the top-level testbench module, an interface object is instantiated and passed to the DUT. The correct modport must be assigned to ensure that the DUT receives the correct direction of signals.

For example, when the DUT operates in Master Mode, the interface signals are passed with the master modport, and when the DUT operates in Slave Mode, the interface signals are passed with the slave modport. This approach simplifies the connection and ensures that each component in the verification environment receives the correct signals.

```systemverilog
// SPI Interface Definition
interface spi_if(input logic clk, reset_n);
    // SPI signals
    logic cs_n;
    logic mosi;
    logic sclk;
    logic mode;
    logic [7:0] reg_addr;
    logic reg_write;
    logic [7:0] reg_wdata;
    logic [7:0] reg_rdata;
    logic miso;
    logic ready;

    // Modports for Master and Slave
    modport master(input clk, reset_n, cs_n, mosi, sclk, mode, reg_addr, reg_write, reg_wdata, output reg_rdata, miso, ready);
    modport slave(input clk, reset_n, cs_n, sclk, mode, reg_addr, reg_write, reg_wdata, output reg_rdata, mosi, miso, ready);
endinterface
