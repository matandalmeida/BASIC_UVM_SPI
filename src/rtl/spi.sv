// SPI Controller Design Under Test (DUT)
// Implements full SPI protocol with register-based configuration
// Features: Master/Slave modes, configurable clock, data order control

module spi (
    input  logic        clk,        // System clock (50MHz)
    input  logic        reset_n,    // Active-low asynchronous reset
    input  logic        cs_n,       // Chip select (active low)
    inout               mosi,       // Master Out Slave In
    inout               miso,       // Master In Slave Out
    output logic        sclk,       // SPI serial clock
    input  logic [7:0]  reg_addr,   // Register address bus
    input  logic        mode,       // 0: Slave, 1: Master
    input  logic        reg_write,  // Register write strobe
    input  logic [7:0]  reg_wdata,  // Register write data
    output logic [7:0]  reg_rdata,  // Register read data
    output logic        ready       // Transfer ready status
);

    //-----------------------------------------------------------------
    // Register Definitions
    //-----------------------------------------------------------------
    // Control Register (0x00) Bit Map:
    // [0]    - SPI Enable (1: enabled, 0: disabled)
    // [1]    - Mode (0: Slave, 1: Master)
    // [2]    - Data Order (0: MSB first, 1: LSB first)
    // [7:3]  - Reserved
    logic [7:0] ctrl_reg;

    // Status Register (0x04) Bit Map:
    // [0]    - Ready (1: ready for new transfer)
    // [1]    - Error status (1: error detected)
    // [7:2]  - Reserved
    logic [7:0] status_reg;

    // Data Registers:
    logic [7:0] data_in_reg;   // TX Data register (0x08)
    logic [7:0] data_out_reg;  // RX Data register (0x0C)
    
    // Clock Configuration:
    logic [7:0] clk_div_reg;   // Clock divider register (0x10)

    //-----------------------------------------------------------------
    // Internal Signals
    //-----------------------------------------------------------------
    logic [7:0]  shift_reg;     // Data shift register
    logic [3:0]  bit_count;     // Bit transfer counter
    logic [15:0] clk_counter;   // Clock divider counter
    logic        sclk_int;      // Internal generated clock
    logic        spi_en;        // SPI enable signal
    logic        mode;          // Operation mode (from ctrl_reg)
    logic        lsb_first;     // Data order control
    
    // Internal signals
    logic mosi_out, miso_out;
    
    // Tri-state buffers
    assign mosi = (mode) ? mosi_out : 'bz; // Master drives mosi
    assign miso = (mode) ? 'bz : miso_out; // Slave drives miso

    
    // Control signals extraction
    assign spi_en    = ctrl_reg[0];
    assign mode      = ctrl_reg[1];  // Master(1)/Slave(0) mode
    assign lsb_first = ctrl_reg[2];

    // Status register mapping
    assign status_reg[0] = ready;
    assign status_reg[1] = 1'b0;     // Error flag placeholder

    //-----------------------------------------------------------------
    // Register Interface
    //-----------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ctrl_reg    <= 8'h00;  // Default: SPI disabled
            data_in_reg <= 8'h00;
            clk_div_reg <= 8'h01;  // Default clock divider
        end
        else if (reg_write && !cs_n) begin
            case (reg_addr)
                8'h00: ctrl_reg    <= reg_wdata;  // Control reg
                8'h08: data_in_reg <= reg_wdata;  // TX data
                8'h10: clk_div_reg <= reg_wdata;  // Clock divider
                default: ; // Ignore other writes
            endcase
        end
    end

    // Read register mux
    always_comb begin
        case (reg_addr)
            8'h00: reg_rdata = ctrl_reg;     // Control
            8'h04: reg_rdata = status_reg;   // Status
            8'h0C: reg_rdata = data_out_reg; // RX data
            8'h10: reg_rdata = clk_div_reg;  // Clock divider
            default: reg_rdata = 8'h00;
        endcase
    end

    //-----------------------------------------------------------------
    // Clock Generation (Master Mode Only)
    //-----------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 16'h0;
            sclk_int    <= 1'b0;
        end
        else if (spi_en && mode) begin // Master mode
            if (clk_counter >= {clk_div_reg, 1'b0}) begin
                clk_counter <= 16'h0;
                sclk_int    <= ~sclk_int;
            end
            else begin
                clk_counter <= clk_counter + 1;
            end
        end
        else begin
            clk_counter <= 16'h0;
            sclk_int    <= 1'b0;
        end
    end

    assign sclk = mode ? sclk_int : 1'b0; // Slave uses external clock

    //-----------------------------------------------------------------
    // Data Transfer Control
    //-----------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            shift_reg    <= 8'h00;
            bit_count    <= 4'h0;
            data_out_reg <= 8'h00;
            ready        <= 1'b1;
        end
        else begin
            ready <= (bit_count == 0); // Update ready status

            if (spi_en) begin
                if (mode) begin // Master Mode
                    if (ready && !cs_n) begin
                        shift_reg <= data_in_reg;
                        bit_count <= 4'h1;
                        ready     <= 1'b0;
                    end
                    else if (sclk_int && bit_count > 0) begin
                        if (lsb_first) begin
                            shift_reg <= {shift_reg[6:0], miso};
                        end
                        else begin
                            shift_reg <= {miso, shift_reg[7:1]};
                        end

                        if (bit_count == 8) begin
                            data_out_reg <= shift_reg;
                            bit_count    <= 4'h0;
                            ready        <= 1'b1;
                        end
                        else begin
                            bit_count <= bit_count + 1;
                        end
                    end
                end
                else begin // Slave Mode
                    if (sclk && !cs_n) begin
                        if (lsb_first) begin
                            shift_reg <= {shift_reg[6:0], mosi};
                        end
                        else begin
                            shift_reg <= {mosi, shift_reg[7:1]};
                        end

                        if (bit_count == 7) begin
                            data_out_reg <= shift_reg;
                            bit_count    <= 4'h0;
                        end
                        else begin
                            bit_count <= bit_count + 1;
                        end
                    end
                end
            end
        end
    end

    //-----------------------------------------------------------------
    // MISO Output Control
    //-----------------------------------------------------------------
    always_comb begin
        if (mode) begin // Master mode
            miso = 1'bz; // Tri-state in master mode
        end
        else begin      // Slave mode
            if (lsb_first) begin
                miso = (bit_count < 8) ? data_in_reg[bit_count] : 1'bz;
            end
            else begin
                miso = (bit_count < 8) ? data_in_reg[7 - bit_count] : 1'bz;
            end
        end
    end

endmodule
