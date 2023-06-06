`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2023 17:29:30
// Design Name: 
// Module Name: Game_logic_TB
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


module Game_logic_TB();

    reg CLK, RESET;
    reg [17:0] row_1, row_2, row_3;
    wire [15:0] OUT;

    Game_logic UUT(
    .CLK(CLK),
    .RESET(RESET),
    .row_1(row_1),
    .row_2(row_2),
    .row_3(row_3),
    .OUT(OUT)
    );
    
    always #5 CLK = ~CLK;
    
    initial begin
        CLK = 0;
        RESET = 1;
        #5 RESET = 0;
        #5 row_1 = 18'b111111111111111111;
            row_2 = 18'b100000000000000001;
            row_3 = 18'b100000000000000001;
    end

endmodule
