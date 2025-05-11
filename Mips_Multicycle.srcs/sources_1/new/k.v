`timescale 1ns / 1ps


module shift_left_2 (
    input [31:0] imm_ext ,           
    output reg [31:0] shift_left  
);

    always @(*) begin
        shift_left = imm_ext << 2; 
    end

endmodule
