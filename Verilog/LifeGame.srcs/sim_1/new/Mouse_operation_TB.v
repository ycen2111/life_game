`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2023 12:38:00
// Design Name: 
// Module Name: Mouse_operation_TB
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


module Mouse_operation_TB();

    parameter MAX_ROW_BITS = 9; //512
    parameter MAX_COLUMN_BITS = 9; //512
    parameter MAX_ROW = 2 ** MAX_ROW_BITS;
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS;

    reg CLK, RESET;
    reg [11:0] MouseX, MouseY;
    
    always #5 CLK = ~CLK;
    
    Mouse_operation operation(
        .CLK(CLK),
        .RESET(RESET),
        //receive cell content
        /*input [MAX_ROW_BITS - 1 : 0] cell_row_num,
        input [MAX_COLUMN_BITS - 1 : 0] cell_column_num,*/
        //receive mouse coordinate
        .MouseX(MouseX),
        .MouseY(MouseY)
        //input [3:0] MouseStatus,
        //curent VGA point is belongs to mouse cell
        //output mouse_cell_pixcle
    );
    
    initial begin
        CLK = 0;
        RESET = 1;
        MouseX = 1;
        MouseY = 1;
        #50 RESET = 0;
        #50 MouseX = 17;
            MouseY = 17;
    end

endmodule
