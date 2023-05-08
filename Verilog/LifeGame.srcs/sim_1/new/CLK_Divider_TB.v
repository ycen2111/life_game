`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: /
// Engineer: /
// 
// Create Date: 08.05.2023 11:38:41
// Design Name: Yang Cen
// Module Name: CLK_Divider_TB
// Project Name: Conway's Life Game
// Target Devices: X7 236-L
// Tool Versions: Vivado 2015.2
// Description: testbench of CLK_Divider.v
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CLK_Divider_TB();

    reg clk, reset;
    reg [3:0] index;
    wire clk_out;
    
    always #5 clk = ~clk;
    
    CLK_Divider UUT(
        .CLK(clk),
        .RESET(reset),
        .index(index),
        .clk_out(clk_out)
        );

    initial begin
        clk = 0;
        reset = 1;
        index = 0;
        #100 reset = 0;
        #200 index = 1;
        #200 index = 5;
    end

endmodule
