`timescale 1ns / 1ps


module AlusrcA_mux (
    input [31:0] pc_out,        
    input [31:0] A_out,         
    input ALUSrcA,             
    output reg [31:0] alu_src_a_out  
);

    always @(*) begin
        case (ALUSrcA)
            1'b0: alu_src_a_out = pc_out;
            1'b1: alu_src_a_out = A_out;
            default: alu_src_a_out = 32'b0; 
        endcase
    end

endmodule
