`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.05.2023 20:26:35
// Design Name: 
// Module Name: Find_neighbors_TB
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


module Find_neighbors_TB();

    parameter ROW = 16;
    parameter COLUMN = 16;
    parameter INPUT_SIZE = (ROW + 2) * (COLUMN + 2); //the core modified matrix and its extra nearby cell
    parameter OUTPUT_SIZE = ROW * COLUMN;
    
    reg CLK, RESET;
    reg [INPUT_SIZE - 1:0] cell_in;
    wire [OUTPUT_SIZE - 1:0] cell_out;
    
    always #5 CLK = ~CLK;
    
    Find_neighbors UUT(
        .CLK(CLK),
        .RESET(RESET),
        .cell_in(cell_in),
        .cell_out(cell_out)
        );

    integer i;

    initial begin
        CLK = 0;
        RESET = 1;
        /*for (i = 0; i < INPUT_SIZE; i = i + 1)
            cell_in[i] = 1;*/
        cell_in = 25'b0000001110011100111000000;
        #100 RESET = 0; //start work
    end

endmodule
