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
    wire write_cell_en, erase_cell_en, frame_write_en;
    wire [MAX_ROW_BITS - 1:0] row_to_read_mem;
    wire [MAX_COLUMN_BITS - 1:0] column_to_read_mem;
    wire [MAX_ROW_BITS - 1:0] ROW_OUT, ROW_IN, row_to_write_mem;
    wire [MAX_COLUMN_BITS - 1:0] COLUMN_OUT, COLUMN_IN, column_to_write_mem;
    wire [15 : 0] data_out_15_bits;
    wire [15:0] data_from_frame_to_mem;
    wire [2 : 0] cell_length_level;
    wire [MAX_ROW_BITS - 1 : 0] canvas_row;
    wire [MAX_COLUMN_BITS - 1 : 0] canvas_column;
    wire WE_buffer;
    
    assign ROW_OUT = WE_buffer ? row_out : row_to_read_mem;
    assign COLUMN_OUT = WE_buffer ? column_out : column_to_read_mem;
    assign ROW_IN = frame_write_en ? row_to_write_mem : cell_row_in;
    assign COLUMN_IN = frame_write_en ? column_to_write_mem : cell_column_in;
   
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
    
    Canvas_manager canvas(
        .CLK(CLK),
        .RESET(RESET),
        //button signal
        .up(up_releasing),
        .down(down_releasing),
        .left(left_releasing),
        .right(right_releasing),
        //axis state
        .axis(axis),
        //output canvas value
        .cell_length_level(cell_length_level),
        .canvas_row(canvas_row),
        .canvas_column(canvas_column)
    );
    
    seg7Driver seg7(
        .CLK(CLK),
        .init_process(RESET),
        .DATA_X(canvas_column),
        .DATA_Y(canvas_row),
        .axis(axis),
        .SEG_SELECT_OUT(SEG_SELECT_OUT),
        .HEX_OUT(HEX_OUT)
    );
    
    VGA_manager VGA(
        //Standard Signal
        .CLK(CLK),
        .RESET(RESET),
        .row_in(canvas_row),
        .column_in(canvas_column),
        .A_WE(MouseStatus[0]),
        .A_DATA_OUT(A_DATA_OUT),
        //research cell
        .cell_row_num(row_out),
        .cell_column_num(column_out),
        .WE_buffer(WE_buffer),
        .cell_value(data_out_1_bit),
        //input new cells when clicking
        .cell_row_in(cell_row_in),
        .cell_column_in(cell_column_in),
        .write_cell_en(write_cell_en),
        .erase_cell_en(erase_cell_en),
        //Canvas parameter
        .cell_length_level(cell_length_level),
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
        .finish(frame_finish),
        .W_enable(write_cell_en || erase_cell_en || frame_write_en),
        .ROW_IN(ROW_IN), //start with 0
        .COLUMN_IN(COLUMN_IN),
        .data_in(data_from_frame_to_mem),
        //input [15 : 0] data_in,
        .ROW_OUT(ROW_OUT/*row_to_read_mem*/),
        .COLUMN_OUT(COLUMN_OUT/*column_to_read_mem*/),
        .data_out(data_out_15_bits),
        .data_out_1_bit(data_out_1_bit),
        //input single bit
        .write_1_bit(write_cell_en || erase_cell_en),
        .data_in_1_bit(write_cell_en ? 1 : 0)
    );
    
    Frame_calculator Frame(
        //Standard Signal
        .CLK(CLK),
        .RESET(RESET),
        .enter(enter),
        //start new frame calculation
        .new_frame(WE_buffer),
        //canvas parameter
        .ROW(canvas_row),
        .COLUMN(canvas_column),
        //read mem
        .row_to_read_mem(row_to_read_mem),
        .column_to_read_mem(column_to_read_mem),
        .data_from_mem(data_out_15_bits),
        //write mem
        .OUT(data_from_frame_to_mem),
        .mem_write_en(frame_write_en),
        .row_to_write_mem(row_to_write_mem),
        .column_to_write_mem(column_to_write_mem),
        //finish sign
        .frame_finish(frame_finish)
    );
    
endmodule
