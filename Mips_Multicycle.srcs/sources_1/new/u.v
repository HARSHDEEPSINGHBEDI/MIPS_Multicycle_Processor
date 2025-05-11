`timescale 1ns / 1ps

module A_reg (
    input clk,
    input reset,
    input A_Load,                 
    input [31:0] read_data1,     
    output reg [31:0] A_out    
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            A_out <= 32'b0;
        else if (A_Load)
            A_out <= read_data1;
    end

endmodule
