`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.05.2023 19:32:58
// Design Name: 
// Module Name: Find_neighbors
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: calculates the sum of neighbors for each cell in a matrix and implements the rules of Conway's Game of Life
//              The updated cell states are output as cell_out after each clock cycle.
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Find_neighbors
    #(
    parameter ROW = 16,
    parameter COLUMN = 16,
    parameter INPUT_SIZE = (ROW + 2) * (COLUMN + 2), //the core modified matrix and its extra nearby cell
    parameter OUTPUT_SIZE = ROW * COLUMN
    )(
    input CLK,
    input RESET,
    input [INPUT_SIZE - 1 : 0] cell_in,
    output [OUTPUT_SIZE - 1 : 0] cell_out
    );
    
    reg [2 : 0] neighbors [0 : OUTPUT_SIZE - 1];
    reg [OUTPUT_SIZE - 1 : 0] past_cell_in;
    reg [OUTPUT_SIZE - 1 : 0] new_cell;
    
    genvar i, j, z;
    
    generate
        /*calculates the sum of neighbors for each cell and stores it in the neighbors array. 
        It also saves the current state of the cell in the past_cell_in array.*/
        for (i = 1; i < ROW + 1; i = i + 1) begin : row_num
            for (j = 1; j < COLUMN + 1; j = j + 1) begin : column_num
                always @(posedge CLK) begin
                    if (RESET)
                        neighbors [(i - 1) * COLUMN + (j - 1)] <= 0;
                    //num = i * (COLUMN + 2) + j
                    else begin
                        neighbors [(i - 1) * COLUMN + (j - 1)] <= cell_in[(i - 1) * (COLUMN + 2) + j - 1] + cell_in[(i - 1) * (COLUMN + 2) + j] + cell_in[(i - 1) * (COLUMN + 2) + j + 1] + cell_in[i * (COLUMN + 2) + j - 1] + cell_in[i * (COLUMN + 2) + j + 1] + cell_in[(i + 1) * (COLUMN + 2) + j - 1] + cell_in[(i + 1) * (COLUMN + 2) + j] + cell_in[(i + 1) * (COLUMN + 2) + j + 1];
                        past_cell_in [(i - 1) * COLUMN + (j - 1)] <= cell_in[i * (COLUMN + 2) + j];
                    end
                end
            end
        end
        
        /*determines the new state of each cell based on the number of neighbors, 
        following the rules of Conway's Game of Life.*/
        for (z = 0; z < ROW * COLUMN; z = z + 1) begin : depend_neighbors
            always @(posedge CLK) begin
                if (neighbors[z] == 3)
                    new_cell[z] <= 1;
                else if (neighbors[z] == 2)
                    new_cell[z] <= past_cell_in[z];
                else
                    new_cell[z] <= 0;
            end
        end
    endgenerate
    
    assign cell_out = new_cell;
    
endmodule
