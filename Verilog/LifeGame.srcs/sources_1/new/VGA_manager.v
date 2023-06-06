`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2023 12:24:58
// Design Name: 
// Module Name: VGA_manager
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


module VGA_manager#(
    parameter MAX_CELL_LENGTH_BITS = 6,
    parameter MAX_ROW_BITS = 9, //512
    parameter MAX_COLUMN_BITS = 10, //1024
    parameter MAX_ROW = 2 ** MAX_ROW_BITS,
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS
    )(
    //Standard Signal
    input CLK,
    input RESET,
    input [MAX_ROW_BITS:0] row_in,
    input [MAX_COLUMN_BITS:0] column_in,
    input A_WE,
    output A_DATA_OUT,
    //research cell
    output [MAX_ROW_BITS - 1 : 0] cell_row_num,
    output [MAX_COLUMN_BITS - 1 : 0] cell_column_num,
    input cell_value,
    //input new cells when clicking
    output [MAX_ROW_BITS - 1 : 0] cell_row_in,
    output [MAX_COLUMN_BITS - 1 : 0] cell_column_in,
    output write_cell_en,
    output erase_cell_en,
    //Canvas parameter
    input [2:0] cell_length_level,
    //receive mouse coordinate
    input [11:0] MouseX,
    input [11:0] MouseY,
    input [3:0] MouseStatus,
    //VGA Port Interface
    output VGA_HS,
    output VGA_VS,
    output [3:0] VGA_RED,
    output [3:0] VGA_GREEN,
    output [3:0] VGA_BLUE
    );
    
    wire [18:0] VGA_ADDR_OUT, VGA_ADDR_IN;
    wire VGA_DATA_OUT, VGA_DATA_IN, data_from_generator;
    wire read_finish;
    wire WE_buffer;
    wire VGA_data_out;
    wire [MAX_ROW_BITS + MAX_CELL_LENGTH_BITS - 1 : 0] start_row_num;
    wire [MAX_COLUMN_BITS + MAX_CELL_LENGTH_BITS - 1 : 0] start_column_num;
    wire mouse_cell_pixcle, bordar_cell_pixcle;
    
    VGA_reader reader(
        //Standard Signal
        .CLK(CLK),
        .RESET(RESET),
        // Frame Buffer (Dual Port memory) Interface
        .VGA_ADDR(VGA_ADDR_OUT),
        .VGA_DATA(VGA_DATA_OUT),
        //VGA Port Interface
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_COLOUR({VGA_RED, VGA_GREEN, VGA_BLUE}),
        .read_finish(read_finish)
    );
    
    assign VGA_DATA_IN = mouse_cell_pixcle ? CLK_out : bordar_cell_pixcle ? 1'b1 : data_from_generator;
    
    VGA_buffer buffer(
        // Port A - Read/Write
        .A_CLK(CLK),
        .A_ADDR(/*{row_in, column_in}*/VGA_ADDR_IN),
        .A_DATA_IN(VGA_DATA_IN), // Pixel Data In
        .A_DATA_OUT(A_DATA_OUT),
        .A_WE(WE_buffer), // Write Enable
        //Port B - Read Only
        .B_CLK(CLK),
        .B_ADDR(VGA_ADDR_OUT), // Pixel Data Out
        .B_DATA(VGA_DATA_OUT)
    );
    
    VGA_writer writer(
        //Standard Signal
        .CLK(CLK),
        .RESET(RESET),
        .read_finish(read_finish),
        //Input screen parameter
        .cell_length_level(cell_length_level),
        .start_row_num(start_row_num),
        .start_column_num(start_column_num),
        //receive cell content
        .cell_row_num(cell_row_num),
        .cell_column_num(cell_column_num),
        .cell_value(cell_value),
        //rewrite VGA buffer
        .VGA_add(VGA_ADDR_IN),
        .VGA_data_out(data_from_generator),
        .WE_buffer(WE_buffer)
    );
    
    Mouse_operation operator(
        .CLK(CLK),
        .RESET(RESET),
        .row_in(row_in),
        .column_in(column_in),
        //receive cell content
        .cell_row_num(cell_row_num),
        .cell_column_num(cell_column_num),
        .cell_length_level(cell_length_level),
        //receive mouse coordinate
        .MouseX(MouseX),
        .MouseY(MouseY),
        .MouseStatus(MouseStatus),
        //output screen parameter
        .start_row_num(start_row_num),
        .start_column_num(start_column_num),
        //input new cells when clicking
        .cell_row_in(cell_row_in),
        .cell_column_in(cell_column_in),
        .write_cell_en(write_cell_en),
        .erase_cell_en(erase_cell_en),
        //curent VGA point is belongs to mouse cell
        .mouse_cell_pixcle(mouse_cell_pixcle),
        //curent VGA point is belongs to bordar cell
        .bordar_cell_pixcle(bordar_cell_pixcle)
    );
    
    wire CLK_out;
    
    CLK_1Hz CLK_divider(
        .CLK(CLK),
        .RESET(RESET),
        .CLK_out(CLK_out)
    );
    
endmodule
