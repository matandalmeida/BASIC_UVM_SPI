# Makefile para simulação UVM com Xcelium
# Usage: make [target] [OPTIONS=value]

# Configurações do projeto
SIMULATOR  = xcelium
UVM_HOME  ?= $(XCELIUM_HOME)/tools/uvm/uvm-1.2
DUT_FILES  = rtl/spi.sv
TB_FILES   = tb/tb_top.sv \
             uvmtb/spi_uvm_pkg.sv \
             uvmtb/spi_interface.sv

# Opções de compilação
COMP_OPTS  = -64bit \
             -uvmhome $(UVM_HOME) \
             -uvm \
             -access +rwc \
             -nowarn DLCPTH \
             -define UVM_NO_DEPRECATED

# Configurações de simulação
TEST_NAME ?= spi_full_test
UVM_VERBOSITY = UVM_MEDIUM
SIM_OPTS   = -input .xcelium_waves.tcl \
             -uvmcontrol set_verbosity \
             -uvmcontrol set_config \
             +UVM_TESTNAME=$(TEST_NAME) \
             +UVM_VERBOSITY=$(UVM_VERBOSITY)

# Diretórios
WORK_DIR   = work
LOG_DIR    = logs
COV_DIR    = coverage

.PHONY: all compile elaborate run clean help

all: clean compile elaborate run

# Compilação
compile:
    @echo "Compiling design and TB..."
    @mkdir -p $(LOG_DIR)
    xmvlog $(COMP_OPTS) -f filelist.f | tee $(LOG_DIR)/compile.log

# Elaboração
elaborate:
    @echo "Elaborating top module..."
    xmelab $(COMP_OPTS) -work $(WORK_DIR) -timescale 1ns/1ps \
    tb_top | tee $(LOG_DIR)/elaborate.log

# Execução
run:
    @echo "Starting simulation..."
    xmsim $(SIM_OPTS) -coverage all -covfile cov_config.ccf \
    -work $(WORK_DIR) tb_top | tee $(LOG_DIR)/simulation.log
    @mv xcelium.d $(COV_DIR)

# Geração de ondas
waves:
    @echo "Opening waveform viewer..."
    simvision waves.shm &

# Limpeza
clean:
    @echo "Cleaning project..."
    @rm -rf $(WORK_DIR) $(LOG_DIR) $(COV_DIR) xcelium.d *.log *.vcd *.wlf *.dsn *.trn *.err *.key *.shm

# Ajuda
help:
    @echo "Uso: make [target]"
    @echo ""
    @echo "Targets:"
    @echo "  all       : Clean, compile, elaborate and run (default)"
    @echo "  compile   : Compile design and testbench"
    @echo "  elaborate : Elaborate top-level module"
    @echo "  run       : Run simulation"
    @echo "  waves     : Open waveform viewer"
    @echo "  clean     : Remove generated files"
    @echo "  help      : Show this help message"
    @echo ""
    @echo "Options:"
    @echo "  TEST_NAME=spi_test_name : Set UVM test name"
    @echo "  UVM_VERBOSITY=level     : Set UVM verbosity (UVM_LOW, UVM_MEDIUM, UVM_HIGH)"
    @echo ""
    @echo "Exemplo:"
    @echo "  make run TEST_NAME=spi_basic_test UVM_VERBOSITY=UVM_HIGH"

# Arquivo de lista de arquivos
filelist.f:
    @echo "Generating file list..."
    @echo $(DUT_FILES) $(TB_FILES) > filelist.f

# Configuração de cobertura
cov_config.ccf:
    @echo "coverage -setup -dut tb_top" > cov_config.ccf
    @echo "coverage -setup -testname $(TEST_NAME)" >> cov_config.ccf
    @echo "coverage -code s -cglbranch all" >> cov_config.ccf
