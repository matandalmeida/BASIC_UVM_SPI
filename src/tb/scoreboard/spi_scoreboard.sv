`ifndef SPI_SCOREBOARD_SV
`define SPI_SCOREBOARD_SV

class spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_scoreboard)
    
    uvm_analysis_imp #(spi_transaction, spi_scoreboard) mon_export;
    uvm_analysis_imp #(spi_transaction, spi_scoreboard) refmod_export;
    
    spi_refmod refmod;
    spi_transaction actual_queue[$];
    int match_count = 0;
    int mismatch_count = 0;
    int transaction_count = 0;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_export = new("mon_export", this);
        refmod_export = new("refmod_export", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        refmod = spi_refmod::type_id::create("refmod", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        refmod.ap.connect(refmod_export);
    endfunction

    virtual function void write_mon(spi_transaction tr);
        actual_queue.push_back(tr);
        refmod.predict_transaction(tr);
        transaction_count++;
    endfunction

    virtual function void write_refmod(spi_transaction predicted_tr);
        spi_transaction actual_tr;
        
        if(actual_queue.size() == 0) begin
            `uvm_error("SCBD", "Transação real não encontrada para comparação")
            return;
        end
        
        actual_tr = actual_queue.pop_front();
        
        if(compare_transactions(actual_tr, predicted_tr)) begin
            match_count++;
            `uvm_info("SCBD", "Transação verificada com sucesso", UVM_HIGH)
        end
        else begin
            mismatch_count++;
            `uvm_error("SCBD", $sformatf("Mismatch!\nEsperado: %s\nRecebido: %s", 
                predicted_tr.sprint(), actual_tr.sprint()))
        end
    endfunction

    virtual function bit compare_transactions(spi_transaction actual, spi_transaction expected);
        bit status = 1;
        
        // Comparação de dados TX
        if(actual.data !== expected.data) begin
            `uvm_error("SCBD", $sformatf("TX mismatch! Esperado: 0x%h, Recebido: 0x%h",
                expected.data, actual.data))
            status = 0;
        end
        
        // Comparação de dados RX
        if(actual.received_data !== expected.received_data) begin
            `uvm_error("SCBD", $sformatf("RX mismatch! Esperado: 0x%h, Recebido: 0x%h",
                expected.received_data, actual.received_data))
            status = 0;
        end
        
        // Verificação de timing
        if(actual.duration > (expected.clock_div * 20ns)) begin
            `uvm_warning("SCBD", $sformatf("Timing violation: %0tns (max: %0tns)",
                actual.duration, expected.clock_div * 20ns))
        end
        
        return status;
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCBD", $sformatf(
            "\nRelatório Final:\n" +
            "Transações totais:  %0d\n" +
            "Matchs:             %0d\n" +
            "Mismatches:         %0d\n" +
            "Taxa de sucesso:    %0.2f%%",
            transaction_count, 
            match_count,
            mismatch_count,
            (transaction_count == 0) ? 0.0 : (match_count*100.0/transaction_count)
        ), UVM_MEDIUM)
    endfunction

endclass

`endif // SPI_SCOREBOARD_SV
