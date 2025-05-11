`timescale 1ns / 1ps

module memtoreg_mux (
    input        MemtoReg,
    input  [31:0] alu_out_reg,
    input  [31:0] MDR_out,
    output reg [31:0] write_data
);

    always @(*) begin
        case (MemtoReg)
            1'b0: write_data = alu_out_reg;
            1'b1: write_data = MDR_out;
            default: write_data = 32'b0;
        endcase
    end

endmodule
