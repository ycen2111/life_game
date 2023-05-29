`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.05.2023 14:23:47
// Design Name: 
// Module Name: TOP
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


module TOP#(
    parameter MAX_ROW_BITS = 9, //512
    parameter MAX_COLUMN_BITS = 10, //1024
    parameter MAX_ROW = 2 ** MAX_ROW_BITS,
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS
    )(
    //Standard Signal
    input CLK,
    input RESET,
    //user entering
    input enter,
    //button input
    input [4:0] button_in,
    //Mouse Bus
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    //7 segments output
    input axis,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] HEX_OUT,
    //VGA outputs
    output VGA_HS,
    output VGA_VS,
    output [3:0] VGA_RED,
    output [3:0] VGA_GREEN,
    output [3:0] VGA_BLUE
    );
    
    wire up_releasing, down_releasing, left_releasing, right_releasing, center_releasing;
    wire [3:0] MouseStatus;
    wire [11:0] MouseX, MouseY;
    wire A_DATA_OUT;
    wire [MAX_ROW_BITS - 1 : 0] row_out;
    wire [MAX_COLUMN_BITS - 1 : 0] column_out;
    wire data_out_1_bit;
    wire [MAX_ROW_BITS - 1 : 0] cell_row_in;
    wire [MAX_COLUMN_BITS - 1 : 0] cell_column_in;
    wire write_cell_en, erase_cell_en;
       
    Button_detector detector(
        //Standard Inputs
        .CLK(CLK),
        .RESET(RESET),
        //button signal input
        .button_in(button_in),
        //detect button releasing
        .up_releasing(up_releasing),
        .down_releasing(down_releasing),
        .left_releasing(left_releasing),
        .right_releasing(right_releasing),
        .center_releasing(center_releasing)
    );
    
    MouseTransceiver mouse(
        //output [3:0] M_state_check,
        //output [3:0] T_state_check,
        //output [2:0] R_state_check,
    
        //Standard Inputs
        .CLK(CLK),
        .RESET(RESET),
        //IO - Mouse side
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        // Mouse data information
        .MouseStatus(MouseStatus),
        .MouseX(MouseX),
        .MouseY(MouseY)
    );
    
    seg7Driver seg7(
        .CLK(CLK),
        .init_process(RESET),
        .DATA_X(MouseX),
        .DATA_Y(MouseY),
        .axis(axis),
        .SEG_SELECT_OUT(SEG_SELECT_OUT),
        .HEX_OUT(HEX_OUT)
    );
    
    VGA_manager VGA(
        //Standard Signal
        .CLK(CLK),
        .RESET(RESET),
        .row_in(MouseY[9:0]),
        .column_in(MouseX[9:0]),
        .A_WE(MouseStatus[0]),
        .A_DATA_OUT(A_DATA_OUT),
        //research cell
        .cell_row_num(row_out),
        .cell_column_num(column_out),
        .cell_value(data_out_1_bit),
        //input new cells when clicking
        .cell_row_in(cell_row_in),
        .cell_column_in(cell_column_in),
        .write_cell_en(write_cell_en),
        .erase_cell_en(erase_cell_en),
        //button event
        .up_button(up_releasing),
        .down_button(down_releasing),
        //receive mouse coordinate
        .MouseX(MouseX),
        .MouseY(MouseY),
        .MouseStatus(MouseStatus),
        //VGA Port Interface
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_RED(VGA_RED),
        .VGA_GREEN(VGA_GREEN),
        .VGA_BLUE(VGA_BLUE)
    );
    
    Mem_driver driver (
        //Standard Signal
        .CLK(CLK),
        .RESET(RESET),
        .enter(enter),
        //input finish,
        .W_enable(write_cell_en || erase_cell_en),
        .row_in(cell_row_in), //start with 0
        .column_in(cell_column_in),
        //input [15 : 0] data_in,
        .row_out(row_out),
        .column_out(column_out),
        /*output [15 : 0] data_out,*/
        .data_out_1_bit(data_out_1_bit),
        //input single bit
        .write_1_bit(write_cell_en || erase_cell_en),
        .data_in_1_bit(write_cell_en ? 1 : 0)
    );
    
endmodule
