`ifndef SPI_REG_MODEL_SV
`define SPI_REG_MODEL_SV

class spi_ctrl_reg extends uvm_reg;
    `uvm_object_utils(spi_ctrl_reg)

    rand uvm_reg_field enable;
    rand uvm_reg_field mode;
    rand uvm_reg_field lsb_first;

    function new(string name = "spi_ctrl_reg");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        // Create fields
        enable = uvm_reg_field::type_id::create("enable");
        mode = uvm_reg_field::type_id::create("mode");
        lsb_first = uvm_reg_field::type_id::create("lsb_first");
        
        // Configure fields
        enable.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
        mode.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
        lsb_first.configure(this, 1, 2, "RW", 0, 1'b0, 1, 1, 0);
    endfunction
endclass

class spi_status_reg extends uvm_reg;
    `uvm_object_utils(spi_status_reg)

    uvm_reg_field ready;
    uvm_reg_field error;

    function new(string name = "spi_status_reg");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        ready = uvm_reg_field::type_id::create("ready");
        error = uvm_reg_field::type_id::create("error");
        
        ready.configure(this, 1, 0, "RO", 0, 1'b0, 1, 0, 0);
        error.configure(this, 1, 1, "RO", 0, 1'b0, 1, 0, 0);
    endfunction
endclass

class spi_reg_block extends uvm_reg_block;
    `uvm_object_utils(spi_reg_block)

    rand spi_ctrl_reg    ctrl;
    rand spi_status_reg  status;
    rand uvm_reg         data_in;
    rand uvm_reg         data_out;
    rand uvm_reg         clk_div;

    function new(string name = "spi_reg_block");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        // Create registers
        ctrl = spi_ctrl_reg::type_id::create("ctrl");
        ctrl.configure(this);
        ctrl.build();

        status = spi_status_reg::type_id::create("status");
        status.configure(this, null, "");
        status.build();

        data_in = uvm_reg::type_id::create("data_in");
        data_in.configure(this, null, "data_in");
        data_in.build();

        data_out = uvm_reg::type_id::create("data_out");
        data_out.configure(this, null, "data_out");
        data_out.build();

        clk_div = uvm_reg::type_id::create("clk_div");
        clk_div.configure(this, null, "clk_div");
        clk_div.build();

        // Map registers
        default_map = create_map("default_map", 0, 1, UVM_LITTLE_ENDIAN);
        default_map.add_reg(ctrl,    'h00, "RW");
        default_map.add_reg(status,  'h04, "RO");
        default_map.add_reg(data_in, 'h08, "WO");
        default_map.add_reg(data_out,'h0C, "RO");
        default_map.add_reg(clk_div, 'h10, "RW");

        lock_model();
    endfunction
endclass

`endif // SPI_REG_MODEL_SV
