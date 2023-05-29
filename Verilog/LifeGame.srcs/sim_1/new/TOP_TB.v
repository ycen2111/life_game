`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.05.2023 18:32:36
// Design Name: 
// Module Name: TOP_TB
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


module TOP_TB();

    parameter MAX_ROW_BITS = 9; //512
    parameter MAX_COLUMN_BITS = 9; //512
    parameter MAX_ROW = 2 ** MAX_ROW_BITS;
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS;

    reg CLK, RESET;
    
    TOP UUT(
        .CLK(CLK),
        .RESET(RESET)
    );
    
    always #5 CLK = ~CLK;
    
    initial begin
        CLK = 0;
        RESET = 1;
        #50 RESET = 0;
        #50;
    end

endmodule
