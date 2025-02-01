// spi_env.sv
`ifndef SPI_ENV_SV
`define SPI_ENV_SV

class spi_env extends uvm_env;
    `uvm_component_utils(spi_env)
    
    spi_agent       agent;
    spi_scoreboard  scoreboard;
    spi_coverage    coverage;
    
    // Configurações do ambiente
    bit is_active = UVM_ACTIVE;
    bit mode;  // 0: Slave, 1: Master
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Criação do agent com configuração
        agent = spi_agent::type_id::create("agent", this);
        agent.set_active(is_active);
        uvm_config_db#(bit)::set(this, "agent", "mode", mode);
        
        // Componentes de verificação
        scoreboard = spi_scoreboard::type_id::create("scoreboard", this);
        coverage = spi_coverage::type_id::create("coverage", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Conexão do agent com scoreboard e coverage
        agent.analysis_port.connect(scoreboard.analysis_export);
        agent.analysis_port.connect(coverage.analysis_export);
    endfunction

    // Métodos de configuração
    function void set_active(bit active);
        is_active = active;
        agent.set_active(active);
    endfunction

    function void set_mode(bit new_mode);
        mode = new_mode;
        uvm_config_db#(bit)::set(this, "agent", "mode", new_mode);
    endfunction

    // Fase de report final
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("ENV", $sformatf("Coverage Final: %0.2f%%", coverage.get_coverage()), UVM_MEDIUM)
    endfunction

endclass

`endif // SPI_ENV_SV
