`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: /
// Engineer: /
// 
// Create Date: 06.05.2023 21:39:36
// Design Name: Yang Cen
// Module Name: Core_Logic
// Project Name: Conway's Life Game
// Target Devices: X7 236-L
// Tool Versions: Vivado 2015.2
// Description: This is a Verilog module for implementing the core logic of a game of life.
//              It takes in a few inputs such as the system clock, reset button, enter button to initiate a new board, and the current state of the board represented by a 2D array.
//              It outputs the next state of the board as a 2D array.
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
    input enter, //init new board
    input [2**BIT_NUM**2 - 1:0] board_in, // N*N board
    output [2**BIT_NUM**2 - 1:0] board_out // output of the board
    );
    
    //basic parameters
    integer i, j;
    parameter SIZE = 2**BIT_NUM;
    parameter SIZE_SQUARE = SIZE**2;
    
    //record board state in 3 cycles
    reg [SIZE_SQUARE - 1:0] board;
    reg [SIZE_SQUARE - 1:0] next_board;
    reg [SIZE_SQUARE - 1:0] past_board;
    //neighbors for last loop
    reg [3:0] neighbors [SIZE_SQUARE - 1:0];
    
    /**
    
    This block contains an always block that is sensitive to a positive edge of the clock signal.
    It checks if the reset button is pressed, and if it is, sets the board to 0.
    If the reset button is not pressed, then it checks if the enter button is pressed, and if it is, sets the board to the new input board.
    Otherwise, it sets the board to the next board state.
    Finally, it sets the past board to the current board state.
    */
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
    
    /**
    
    This block contains an always block that is sensitive to a positive edge of the clock signal.
    It loops through every cell in the board and checks its position relative to the edge of the board.
    Based on the position, it calculates the neighbors of each cell and stores them in an array to be used in the next iteration of the game of life.
    */
    always @(posedge clk) begin
        for (i = 0; i < SIZE_SQUARE; i = i + 1) begin //row
            if (i == 0) begin //top-left cornor
                neighbors[i] <= board[i + 1] + board[i + SIZE] + board[i + SIZE + 1];
            end
            else if (i == SIZE_SQUARE - SIZE) begin //bottom-left cornor
                neighbors[i] <= board[i - SIZE] + board[i + 1] + board[i - SIZE + 1];
            end
            else if (i == SIZE - 1) begin //top-right cornor
                neighbors[i] <= board[i - 1] + board[i + SIZE] + board[i + SIZE - 1];
            end
            else if (i == SIZE_SQUARE - 1) begin //bottom-right cornor
                neighbors[i] <= board[i - 1] + board[i - SIZE] + board[i - SIZE - 1];
            end
            else if (i < SIZE) begin //top line
                neighbors[i] <= board[i - 1] + board[i + 1] + board[i + SIZE] + board[i + SIZE - 1] + board[i + SIZE + 1];
            end
            else if (i > SIZE_SQUARE - SIZE - 1) begin //bottom line
                neighbors[i] <= board[i - 1] + board[i + 1] + board[i - SIZE] + board[i - SIZE - 1] + board[i - SIZE +1];
            end
            else if (i[BIT_NUM - 1:0] == 0) begin //left line
                neighbors[i] <= board[i + 1] + board[i - SIZE] + board[i - SIZE + 1] + board[i + SIZE] + board[i + SIZE + 1];
            end
            else if (i[BIT_NUM - 1:0] == SIZE - 1) begin //right line
                neighbors[i] <= board[i - 1] + board[i - SIZE] + board[i - SIZE - 1] + board[i + SIZE] + board[i + SIZE - 1];
            end
            else begin //normal case
                neighbors[i] <= board[i - 1] + board[i + 1] + board[i - SIZE] + board[i - SIZE - 1] + board[i - SIZE +1] + board[i + SIZE] + board[i + SIZE - 1] + board[i + SIZE + 1];
            end
        end
    end
    
    /**
    
    This block contains an always block that is sensitive to a positive edge of the clock signal.
    If the reset button is pressed, it sets the next board state to 0.
    Otherwise, it loops through every cell in the board and checks the number of neighbors for each cell.
    Based on the number of neighbors, it sets the next board state for each cell.
    */
    always @(posedge clk) begin
        if (reset) begin
            next_board <= 0;
        end
        else begin
            for (j = 0; j < SIZE_SQUARE; j = j + 1) begin
                if (neighbors[j] == 3)
                    next_board[j] <= 1;
                else if (neighbors[j] == 2) 
                    next_board[j] <= past_board[j];
                else
                    next_board[j] <= 0;
            end
        end
    end
    
    //current board result output
    assign board_out = board;
    
endmodule
