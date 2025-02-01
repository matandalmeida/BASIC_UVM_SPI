# SPI UVM Package Documentation

## Overview
This package contains all UVM components for SPI verification, providing a complete verification environment ready for integration.

## Package Structure
```systemverilog
spi_uvm_pkg/
├── spi_interface.sv       // Physical interface
├── spi_transaction.sv     // Transaction items
├── spi_sequences.sv       // Test sequences
├── spi_driver.sv          // Driver component
├── spi_monitor.sv         // Monitor component
├── spi_agent.sv           // Agent container
├── spi_scoreboard.sv      // Verification checker
├── spi_refmod.sv          // Reference model
├── spi_coverage.sv        // Coverage collector
├── spi_env.sv             // Test environment
└── spi_test.sv            // Test cases
```
