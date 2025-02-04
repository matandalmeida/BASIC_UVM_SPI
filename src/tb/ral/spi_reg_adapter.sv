`ifndef SPI_REG_ADAPTER_SV
`define SPI_REG_ADAPTER_SV

class spi_reg_adapter extends uvm_reg_adapter;
    `uvm_object_utils(spi_reg_adapter)

    function new(string name = "spi_reg_adapter");
        super.new(name);
    endfunction

    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        spi_reg_item req = spi_reg_item::type_id::create("req");
        req.addr = rw.addr;
        req.data = rw.data;
        req.kind = rw.kind == UVM_READ ? SPI_REG_READ : SPI_REG_WRITE;
        return req;
    endfunction

    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        spi_reg_item rsp;
        if (!$cast(rsp, bus_item)) begin
            `uvm_fatal("ADAPT", "Failed to cast bus_item")
        end
        rw.addr = rsp.addr;
        rw.data = rsp.data;
        rw.kind = rsp.kind == SPI_REG_READ ? UVM_READ : UVM_WRITE;
        rw.status = UVM_IS_OK;
    endfunction
endclass

`endif // SPI_REG_ADAPTER_SV
