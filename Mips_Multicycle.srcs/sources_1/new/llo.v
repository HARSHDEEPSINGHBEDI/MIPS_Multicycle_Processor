`timescale 1ns / 1ps

module alu_out_reg (
    input  clk,
    input  reset,
    input  [31:0] ALUOut,
    output reg [31:0] aluoutreg
);

    always @(posedge clk) begin
        if (reset)
            aluoutreg <= 32'b0;
        else
            aluoutreg <= ALUOut;
    end

endmodule
