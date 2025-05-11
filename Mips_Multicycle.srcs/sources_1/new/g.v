`timescale 1ns / 1ps


module MDR (
    input clk,
    input reset,
    input [31:0] mem_data_out, 
    output reg [31:0] MDR_out  
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            MDR_out <= 32'b0;
        else
            MDR_out <= mem_data_out;  
    end

endmodule
