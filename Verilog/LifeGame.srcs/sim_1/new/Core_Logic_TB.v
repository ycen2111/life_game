`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.05.2023 00:28:55
// Design Name: 
// Module Name: Core_Logic_TB
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


module Core_Logic_TB();

    parameter BIT_NUM = 2;
    parameter SIZE = 2**BIT_NUM;
    parameter SIZE_SQUARE = SIZE**2;

    reg clk, reset, enter;
    reg [SIZE_SQUARE - 1:0] board_in;
    wire [SIZE_SQUARE - 1:0] board_out;
    
    integer i;

    Core_Logic UUT(
        .clk(clk), //system clk
        .reset(reset), //reset button
        .enter(enter), //input new board
        .board_in(board_in), // 8x8 board
        .board_out(board_out) // next state of the board
    );
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        enter = 0;
        reset = 1;
        board_in = 0;
        for (i = 0; i < SIZE; i = i + 1) begin
            board_in[i] = 1;
        end
        
        #100 reset = 0;
        #100 enter = 1;
        #50 enter = 0;
        for (i = 0; i < SIZE_SQUARE; i = i + 1) begin
            board_in[i] = 1;
        end
        #100 enter = 1;
        #50 enter = 0;
    end

endmodule
