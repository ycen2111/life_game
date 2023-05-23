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

    parameter MAX_ROW_BITS = 5; //512
    parameter MAX_COLUMN_BITS = 5; //512
    parameter MAX_ROW = 2 ** MAX_ROW_BITS;
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS;

    reg CLK, RESET;
    reg finish, W_enable;
    reg [MAX_ROW_BITS - 1 : 0] row_in, row_out;
    reg [MAX_COLUMN_BITS - 1 : 0] column_in, column_out;
    reg [15 : 0] data_in;
    
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
        .data_out(data_out)
    );
    
    always #5 CLK = ~CLK;
    
    initial begin
        CLK = 0;
        RESET = 1;
        finish = 0;
        W_enable = 0;
        #50 RESET = 0;
            row_out = 1;
            column_out = 16;
            
    end

endmodule
