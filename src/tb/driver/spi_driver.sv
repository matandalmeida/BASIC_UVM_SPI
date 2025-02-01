// Arquivo: spi_driver.sv
class spi_driver extends uvm_driver #(spi_transaction);
  `uvm_component_utils(spi_driver)
  virtual spi_interface.master vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive_transaction(req);
      seq_item_port.item_done();
    end
  endtask

  virtual task drive_transaction(spi_transaction tr);
    // Implementar lógica de driver aqui
    // Ex: Configurar registradores, gerar clocks, etc.
  endtask
endclass
