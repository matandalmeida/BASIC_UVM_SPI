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
