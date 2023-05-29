`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2023 14:04:28
// Design Name: 
// Module Name: CLK_1Hz
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


module CLK_1Hz(
    input CLK,
    input RESET,
    output reg CLK_out
    );
    
    //divide 100Mhz clk into 10Hz
    parameter CLK_PERIOD = 100000000/2/2;
    
    reg [25:0] counter;
    
    always @(posedge CLK) begin
        if (RESET) begin
            counter <= 0;
            CLK_out <= 0;
        end
        else begin
            if (counter < CLK_PERIOD - 1) begin
                counter <= counter + 1;
                CLK_out <= CLK_out;
            end
            else begin
                counter <= 0;
                CLK_out <= ~ CLK_out;
            end
        end
    end
    
endmodule
