`ifndef SPI_REFMOD_SV
`define SPI_REFMOD_SV

class spi_refmod extends uvm_component;
    `uvm_component_utils(spi_refmod)
    
    uvm_analysis_port #(spi_transaction) ap;
    virtual spi_interface vif;
    
    // Configurações
    bit mode;
    bit lsb_first;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual spi_interface)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Interface não encontrada")
        uvm_config_db#(bit)::get(this, "", "mode", mode);
        uvm_config_db#(bit)::get(this, "", "lsb_first", lsb_first);
    endfunction

    virtual task predict_transaction(spi_transaction tr);
        spi_transaction predicted_tr;
        predicted_tr = spi_transaction::type_id::create("predicted_tr");
        
        // Modelagem do comportamento esperado
        if(mode) begin // Master
            predicted_tr.data = tr.data;
            predicted_tr.received_data = model_slave_response(tr.data);
        else begin     // Slave
            predicted_tr.data = model_master_command(tr.data);
            predicted_tr.received_data = tr.data;
        end
        
        predicted_tr.copy(tr);
        ap.write(predicted_tr);
    endtask

    virtual function bit [7:0] model_slave_response(bit [7:0] tx_data);
        // Implementar modelo da resposta do escravo
        return ~tx_data; // Exemplo simples
    endfunction

    virtual function bit [7:0] model_master_command(bit [7:0] rx_data);
        // Implementar modelo do comando do mestre
        return rx_data << 1; // Exemplo simples
    endfunction

endclass

`endif // SPI_REFMOD_SV
