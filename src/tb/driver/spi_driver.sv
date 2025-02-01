// Arquivo: spi_driver.sv
class spi_driver extends uvm_driver #(spi_transaction);
  `uvm_component_utils(spi_driver)
  
  virtual spi_interface.master vif;
  spi_transaction tr;
  bit [7:0] register_data;
  
  // Método construtor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Fase de conexão
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual spi_interface.master)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Falha ao obter a interface virtual")
  endfunction

  // Tarefa principal de execução
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(tr);
      `uvm_info("DRIVER", $sformatf("Iniciando transação: %s", tr.convert2string()), UVM_LOW)
      drive_transaction(tr);
      seq_item_port.item_done();
    end
  endtask

  // Tarefa para escrita de registradores
  virtual task write_register(bit [7:0] addr, bit [7:0] data);
    @(posedge vif.clk);
    vif.cb_master.reg_addr  <= addr;
    vif.cb_master.reg_write <= 1'b1;
    vif.cb_master.reg_wdata <= data;
    @(posedge vif.clk);
    vif.cb_master.reg_write <= 1'b0;
  endtask

  // Tarefa para leitura de registradores
  virtual task read_register(bit [7:0] addr, output bit [7:0] data);
    @(posedge vif.clk);
    vif.cb_master.reg_addr  <= addr;
    vif.cb_master.reg_write <= 1'b0;
    @(posedge vif.clk);
    data = vif.cb_master.reg_rdata;
  endtask

  // Lógica principal de direcionamento
  virtual task drive_transaction(spi_transaction tr);
    // Configuração inicial do DUT
    write_register(8'h00, {5'b0, tr.lsb_first, tr.mode, 1'b1}); // ctrl_reg
    write_register(8'h10, tr.clock_div);                       // clk_div_reg
    
    if(tr.mode) begin // Modo Master
      drive_master_mode(tr);
    else              // Modo Slave
      drive_slave_mode(tr);
  endtask

  // Lógica para modo Master
  virtual task drive_master_mode(spi_transaction tr);
    bit [7:0] tx_data = tr.data;
    bit [7:0] rx_data;

    // Escreve dados no registrador de transmissão
    write_register(8'h08, tx_data); // data_in_reg
    
    // Inicia transação
    vif.cb_master.cs_n <= 1'b0;
    
    // Gera clock e transmite/recebe bits
    for(int i = 0; i < 8; i++) begin
      // Define MOSI conforme ordem dos bits
      vif.cb_master.mosi <= tr.lsb_first ? tx_data[i] : tx_data[7-i];
      
      // Gera borda de subida do clock
      vif.cb_master.sclk <= 1'b1;
      #(tr.clock_div * vif.clk_period);
      
      // Amostra MISO na borda de subida
      if(tr.lsb_first)
        rx_data[i] = vif.cb_master.miso;
      else
        rx_data[7-i] = vif.cb_master.miso;
      
      // Gera borda de descida do clock
      vif.cb_master.sclk <= 1'b0;
      #(tr.clock_div * vif.clk_period);
    end
    
    // Finaliza transação
    vif.cb_master.cs_n <= 1'b1;
    
    // Atualiza transação com dados recebidos
    tr.received_data = rx_data;
    `uvm_info("DRIVER", $sformatf("Master: TX=0x%0h RX=0x%0h", tx_data, rx_data), UVM_HIGH)
  endtask

  // Lógica para modo Slave
  virtual task drive_slave_mode(spi_transaction tr);
    bit [7:0] tx_data = tr.data;
    bit [7:0] rx_data;

    // Configura resposta do Slave
    write_register(8'h0C, tx_data); // data_out_reg
    
    // Monitora CS_N e SCLK
    wait(vif.cb_master.cs_n == 1'b0);
    
    // Recebe dados do Master
    for(int i = 0; i < 8; i++) begin
      // Amostra MOSI na borda de subida
      @(posedge vif.cb_master.sclk);
      if(tr.lsb_first)
        rx_data[i] = vif.cb_master.mosi;
      else
        rx_data[7-i] = vif.cb_master.mosi;
    end
    
    // Atualiza transação com dados recebidos
    tr.received_data = rx_data;
    `uvm_info("DRIVER", $sformatf("Slave: TX=0x%0h RX=0x%0h", tx_data, rx_data), UVM_HIGH)
  endtask
endclass
