// Arquivo: spi_sequence.sv
class spi_sequence extends uvm_sequence #(spi_transaction);
  `uvm_object_utils(spi_sequence)

  function new(string name = "spi_sequence");
    super.new(name);
  endfunction

  virtual task body();
    spi_transaction tr;
    repeat(10) begin
      tr = spi_transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize());
      finish_item(tr);
    end
  endtask
endclass
