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
//              It will divide calculation into multiple clock cycles.
//              It takes in a few inputs such as the system clock, reset button, enter button to initiate a new board, and the current state of the board represented by a 2D array.
//              It outputs the next state of the board as a 2D array.
// 
// Dependencies: 
// 
// Revision:
// Revision 1.00 - pipline the calculation
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Core_Logic_v1
    #(
    parameter BIT_NUM = 4,
    parameter STEP_NUM = 2
    )
    (
    input clk, //system clk
    input reset, //reset button
    input enter, //init new board
    input [2**BIT_NUM**2 - 1:0] board_in, // N*N board
    output [2**BIT_NUM**2 - 1:0] board_out // output of the board
    );
    
    //basic parameters
    parameter SIZE = 2**BIT_NUM;
    parameter SIZE_SQUARE = SIZE**2;
    parameter STEP = 2**STEP_NUM**2;
    
    //record board state in 3 cycles
    integer i, j;
    reg [SIZE_SQUARE - 1:0] board;
    reg [SIZE_SQUARE - 1:0] next_board;
    //neighbors for last loop
    reg [3:0] neighbors [STEP - 1:0];
    
    reg top, middle, bottom;
    reg finish;
    reg [31:0] count;
    
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
            else if (finish)
                board <= next_board;
            else
                board <= board;
        end
    end
    
    
    always @(posedge clk) begin
        if (reset || enter) begin
            count <= 0;
            finish <= 0;
            top <= 0;
            middle <= 0;
            bottom <= 0;
        end
        else if(count == 0) begin
            count <= count + STEP;
            finish <= 0;
            top <= 1;
            middle <= 0;
            bottom <= 0;
        end
        else if(count == SIZE_SQUARE - STEP) begin
            count <= 0;
            finish <= 1;
            top <= 0;
            middle <= 0;
            bottom <= 1;
        end
        else begin
            count <= count + STEP;
            finish <= 0;
            top <= 0;
            middle <= 1;
            bottom <= 0;
        end
    end
    
    /**
    
    This block contains an always block that is sensitive to a positive edge of the clock signal.
    It loops through every cell in the board and checks its position relative to the edge of the board.
    Based on the position, it calculates the neighbors of each cell and stores them in an array to be used in the next iteration of the game of life.
    */
    always @(posedge clk) begin
        if (reset) begin
            next_board <= 0;
        end
        else begin
            /*if (top) begin
                neighbors[0] = board[i + 1] + board[i + SIZE] + board[i + SIZE + 1];
                for (i = 1; i < STEP - 1; i = i + 1)
                    neighbors[i] = board[i - 1] + board[i + 1] + board[i + SIZE] + board[i + SIZE - 1] + board[i + SIZE + 1];
                neighbors[i] = board[i - 1] + board[i + SIZE] + board[i + SIZE - 1];
            end
            else if (middle) begin
                neighbors[count] = board[count + 1] + board[count - SIZE] + board[count - SIZE + 1] + board[count + SIZE] + board[count + SIZE + 1];
                for (i = 1; i < STEP - 1; i = i + 1)
                    neighbors[count + i] = board[count + i - 1] + board[count + i + 1] + board[count + i - SIZE] + board[count + i - SIZE - 1] + board[count + i - SIZE +1] + board[count + i + SIZE] + board[count + i + SIZE - 1] + board[count + i + SIZE + 1];
                neighbors[i] = board[i - 1] + board[i - SIZE] + board[i - SIZE - 1] + board[i + SIZE] + board[i + SIZE - 1];
            end
            else if (bottom) begin
                neighbors[count] = board[count - SIZE] + board[count + 1] + board[count - SIZE + 1];
                for (i = 1; i < STEP - 1; i = i + 1)
                    neighbors[count + i] = board[count + i - 1] + board[count + i + 1] + board[count + i - SIZE] + board[count + i - SIZE - 1] + board[count + i - SIZE +1];
                neighbors[i] = board[i - 1] + board[i - SIZE] + board[i - SIZE - 1];
            end
            else begin
                for (i = 0; i < STEP; i = i + 1)
                    neighbors[count + i] = neighbors[count + i];
            end*/
            for (i = 0; i < STEP; i = i + 1) begin //row
                j = count + i;
                if (j == 0) begin //top-left cornor
                    neighbors[i] = board[j + 1] + board[j + SIZE] + board[j + SIZE + 1];
                end
                else if (j == SIZE_SQUARE - SIZE) begin //bottom-left cornor
                    neighbors[i] = board[j - SIZE] + board[j + 1] + board[j - SIZE + 1];
                end
                else if (j == SIZE - 1) begin //top-right cornor
                    neighbors[i] = board[j - 1] + board[j + SIZE] + board[j + SIZE - 1];
                end
                else if (j == SIZE_SQUARE - 1) begin //bottom-right cornor
                    neighbors[i] = board[j - 1] + board[j - SIZE] + board[j - SIZE - 1];
                end
                else if (j < SIZE) begin //top line
                    neighbors[i] = board[j - 1] + board[j + 1] + board[j + SIZE] + board[j + SIZE - 1] + board[j + SIZE + 1];
                end
                else if (j > SIZE_SQUARE - SIZE - 1) begin //bottom line
                    neighbors[i] = board[j - 1] + board[j + 1] + board[j - SIZE] + board[j - SIZE - 1] + board[j - SIZE +1];
                end
                else if (j[BIT_NUM - 1:0] == 0) begin //left line
                    neighbors[i] = board[j + 1] + board[j - SIZE] + board[j - SIZE + 1] + board[j + SIZE] + board[j + SIZE + 1];
                end
                else if (j[BIT_NUM - 1:0] == SIZE - 1) begin //right line
                    neighbors[i] = board[j - 1] + board[j - SIZE] + board[j - SIZE - 1] + board[j + SIZE] + board[j + SIZE - 1];
                end
                else begin //normal case
                    neighbors[i] = board[j - 1] + board[j + 1] + board[j - SIZE] + board[j - SIZE - 1] + board[j - SIZE +1] + board[j + SIZE] + board[j + SIZE - 1] + board[j + SIZE + 1];
                end
                
                if (neighbors[i] == 3)
                    next_board[j] <= 1;
                else if (neighbors[i] == 2) 
                    next_board[j] <= board[j];
                else
                    next_board[j] <= 0;
            end
        end
    end
    
    /**
    
    This block contains an always block that is sensitive to a positive edge of the clock signal.
    If the reset button is pressed, it sets the next board state to 0.
    Otherwise, it loops through every cell in the board and checks the number of neighbors for each cell.
    Based on the number of neighbors, it sets the next board state for each cell.
    */
    /*always @(posedge clk) begin
        if (reset) begin
            next_board <= 0;
        end
        else begin
            for (j = 0; j < STEP; j = j + 1) begin
                if (neighbors[count + j] == 3)
                    next_board[count + j] <= 1;
                else if (neighbors[count + j] == 2) 
                    next_board[count + j] <= board[count + j];
                else
                    next_board[count + j] <= 0;
            end
        end
    end*/
    
    //current board result output
    assign board_out = board;
    
endmodule
