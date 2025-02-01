`timescale 1ns/1ps

module tb_top;
  import uvm_pkg::*;
  import spi_uvm_pkg::*;

  // Clock generation
  bit clk;
  bit reset_n;
  
  // Interface instantiation
  spi_interface intf(
    .clk(clk),
    .reset_n(reset_n),
    .cs_n(),
    .mosi(),
    .miso(),
    .sclk(),
    .mode(),
    .reg_addr(),
    .reg_write(),
    .reg_wdata(),
    .reg_rdata(),
    .ready()
  );

  // DUT instantiation
  spi_dut dut(
    .clk(intf.clk),
    .reset_n(intf.reset_n),
    .cs_n(intf.cs_n),
    .mosi(intf.mosi),
    .miso(intf.miso),
    .sclk(intf.sclk),
    .mode(intf.mode),
    .reg_addr(intf.reg_addr),
    .reg_write(intf.reg_write),
    .reg_wdata(intf.reg_wdata),
    .reg_rdata(intf.reg_rdata),
    .ready(intf.ready)
  );

  // Clock generator
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset generator
  initial begin
    reset_n = 0;
    #20 reset_n = 1;
  end

  // UVM initialization
  initial begin
    $timeformat(-9, 2, " ns", 10);
    $display("\n\n=== Starting SPI UVM Testbench ===");
    
    // Set interface in config DB
    uvm_config_db#(virtual spi_interface)::set(null, "*", "vif", intf);
    
    // Set default test if not specified
    if (!$test$plusargs("UVM_TESTNAME")) begin
      `uvm_info("TOP", "No test specified, running default test", UVM_MEDIUM)
      run_test("spi_full_test");
    end
    else begin
      run_test();
    end
    
    $display("\n=== Simulation Completed ===");
    $finish;
  end

  // Simulation timeout
  initial begin
    #100_000; // 100us timeout
    $display("Error: Simulation timeout!");
    $finish(2);
  end

endmodule : tb_top
