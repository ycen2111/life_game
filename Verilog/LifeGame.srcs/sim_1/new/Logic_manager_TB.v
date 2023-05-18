`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.05.2023 10:10:03
// Design Name: 
// Module Name: Logic_manager_TB
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


module Logic_manager_TB();

    parameter ROW = 3;
    parameter COLUMN = 3;
    
    reg CLK, RESET;
    reg enter;
    reg [9 : 0] row_in;
    reg [9 : 0] column_in;
    
    Logic_manager UUT(
        .CLK(CLK),
        .RESET(RESET),
        .enter(enter),
        .ROW(ROW),
        .COLUMN(COLUMN),
        .row_in(row_in),
        .column_in(column_in)
    );
    
    always #5 CLK = ~CLK;
    
    initial begin
        RESET = 1;
        CLK = 0;
        enter = 1;
        row_in = 0;
        column_in = 0;
        #50 RESET = 0;
        #2000 enter = 1;
            row_in = 1;
            column_in = 1;
        #50 row_in = 2;
            column_in = 2;
        #50 row_in = 3;
            column_in = 3;
        #50 enter = 0;
    end

endmodule
