// spi_monitor.sv
`uvm_analysis_imp_decl(_monitor)

class spi_monitor extends uvm_monitor;
    `uvm_component_utils(spi_monitor)
    
    virtual spi_interface.monitor vif;
    uvm_analysis_port #(spi_transaction) mon_ap;
    
    // Configurações
    bit mode;         // 0: Slave, 1: Master
    bit lsb_first;    // Ordenação dos bits
    int clock_div;    // Divisor de clock
    
    // Variáveis internas
    bit [7:0] mosi_data;
    bit [7:0] miso_data;
    int bit_count;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual spi_interface.monitor)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Interface não encontrada")
        if (!uvm_config_db#(bit)::get(this, "", "mode", mode))
            `uvm_warning("NOCFG", "Modo não configurado, usando padrão Master")
        if (!uvm_config_db#(bit)::get(this, "", "lsb_first", lsb_first))
            `uvm_warning("NOCFG", "Ordem de bits não configurada, usando MSB first")
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        forever begin
            capture_transaction();
        end
    endtask
    
    virtual task capture_transaction();
        spi_transaction tr;
        wait_for_start();
        collect_data();
        tr = spi_transaction::type_id::create("tr");
        populate_transaction(tr);
        mon_ap.write(tr);
        `uvm_info("MONITOR", $sformatf("Transação capturada:\n%s", tr.sprint()), UVM_HIGH)
    endtask
    
    virtual task wait_for_start();
        @(negedge vif.cb_mon.cs_n);
        `uvm_info("MONITOR", "Início da transação detectado", UVM_MEDIUM)
        mosi_data = 0;
        miso_data = 0;
        bit_count = 0;
    endtask
    
    virtual task collect_data();
        while(bit_count < 8) begin
            @(vif.cb_mon);
            if(vif.cb_mon.cs_n) break; // Transação abortada
            
            if(mode) begin // Master
                sample_master_bits();
            else           // Slave
                sample_slave_bits();
            end
            
            bit_count++;
        end
    endtask
    
    virtual task sample_master_bits();
        // Wait for sclk posedge (DUT generates sclk in master mode)
        @(posedge vif.cb_master.sclk);
        store_bit(vif.cb_master.mosi, vif.cb_master.miso);
    endtask
    
    virtual task sample_slave_bits();
        // Amostra na borda de subida do SCLK externo
        @(posedge vif.cb_mon.sclk);
        store_bit(vif.cb_mon.mosi, vif.cb_mon.miso);
    endtask
    
    virtual function void store_bit(bit mosi_bit, bit miso_bit);
        if(lsb_first) begin
            mosi_data[bit_count] = mosi_bit;
            miso_data[bit_count] = miso_bit;
        end else begin
            mosi_data[7 - bit_count] = mosi_bit;
            miso_data[7 - bit_count] = miso_bit;
        end
    endfunction
    
    virtual function void populate_transaction(ref spi_transaction tr);
        tr.mode = mode;
        tr.lsb_first = lsb_first;
        tr.clock_div = clock_div;
        
        if(mode) begin // Master
            tr.data = mosi_data;
            tr.received_data = miso_data;
        else           // Slave
            tr.data = miso_data;
            tr.received_data = mosi_data;
        end
    endfunction
endclass
