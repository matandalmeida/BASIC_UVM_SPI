interface spi_if(input logic clk, input logic reset_n);
    logic mosi;
    logic miso;
    logic cs_n;
    logic sclk;
    logic [7:0] data_in;
    logic [7:0] data_out;

    modport master(input clk, input reset_n, output mosi, input miso, output cs_n, output sclk);
    modport slave(input clk, input reset_n, input mosi, output miso, input cs_n, input sclk);
endinterface
