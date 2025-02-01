`ifndef SPI_SEQUENCES_SV
`define SPI_SEQUENCES_SV

//----------------------------------------------
// Classe base para todas as sequências SPI
//----------------------------------------------
class spi_base_sequence extends uvm_sequence #(spi_transaction);
    `uvm_object_utils(spi_base_sequence)
    
    // Configurações padrão
    rand bit mode = 1;          // 0: Slave, 1: Master
    rand int clock_div = 1;     // Divisor de clock
    rand bit lsb_first = 0;     // Ordem dos bits
    rand int num_transactions = 10;
    
    // Constraints
    constraint valid_clock_div {
        clock_div inside {[1:31]};
    }
    
    function new(string name = "spi_base_sequence");
        super.new(name);
    endfunction
    
    virtual task pre_body();
        // Configurações iniciais opcionais
    endtask
endclass

//----------------------------------------------
// Sequência de teste básico
//----------------------------------------------
class spi_basic_sequence extends spi_base_sequence;
    `uvm_object_utils(spi_basic_sequence)
    
    function new(string name = "spi_basic_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        repeat(num_transactions) begin
            `uvm_do_with(req, {
                mode == local::mode;
                clock_div == local::clock_div;
                lsb_first == local::lsb_first;
                data dist {
                    8'h00 :/ 1,
                    8'hFF :/ 1,
                    [8'h01:8'hFE] :/ 8
                };
            })
        end
    endtask
endclass

//----------------------------------------------
// Sequência de modo Master
//----------------------------------------------
class spi_master_sequence extends spi_base_sequence;
    `uvm_object_utils(spi_master_sequence)
    
    function new(string name = "spi_master_sequence");
        super.new(name);
        mode = 1;
    endfunction
    
    virtual task body();
        `uvm_info("SEQ", "Iniciando sequência Master", UVM_LOW)
        repeat(num_transactions) begin
            `uvm_do_with(req, {
                mode == 1;
                data inside {[8'h00:8'hFF]};
                clock_div inside {1, 2, 4, 8};
            })
        end
    endtask
endclass

//----------------------------------------------
// Sequência de modo Slave
//----------------------------------------------
class spi_slave_sequence extends spi_base_sequence;
    `uvm_object_utils(spi_slave_sequence)
    
    function new(string name = "spi_slave_sequence");
        super.new(name);
        mode = 0;
    endfunction
    
    virtual task body();
        `uvm_info("SEQ", "Iniciando sequência Slave", UVM_LOW)
        repeat(num_transactions) begin
            `uvm_do_with(req, {
                mode == 0;
                data inside {[8'h00:8'hFF]};
                clock_div == 0; // Não aplicável para slave
            })
        end
    endtask
endclass

//----------------------------------------------
// Sequência de teste completo
//----------------------------------------------
class spi_full_test_sequence extends spi_base_sequence;
    `uvm_object_utils(spi_full_test_sequence)
    
    function new(string name = "spi_full_test_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        // Teste modo Master
        mode = 1;
        `uvm_do_with(this, {num_transactions == 5;})
        
        // Teste modo Slave
        mode = 0;
        `uvm_do_with(this, {num_transactions == 5;})
        
        // Teste LSB first
        lsb_first = 1;
        `uvm_do_with(this, {num_transactions == 5;})
    endtask
endclass

`endif // SPI_SEQUENCES_SV
