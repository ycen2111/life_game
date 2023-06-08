`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2023 14:40:28
// Design Name: 
// Module Name: Frame_writer
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


module Frame_writer#(
    parameter MAX_ROW_BITS = 9, //512
    parameter MAX_COLUMN_BITS = 10, //1024
    parameter MAX_ROW = 2 ** MAX_ROW_BITS,
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS
    )(
    input CLK,
    input RESET,
    input write_en,
    //canvas parameter
    input [MAX_ROW_BITS - 1:0] ROW,
    input [MAX_COLUMN_BITS - 1:0] COLUMN,
    //write mem
    output [MAX_ROW_BITS - 1:0] row_to_write_mem,
    output [MAX_COLUMN_BITS - 1:0] column_to_write_mem
    );
    
    parameter MEM_UNIT = 16;
    
    reg [MAX_ROW_BITS - 1:0] row_num;
    reg [MAX_COLUMN_BITS - 1:0] column_num;
    
    assign row_to_write_mem = row_num;
    assign column_to_write_mem = column_num;
    
    always @(posedge CLK) begin
        if (RESET) begin
            row_num <= 1;
            column_num <= 1;
        end
        else begin
            if (write_en) begin
                if (row_num < ROW - 1)
                    row_num <= row_num + 1;
                else begin
                    row_num <= 1;
                    if (column_num < COLUMN - 1)
                        column_num <= column_num + MEM_UNIT;
                    else
                        column_num <= 1;
                end
            end
        end
    end
    
endmodule
