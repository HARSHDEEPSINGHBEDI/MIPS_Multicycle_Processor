`timescale 1ns / 1ps

module mux_pc_alu (
    input  [31:0] pc_out,
    input  [31:0] aluoutreg,
    input         IorD,
    output [31:0] address_out
);

    assign address_out = (IorD == 1'b0) ? pc_out : aluoutreg;

endmodule
