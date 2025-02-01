// Arquivo: spi_interface.sv
interface spi_interface(input logic clk);
  logic       reset_n;
  logic       cs_n;
  logic       mosi;
  logic       miso;
  logic       sclk;
  logic       mode;
  logic [7:0] reg_addr;
  logic       reg_write;
  logic [7:0] reg_wdata;
  logic [7:0] reg_rdata;
  logic       ready;

  // Modports para Master e Slave
  modport master (output sclk, cs_n, input mosi, output miso);
  modport slave (input sclk, cs_n, mosi, output miso);

  // Clocking blocks para sincronização
  clocking cb_master @(posedge clk);
    output reset_n, cs_n, mosi, sclk, mode;
    input miso, ready, reg_rdata;
  endclocking

  clocking cb_slave @(posedge clk);
    input reset_n, cs_n, mosi, sclk, mode;
    output miso;
    input ready, reg_rdata;
  endclocking
endinterface
