`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2023 17:05:39
// Design Name: 
// Module Name: Game_logic
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


module Game_logic(
    input CLK,
    input RESET,
    input [17:0] row_1,
    input [17:0] row_2,
    input [17:0] row_3,
    output [15:0] OUT
    );
    
    reg [3:0] neighbors [15:0];
    reg [17:0] past_row_2;
    
    always @(posedge CLK) begin
        past_row_2 <= row_2;
    end
    
    genvar i;
    
    generate
        for (i = 0; i < 16; i = i + 1) begin : find_neighbors
            always @(posedge CLK) begin
                if (RESET)
                    neighbors[i] <= 0;
                else
                    neighbors[i] <= row_1[i] + row_1[i+1] + row_1[i+2] + row_2[i] + row_2[i+2] + row_3[i] + row_3[i+1] + row_3[i+2];
            end
            
            assign OUT[i] =  (neighbors[i] == 3) ? 1 : (neighbors[i] == 2) ? past_row_2[i+1] : 0;
        end
    endgenerate
    
endmodule
