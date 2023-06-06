`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2023 12:24:55
// Design Name: 
// Module Name: Mouse_operation
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


module Mouse_operation#(
    parameter MAX_CELL_LENGTH_BITS = 6,
    parameter MAX_ROW_BITS = 9, //512
    parameter MAX_COLUMN_BITS = 10, //1024
    parameter MAX_ROW = 2 ** MAX_ROW_BITS,
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS
    )(
    input CLK,
    input RESET,
    input [MAX_ROW_BITS:0] row_in,
    input [MAX_COLUMN_BITS:0] column_in,
    //receive cell content
    input [MAX_ROW_BITS - 1 : 0] cell_row_num,
    input [MAX_COLUMN_BITS - 1 : 0] cell_column_num,
    input [2:0] cell_length_level,
    //button event
    input up_button,
    input down_button,
    //receive mouse coordinate
    input [11:0] MouseX,
    input [11:0] MouseY,
    input [3:0] MouseStatus,
    //output screen parameter
    output reg [MAX_ROW_BITS + MAX_CELL_LENGTH_BITS - 1 : 0] start_row_num,
    output reg [MAX_COLUMN_BITS + MAX_CELL_LENGTH_BITS - 1 : 0] start_column_num,
    //enter new cells when clicking
    output [MAX_ROW_BITS - 1 : 0] cell_row_in,
    output [MAX_COLUMN_BITS - 1 : 0] cell_column_in,
    output write_cell_en,
    output erase_cell_en,
    //curent VGA point is belongs to mouse cell
    output mouse_cell_pixcle,
    //curent VGA point is belongs to bordar cell
    output bordar_cell_pixcle
    );
    
    reg [MAX_ROW_BITS - 1 : 0] past_cell_row_num;
    reg [MAX_COLUMN_BITS - 1 : 0] past_cell_column_num;
    
    reg [11 : 0] past_MouseX, past_MouseY;

    wire [MAX_ROW_BITS - 1 : 0] mouse_cell_row;
    wire [MAX_COLUMN_BITS - 1 : 0] mouse_cell_column;
    wire [MAX_CELL_LENGTH_BITS - 1 : 0] cell_length;
    
    assign cell_length = 2 << cell_length_level;
    
    //mouse_cell = (Mouse_coodinate + start_pixcel) / cell_length
    assign mouse_cell_column = (MouseX + start_column_num) >> cell_length_level;
    assign mouse_cell_row = (MouseY + start_row_num) >> cell_length_level;
    
    //this pixcle belongs to mouse cell
    assign mouse_cell_pixcle = (past_cell_row_num == mouse_cell_row) & (past_cell_column_num == mouse_cell_column);
    //boardar pixcle
    assign bordar_cell_pixcle = (past_cell_row_num <= row_in) && (past_cell_column_num <= column_in) && (past_cell_row_num == 0 || past_cell_row_num == row_in || past_cell_column_num == 0 || past_cell_column_num == column_in);
    
    //enter new cells when clicking
    assign cell_row_in = mouse_cell_row;
    assign cell_column_in = mouse_cell_column;
    assign write_cell_en = MouseStatus[0] && (cell_row_in <= row_in) && (cell_column_in <= column_in);
    assign erase_cell_en = MouseStatus[1];
    
    always @(posedge CLK) begin
        past_cell_row_num <= cell_row_num;
        past_cell_column_num <= cell_column_num;
        past_MouseX <= MouseX;
        past_MouseY <= MouseY;
    end
    
    always @(posedge CLK) begin
        if (RESET) begin
            start_row_num <= 0;
            start_column_num <= 0;
        end
        else begin
            //right key pressed
            if (MouseStatus[2]) begin
                start_row_num <= start_row_num - (MouseY - past_MouseY);
                start_column_num <= start_column_num - (MouseX - past_MouseX);
            end
            else begin
                start_row_num <= start_row_num;
                start_column_num <= start_column_num;
            end
        end
    end

endmodule
