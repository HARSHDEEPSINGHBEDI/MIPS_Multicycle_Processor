`timescale 1ns / 1ps

module memory (
    input clk,
    input MemRead,
    input MemWrite,
    input [1:0] mem_mode,          
    input [31:0] address,
    input [31:0] Data,
    output reg [31:0] mem_data_out
);

    reg [31:0] memory [0:255];      // made a combined memory of size 1 KB (kilobyte)(32*256 bits)

    initial $readmemh("program.mem", memory); // Initial memory loading here

    // here i have made mem_mode control signal which opereates in 00 fir normal lw but as 01 for lhu instruction
    always @(*) begin
        mem_data_out = 32'b0;

        if (MemRead) begin
            case (mem_mode)
                2'b00: mem_data_out = memory[address >> 2]; 
                2'b01: begin  
                    if (address[1] == 1'b0)
                        mem_data_out = {16'b0, memory[address >> 2][15:0]};
                    else
                        mem_data_out = {16'b0, memory[address >> 2][31:16]};
                end
                default: mem_data_out = 32'b0;
            endcase
        end
    end

    
    always @(posedge clk) begin
        if (MemWrite && mem_mode == 2'b00) begin
            memory[address >> 2] <= Data;
        end
    end

endmodule
