`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2023 22:01:29
// Design Name: 
// Module Name: Cell_mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Cell_mem#(
    parameter MAX_ROW_BITS = 9, //512
    parameter MAX_COLUMN_BITS = 10 //1024
    )(
    input CLK,
    input RESET,
    input W_enable,
    //adjust 1 bit
    input write_1_bit,
    input data_in_1_bit,
    input [3:0] element_id,
    //adjust 16 bits
    input [MAX_ROW_BITS + MAX_COLUMN_BITS - 4 - 1 : 0] data_in_add,
    input [15 : 0] data_in,
    input [MAX_ROW_BITS + MAX_COLUMN_BITS - 4 - 1 : 0] data_out_add,
    output reg [15 : 0] data_out
    );
    
    reg [15:0] Mem [2 ** (MAX_ROW_BITS + MAX_COLUMN_BITS - 4) - 1 : 0];

    initial $readmemh("Mem.txt", Mem);

    //write data into memory
    always @(posedge CLK) begin
        if (W_enable) begin
            if (write_1_bit) begin
                Mem[data_in_add][element_id] <= data_in_1_bit;
            end
            else
                Mem[data_in_add] <= data_in;
        end
        else
            Mem[data_in_add] <= Mem[data_in_add];
    end
    
    //the left and right nrighbors of this element
    wire left_cell, right_cell;
    
    //read data out of memory
    always @(posedge CLK) begin
        if (RESET)
            data_out <= 0;
        else
            data_out <= Mem[data_out_add];
    end
    
endmodule
