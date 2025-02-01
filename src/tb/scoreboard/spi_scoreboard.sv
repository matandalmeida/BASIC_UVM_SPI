`ifndef SPI_SCOREBOARD_SV
`define SPI_SCOREBOARD_SV

class spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_scoreboard)
    
    uvm_analysis_imp #(spi_transaction, spi_scoreboard) mon_export;
    uvm_analysis_imp #(spi_transaction, spi_scoreboard) refmod_export;
    
    spi_refmod refmod;
    int match_count, mismatch_count;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_export = new("mon_export", this);
        refmod_export = new("refmod_export", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        refmod = spi_refmod::type_id::create("refmod", this);
    endfunction

    virtual function void write_mon(spi_transaction tr);
        refmod.predict_transaction(tr);
    endfunction

    virtual function void write_refmod(spi_transaction predicted_tr);
        spi_transaction actual_tr;
        // Implementar lógica de comparação
        if(actual_tr.compare(predicted_tr)) begin
            match_count++;
        else begin
            mismatch_count++;
            `uvm_error("SCBD", $sformatf("Mismatch!\nExpected: %s\nActual: %s", 
                predicted_tr.sprint(), actual_tr.sprint()))
        end
    endfunction

    // ... (demais métodos mantidos com ajustes)
endclass

`endif // SPI_SCOREBOARD_SV
