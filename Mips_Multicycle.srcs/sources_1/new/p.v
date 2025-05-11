`timescale 1ns / 1ps


module B_reg (
    input clk,
    input reset,
    input B_Load,                 
    input [31:0] read_data2,     
    output reg [31:0] B_out       
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            B_out <= 32'b0;
        end else if (B_Load) begin
            B_out <= read_data2;
        end
    end

endmodule
