`ifndef SPI_TEST_SV
`define SPI_TEST_SV

class spi_test extends uvm_test;
    `uvm_component_utils(spi_test)
    
    spi_env env;
    spi_coverage coverage;
    spi_sequences spi_seq;
    
    // Test configuration
    bit enable_coverage = 1;
    bit run_full_test = 1;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = spi_env::type_id::create("env", this);
        coverage = spi_coverage::type_id::create("coverage", this);
        
        // Configure test parameters
        uvm_config_db#(bit)::set(this, "*", "enable_coverage", enable_coverage);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        env.coverage = coverage;
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        `uvm_info("TEST", "Starting SPI verification test...", UVM_LOW)
        
        if(run_full_test) begin
            spi_full_test_sequence full_seq;
            full_seq = spi_full_test_sequence::type_id::create("full_seq");
            full_seq.start(env.agent.sequencer);
        end
        else begin
            spi_basic_sequence basic_seq;
            basic_seq = spi_basic_sequence::type_id::create("basic_seq");
            basic_seq.start(env.agent.sequencer);
        end
        
        // Wait for completion and report
        #100ns; // Additional settling time
        `uvm_info("TEST", "Test sequence completed", UVM_MEDIUM)
        
        phase.drop_objection(this);
    endtask
    
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("TEST", $sformatf("Test Summary:\n%s", get_test_summary()), UVM_MEDIUM)
    endfunction
    
    virtual function string get_test_summary();
        return $sformatf(
            "Coverage Achieved: %0.2f%%\n" +
            "Transactions Executed: %0d\n" +
            "Errors Detected: %0d",
            coverage.get_coverage(),
            env.scoreboard.transaction_count,
            env.scoreboard.mismatch_count
        );
    endfunction
    
endclass

`endif // SPI_TEST_SV
