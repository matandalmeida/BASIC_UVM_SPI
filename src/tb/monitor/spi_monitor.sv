// Arquivo: spi_monitor.sv
class spi_monitor extends uvm_monitor;
  `uvm_component_utils(spi_monitor)
  virtual spi_interface.slave vif;
  uvm_analysis_port #(spi_transaction) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      spi_transaction tr;
      // Monitorar interface e capturar transações
      ap.write(tr);
    end
  endtask
endclass
