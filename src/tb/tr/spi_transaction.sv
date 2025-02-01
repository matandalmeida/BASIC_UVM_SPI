// Arquivo: spi_transaction.sv
class spi_transaction extends uvm_sequence_item;
  rand bit [7:0] data;
  rand int       clock_div;
  rand bit       mode;       // 0: Slave, 1: Master
  rand bit       lsb_first;

  `uvm_object_utils_begin(spi_transaction)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(clock_div, UVM_ALL_ON)
    `uvm_field_int(mode, UVM_ALL_ON)
    `uvm_field_int(lsb_first, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "spi_transaction");
    super.new(name);
  endfunction
endclass
