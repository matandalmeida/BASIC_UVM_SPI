`ifndef SPI_COVERAGE_SV
`define SPI_COVERAGE_SV

class spi_coverage extends uvm_subscriber #(spi_transaction);
    `uvm_component_utils(spi_coverage)
    
    covergroup spi_cg;
        // Mode and configuration
        cp_mode: coverpoint tr.mode {
            bins master = {1};
            bins slave = {0};
        }
        
        cp_clock_div: coverpoint tr.clock_div {
            bins div_low = {[1:5]};
            bins div_mid = {[6:15]};
            bins div_high = {[16:31]};
        }
        
        cp_data: coverpoint tr.data {
            bins zeros = {8'h00};
            bins ones = {8'hFF};
            bins low = {[8'h01:8'h7F]};
            bins high = {[8'h80:8'hFE]};
        }
        
        cp_data_transfer: coverpoint tr.received_data {
            bins zeros = {8'h00};
            bins ones = {8'hFF};
            bins low = {[8'h01:8'h7F]};
            bins high = {[8'h80:8'hFE]};
        }
        
        // Cross coverage
        cross_mode_data: cross cp_mode, cp_data;
        cross_mode_clock: cross cp_mode, cp_clock_div;
        
        // Timing coverage
        cp_duration: coverpoint tr.duration {
            bins short = {[0:100ns]};
            bins medium = {[101ns:500ns]};
            bins long = {[501ns:1000ns]};
        }
        
        // Error conditions
        cp_errors: coverpoint tr.error_code {
            bins no_error = {0};
            bins timeout = {1};
            bins invalid_reg = {2};
            illegal_bins others = default;
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        spi_cg = new;
    endfunction

    virtual function void write(spi_transaction t);
        tr = t;
        spi_cg.sample();
    endfunction

    virtual function real get_coverage();
        return spi_cg.get_inst_coverage();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info("COV", $sformatf("Cobertura Final: %0.2f%%", get_coverage()), UVM_MEDIUM)
        spi_cg.report();
    endfunction

    // Método para resetar a cobertura
    virtual function void reset();
        spi_cg.stop();
        spi_cg = new;
        spi_cg.start();
    endfunction

    // Variável local para armazenar transação
    local spi_transaction tr;
endclass

`endif // SPI_COVERAGE_SV
