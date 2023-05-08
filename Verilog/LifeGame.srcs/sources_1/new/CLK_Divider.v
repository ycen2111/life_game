`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: /
// Engineer: /
// 
// Create Date: 27.01.2023 13:33:10
// Design Name: Yang Cen
// Module Name: CLK_10Hz
// Project Name: clock divider
// Target Devices: /
// Tool Versions: Vivado 2015.2
// Description: even divider
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CLK_Divider(
    input CLK,
    input RESET,
    input [3:0] index,
    output clk_out
    );
    
    // based on 100Mhz system clk
    reg [3:0] div_counter;
    
    reg div_clk;
    
    // counting the input clk
    always @(posedge CLK) begin
        if (RESET)
            div_counter<='d0;
        else begin
            if (div_counter == index)
                div_counter<='d0;
            else
                div_counter<=div_counter+1'd1;
        end
    end
    
    always @(posedge CLK) begin
        if (RESET)
            div_clk <= 'd0;
        else begin
            if (div_counter == 'd1)
                div_clk <= ~div_clk;
            else
                div_clk <= div_clk;
        end
    end
    
    assign clk_out = RESET ? 1'd0 : div_clk;
endmodule
