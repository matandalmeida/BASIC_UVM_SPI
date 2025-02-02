# Makefile Documentation for Xcelium UVM Simulation

## Requirements
- Cadence Xcelium 18.03+
- UVM 1.2 library
- Bash shell

## Setup
1. Configure environment variables:
```bash
export XCELIUM_HOME=/path/to/xcelium/installation
export PATH=$XCELIUM_HOME/tools/bin:$PATH
```
2. Create project structure:
```
project_root/
├── rtl/            # RTL files
├── uvmtb/          # UVM testbench
├── tb/             # Top-level testbench
└── work/           # Simulation directory (auto-created)
```
## Usage
### Basic Commands
```bash
# Full flow (clean → compile → elaborate → run)
make all

# Individual steps
make compile
make elaborate
make run

# Run specific test
make run TEST_NAME=spi_error_test

# Debug with waveforms
make run SIM_OPTS="-input waves.tcl"
make waves
```
### Generate coverage report:
```bash
imc -load coverage -excl_scope -report_html final_cov
```
