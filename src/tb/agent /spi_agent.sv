// spi_agent.sv
`ifndef SPI_AGENT_SV
`define SPI_AGENT_SV

class spi_agent extends uvm_agent;
    `uvm_component_utils(spi_agent)
    
    spi_driver                 driver;
    spi_monitor                monitor;
    uvm_sequencer #(spi_transaction) sequencer;
    
    uvm_analysis_port #(spi_transaction) analysis_port;
    
    // Configuração de modo de operação
    bit is_active = UVM_ACTIVE;
    bit mode;  // 0: Slave, 1: Master

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Configuração padrão
        if(!uvm_config_db#(bit)::get(this, "", "mode", mode))
            `uvm_warning("CFG", "Modo não configurado, usando padrão Master")
        
        // Criação condicional de componentes
        if(is_active == UVM_ACTIVE) begin
            sequencer = uvm_sequencer#(spi_transaction)::type_id::create("sequencer", this);
            driver = spi_driver::type_id::create("driver", this);
            
            // Configuração do driver
            uvm_config_db#(bit)::set(this, "driver", "mode", mode);
        end
        
        // Monitor sempre criado
        monitor = spi_monitor::type_id::create("monitor", this);
        
        // Configuração comum
        uvm_config_db#(bit)::set(this, "monitor", "mode", mode);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        if(is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
        
        // Conexão do monitor com o analysis port do agente
        monitor.mon_ap.connect(analysis_port);
    endfunction

    function void set_active(bit is_active);
        this.is_active = is_active;
    endfunction

endclass

`endif // SPI_AGENT_SV
