class spi_transaction extends uvm_sequence_item;
    rand bit [7:0] data;
    rand bit [7:0] received_data; // Added received_data
    rand int       clock_div;
    rand bit       mode;
    rand bit       lsb_first;
    rand time      duration;      // Added duration
    rand bit [1:0] error_code;    // Added error_code

    `uvm_object_utils_begin(spi_transaction)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(received_data, UVM_ALL_ON)
        `uvm_field_int(clock_div, UVM_ALL_ON)
        `uvm_field_int(mode, UVM_ALL_ON)
        `uvm_field_int(lsb_first, UVM_ALL_ON)
        `uvm_field_int(duration, UVM_ALL_ON)
        `uvm_field_int(error_code, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "spi_transaction");
        super.new(name);
    endfunction
endclass
