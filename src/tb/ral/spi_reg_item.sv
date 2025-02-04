`ifndef SPI_REG_ITEM_SV
`define SPI_REG_ITEM_SV

typedef enum {SPI_REG_READ, SPI_REG_WRITE} spi_reg_kind;

class spi_reg_item extends uvm_sequence_item;
    `uvm_object_utils_begin(spi_reg_item)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_enum(spi_reg_kind, kind, UVM_ALL_ON)
    `uvm_object_utils_end

    rand logic [7:0] addr;
    rand logic [7:0] data;
    rand spi_reg_kind kind;

    function new(string name = "spi_reg_item");
        super.new(name);
    endfunction
endclass

`endif // SPI_REG_ITEM_SV
