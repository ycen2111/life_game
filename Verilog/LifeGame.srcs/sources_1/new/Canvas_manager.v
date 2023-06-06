`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2023 14:19:27
// Design Name: 
// Module Name: Canvas_manager
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


module Canvas_manager#(
    parameter MAX_CELL_LENGTH_BITS = 6,
    parameter MAX_ROW_BITS = 9, //512
    parameter MAX_COLUMN_BITS = 10, //1024
    parameter MAX_ROW = 2 ** MAX_ROW_BITS,
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS
    )(
    input CLK,
    input RESET,
    //button signal
    input up,
    input down,
    input left,
    input right,
    //axis state
    input axis,
    //output canvas value
    output reg [2:0] cell_length_level,
    output reg [MAX_ROW_BITS:0] canvas_row,
    output reg [MAX_COLUMN_BITS:0] canvas_column
    );
    
    parameter ORIGIN_ROW = 64;
    parameter ORIGIN_COLUMN = 64;
    
    always @(posedge CLK) begin
        if (RESET) begin
            cell_length_level <= 4;
        end
        else begin
            if (up && cell_length_level <= MAX_CELL_LENGTH_BITS)
                cell_length_level <= cell_length_level + 1;
            else if (down && cell_length_level > 0)
                cell_length_level <= cell_length_level - 1;
            else
                cell_length_level <= cell_length_level;
        end
    end
    
    always @(posedge CLK) begin
        if (RESET) begin
            canvas_row <= ORIGIN_ROW;
            canvas_column <= ORIGIN_COLUMN;
        end
        else begin
            //row
            if (axis) begin
                if (left && canvas_row > 6)
                    canvas_row <= canvas_row - 1;
                else if (right && canvas_row < MAX_ROW)
                    canvas_row <= canvas_row + 1;
                else
                    canvas_row <= canvas_row;
            end
            //column
            else begin
                if (left && canvas_column > 6)
                    canvas_column <= canvas_column - 1;
                else if (right && canvas_column < MAX_COLUMN)
                    canvas_column <= canvas_column + 1;
                else
                    canvas_column <= canvas_column;
            end
        end
    end
    
endmodule
