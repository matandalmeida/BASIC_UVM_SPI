// spi_scoreboard.sv
`ifndef SPI_SCOREBOARD_SV
`define SPI_SCOREBOARD_SV

class spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_scoreboard)
    
    uvm_analysis_imp #(spi_transaction, spi_scoreboard) analysis_export;
    
    // Estruturas de dados
    spi_transaction expected_queue[$];
    int transaction_count;
    int error_count;
    
    // Configurações
    bit enable_checks = 1;
    bit mode;  // Modo atual do DUT
    
    // Interface para comunicação externa
    virtual spi_interface vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual spi_interface)::get(this, "", "vif", vif))
            `uvm_warning("NOVIF", "Interface não encontrada")
    endfunction

    virtual function void write(spi_transaction tr);
        if(enable_checks) begin
            spi_transaction expected_tr;
            
            // Busca transação esperada
            if(expected_queue.size() > 0) begin
                expected_tr = expected_queue.pop_front();
                compare_transactions(tr, expected_tr);
            end
            else begin
                `uvm_error("SCBD", $sformatf("Transação inesperada recebida:\n%s", tr.sprint()))
                error_count++;
            end
            
            transaction_count++;
        end
    endfunction

    virtual function void compare_transactions(spi_transaction actual, spi_transaction expected);
        bit error = 0;
        
        // Verificação de dados
        if(actual.data !== expected.data) begin
            `uvm_error("SCBD", $sformatf("Dados TX não coincidem! Esperado: 0x%h, Recebido: 0x%h",
                expected.data, actual.data))
            error = 1;
        end
        
        if(actual.received_data !== expected.received_data) begin
            `uvm_error("SCBD", $sformatf("Dados RX não coincidem! Esperado: 0x%h, Recebido: 0x%h",
                expected.received_data, actual.received_data))
            error = 1;
        end
        
        // Verificação de timing
        if(actual.duration > (expected.clock_div * 20ns)) begin
            `uvm_warning("SCBD", $sformatf("Tempo de transação excedido: %0tns (Limite: %0tns)",
                actual.duration, expected.clock_div * 20ns))
        end
        
        // Atualização de contadores
        if(error) error_count++;
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCBD", $sformatf("Resumo da Verificação:\n%s", get_report()), UVM_MEDIUM)
    endfunction

    virtual function string get_report();
        return $sformatf(
            "Transações verificadas: %0d\n"  +
            "Erros encontrados:      %0d\n"  +
            "Taxa de sucesso:        %0.2f%%",
            transaction_count, 
            error_count,
            (transaction_count == 0) ? 0.0 : (100.0 - (error_count*100.0/transaction_count))
        );
    endfunction

    // Método para adicionar transações esperadas
    function void add_expected(spi_transaction tr);
        expected_queue.push_back(tr);
    endfunction

endclass

`endif // SPI_SCOREBOARD_SV
