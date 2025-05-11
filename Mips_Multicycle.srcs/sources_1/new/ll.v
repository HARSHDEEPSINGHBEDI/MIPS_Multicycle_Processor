`timescale 1ns / 1ps


module shift_left_2_jump (
    input [25:0] address,                
    input [31:0] pc_out,                 
    output reg [31:0] jump_address       
);

    reg [27:0] shifted_address;

    always @(*) begin
        shifted_address = address << 2;                            
        jump_address = {pc_out[31:28], shifted_address};           
    end

endmodule
