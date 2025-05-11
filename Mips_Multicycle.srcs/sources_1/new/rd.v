`timescale 1ns / 1ps

module regdst_mux (
    input  [1:0] RegDst,
    input  [4:0] rt,
    input  [4:0] rd,
    output reg [4:0] write_reg
);

    always @(*) begin
        case (RegDst)
            2'b00: write_reg = rt;
            2'b01: write_reg = rd;
            2'b10: write_reg = 5'd31;
            default: write_reg = 5'b0;
        endcase
    end

endmodule
