`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.05.2023 21:39:36
// Design Name: 
// Module Name: Core_Logic
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


module Core_Logic
    #(
    parameter BIT_NUM = 2
    )
    (
    input clk, //system clk
    input reset, //reset button
    input enter, //input new board
    input [2**BIT_NUM**2 - 1:0] board_in, // 8x8 board
    output [2**BIT_NUM**2 - 1:0] board_out // next state of the board
    );
    
    integer i, j;
    parameter SIZE = 2**BIT_NUM;
    parameter SIZE_SQUARE = SIZE**2;
    
    reg [SIZE_SQUARE - 1:0] board;
    reg [SIZE_SQUARE - 1:0] next_board;
    reg [SIZE_SQUARE - 1:0] past_board;
    reg [3:0] sum [SIZE_SQUARE - 1:0];
    
    always @(posedge clk) begin
        if(reset)
            board <= 0;
        else begin
            if (enter)
                board <= board_in;
            else
                board <= next_board;
        end
        past_board <= board;
    end
    
    always @(posedge clk) begin
        for (i = 0; i < SIZE_SQUARE; i = i + 1) begin //row
            if (i == 0) begin //top-left cornor
                sum[i] <= board[i + 1] + board[i + SIZE] + board[i + SIZE + 1];
            end
            else if (i == SIZE_SQUARE - SIZE) begin //bottom-left cornor
                sum[i] <= board[i - SIZE] + board[i + 1] + board[i - SIZE + 1];
            end
            else if (i == SIZE - 1) begin //top-right cornor
                sum[i] <= board[i - 1] + board[i + SIZE] + board[i + SIZE - 1];
            end
            else if (i == SIZE_SQUARE - 1) begin //bottom-right cornor
                sum[i] <= board[i - 1] + board[i - SIZE] + board[i - SIZE - 1];
            end
            else if (i < SIZE) begin //top line
                sum[i] <= board[i - 1] + board[i + 1] + board[i + SIZE] + board[i + SIZE - 1] + board[i + SIZE + 1];
            end
            else if (i > SIZE_SQUARE - SIZE - 1) begin //bottom line
                sum[i] <= board[i - 1] + board[i + 1] + board[i - SIZE] + board[i - SIZE - 1] + board[i - SIZE +1];
            end
            else if (i[BIT_NUM - 1:0] == 0) begin //left line
                sum[i] <= board[i + 1] + board[i - SIZE] + board[i - SIZE + 1] + board[i + SIZE] + board[i + SIZE + 1];
            end
            else if (i[BIT_NUM - 1:0] == SIZE - 1) begin //right line
                sum[i] <= board[i - 1] + board[i - SIZE] + board[i - SIZE - 1] + board[i + SIZE] + board[i + SIZE - 1];
            end
            else begin //normal case
                sum[i] <= board[i - 1] + board[i + 1] + board[i - SIZE] + board[i - SIZE - 1] + board[i - SIZE +1] + board[i + SIZE] + board[i + SIZE - 1] + board[i + SIZE + 1];
            end
        end
    end
    
    always @(posedge clk) begin
        if (reset) begin
            next_board <= 0;
        end
        else begin
            for (j = 0; j < SIZE_SQUARE; j = j + 1) begin
                if (sum[j] == 3)
                    next_board[j] <= 1;
                else if (sum[j] == 2) 
                    next_board[j] <= past_board[j];
                else
                    next_board[j] <= 0;
            end
        end
    end
    
    assign board_out = board;
    
endmodule
