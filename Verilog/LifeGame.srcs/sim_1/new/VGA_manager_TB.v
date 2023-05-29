`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2023 12:40:06
// Design Name: 
// Module Name: VGA_manager_TB
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


module VGA_manager_TB();

    reg CLK, RESET;
    wire VGA_HS, VGA_VS;
    wire [3:0] VGA_RED, VGA_GREEN, VGA_BLUE;

    VGA_manager UUT(
    //Standard Signal
        .CLK(CLK),
        .RESET(RESET),
        //VGA Port Interface
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_RED(VGA_RED),
        .VGA_GREEN(VGA_GREEN),
        .VGA_BLUE(VGA_BLUE)
    );
    
    always #5 CLK = ~CLK;
    
    initial begin
        CLK = 0;
        RESET = 1;
        #50 RESET = 0;
    end

endmodule
