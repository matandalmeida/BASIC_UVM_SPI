`ifndef SPI_UVM_PKG_SV
`define SPI_UVM_PKG_SV

`timescale 1ns/1ps

package spi_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Interface declaration
  `include "spi_interface.sv"

  // Transaction items
  `include "spi_transaction.sv"

  // Sequences
  `include "spi_sequences.sv"

  // UVM components
  `include "spi_driver.sv"
  `include "spi_monitor.sv"
  `include "spi_agent.sv"
  `include "spi_scoreboard.sv"
  `include "spi_refmod.sv"
  `include "spi_coverage.sv"
  `include "spi_env.sv"
  `include "spi_test.sv"

endpackage

`endif // SPI_UVM_PKG_SV
