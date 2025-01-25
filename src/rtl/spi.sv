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

    // Lógica de reset e escrita no banco de registros
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ctrl_reg <= 8'h00;
            status_reg <= 8'h00;
            data_in_reg <= 8'h00;
            data_out_reg <= 8'h00;
            clk_div_reg <= 8'h01;
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

    // Exemplo de funcionalidade SPI (simplificada)
    always_ff @(posedge sclk or negedge reset_n) begin
        if (!reset_n) begin
            data_out_reg <= 8'h00;
            status_reg[0] <= 1'b0; // Não pronto
        end else if (!cs_n) begin
            if (mode) begin
                // Modo Master
                miso <= data_in_reg[7]; // Shift out MSB
                data_out_reg <= {data_out_reg[6:0], mosi}; // Shift in
            end else begin
                // Modo Slave
                data_out_reg <= {data_out_reg[6:0], mosi}; // Shift in
                miso <= data_in_reg[7]; // Shift out MSB
            end
            status_reg[0] <= 1'b1; // Pronto
        end
    end

endmodule
