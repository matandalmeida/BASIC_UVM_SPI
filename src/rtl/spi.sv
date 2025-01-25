module spi (
    input logic clk,
    input logic reset_n,
    input logic cs_n,
    input logic mosi,
    input logic sclk,
    input logic mode,        // 0 = Slave, 1 = Master
    input logic [7:0] reg_addr,
    input logic reg_write,
    input logic [7:0] reg_wdata,
    output logic [7:0] reg_rdata,
    output logic miso,
    output logic ready
);

    // Banco de registros
    logic [7:0] ctrl_reg;
    logic [7:0] status_reg;
    logic [7:0] data_in_reg;
    logic [7:0] data_out_reg;
    logic [7:0] clk_div_reg;

    // Contadores e registradores para operação SPI
    logic [7:0] shift_reg;      // Shift register para leitura e escrita de dados
    logic [3:0] bit_count;      // Contador de bits para a transação SPI
    logic clk_enable;           // Habilitação do clock para ajuste de frequência

    // Lógica de reset e escrita no banco de registros
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ctrl_reg <= 8'h00;
            status_reg <= 8'h00;
            data_in_reg <= 8'h00;
            data_out_reg <= 8'h00;
            clk_div_reg <= 8'h01;
            shift_reg <= 8'h00;
            bit_count <= 4'h0;
            ready <= 1'b1;
        end else if (reg_write && !cs_n) begin
            case (reg_addr)
                8'h00: ctrl_reg <= reg_wdata;
                8'h08: data_in_reg <= reg_wdata;
                8'h10: clk_div_reg <= reg_wdata;
                default: ; // Ignorar endereços inválidos
            endcase
        end
    end

    // Lógica de leitura do banco de registros
    always_comb begin
        case (reg_addr)
            8'h00: reg_rdata = ctrl_reg;
            8'h04: reg_rdata = status_reg;
            8'h0C: reg_rdata = data_out_reg;
            8'h10: reg_rdata = clk_div_reg;
            default: reg_rdata = 8'h00;
        endcase
    end

    // Geração de Clock Habilitado
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            clk_enable <= 1'b0;
        else
            clk_enable <= (bit_count == 4'h0) ? 1'b0 : 1'b1;
    end

    // Lógica de operação SPI (Master e Slave)
    always_ff @(posedge sclk or negedge reset_n) begin
        if (!reset_n) begin
            shift_reg <= 8'h00;
            bit_count <= 4'h0;
            status_reg[0] <= 1'b0; // Não pronto
            miso <= 1'b0;
            ready <= 1'b1;
        end else if (!cs_n) begin
            if (mode) begin
                // Modo Master
                if (bit_count == 4'h0) begin
                    shift_reg <= data_in_reg; // Carrega dados de data_in_reg
                end

                miso <= shift_reg[7]; // Envia o bit mais significativo
                shift_reg <= {shift_reg[6:0], mosi}; // Shifts in the received bit
                bit_count <= bit_count + 1; // Incrementa contador de bits
                if (bit_count == 4'h7) begin
                    status_reg[0] <= 1'b1; // Pronto
                    ready <= 1'b1; // Operação concluída
                end else begin
                    ready <= 1'b0; // Ainda em transação
                end
            end else begin
                // Modo Slave
                shift_reg <= {shift_reg[6:0], mosi}; // Shifts in the received bit
                miso <= data_out_reg[7]; // Envia o bit mais significativo
                if (bit_count == 4'h7) begin
                    status_reg[0] <= 1'b1; // Pronto
                    ready <= 1'b1; // Operação concluída
                    bit_count <= 4'h0; // Reseta contador de bits
                end else begin
                    ready <= 1'b0; // Ainda em transação
                    bit_count <= bit_count + 1; // Incrementa contador de bits
                end
            end
        end else begin
            status_reg[0] <= 1'b0; // Não pronto
            ready <= 1'b0;
            bit_count <= 4'h0; // Reseta contador de bits
        end
    end

endmodule
