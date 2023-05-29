`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.05.2023 12:45:17
// Design Name: 
// Module Name: Mem_driver_TB
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


module Mem_driver_TB();

    parameter MAX_ROW_BITS = 9; //512
    parameter MAX_COLUMN_BITS = 9; //512
    parameter MAX_ROW = 2 ** MAX_ROW_BITS;
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS;

    reg CLK, RESET;
    reg finish, W_enable;
    reg [MAX_ROW_BITS - 1 : 0] row_in, row_out;
    reg [MAX_COLUMN_BITS - 1 : 0] column_in, column_out;
    reg [15 : 0] data_in;
    reg write_cell_en, erase_cell_en;
    
    wire [15 : 0] data_out;

    Mem_driver UUT (
        .CLK(CLK),
        .RESET(RESET),
        .finish(finish),
        .W_enable(W_enable),
        .row_in(row_in), //start with 0
        .column_in(column_in),
        .data_in(data_in),
        .row_out(row_out),
        .column_out(column_out),
        .data_out(data_out),
        .data_out_1_bit(data_out_1_bit),
        //input single bit
        .write_1_bit(write_cell_en || erase_cell_en),
        .data_in_1_bit(write_cell_en ? 1 : 0)
    );
    
    always #5 CLK = ~CLK;
    
    initial begin
        CLK = 0;
        RESET = 1;
        finish = 0;
        W_enable = 0;
        data_in = 0;
        #50 RESET = 0;
            row_in = 1;
            column_in = 16;
            data_in = 2;
            W_enable = 1;
        #50 W_enable = 0;
            data_in = 0;
            finish = 1;
        #50 row_out = 1;
            column_out = 15;
        #10 row_out = 1;
            column_out = 16;
            
    end

endmodule
