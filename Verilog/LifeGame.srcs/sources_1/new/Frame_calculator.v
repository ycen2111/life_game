`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2023 12:22:58
// Design Name: 
// Module Name: Frame_calculator
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


module Frame_calculator#(
    parameter MAX_ROW_BITS = 9, //512
    parameter MAX_COLUMN_BITS = 10, //1024
    parameter MAX_ROW = 2 ** MAX_ROW_BITS,
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS
    )(
    input CLK,
    input RESET,
    input enter,
    //start new frame calculation
    input new_frame,
    //canvas parameter
    input [MAX_ROW_BITS - 1:0] ROW,
    input [MAX_COLUMN_BITS - 1:0] COLUMN,
    //read mem
    output [MAX_ROW_BITS - 1:0] row_to_read_mem,
    output [MAX_COLUMN_BITS - 1:0] column_to_read_mem,
    input [17:0] data_from_mem,
    //write mem
    output [15:0] OUT,
    output mem_write_en,
    output [MAX_ROW_BITS - 1:0] row_to_write_mem,
    output [MAX_COLUMN_BITS - 1:0] column_to_write_mem,
    //calculation finished
    output frame_finish
    );
    
    wire [17:0] row_1, row_2, row_3;
    
    Frame_manager reader(
        .CLK(CLK),
        .RESET(RESET),
        .enter(enter),
        .new_frame(new_frame),
        .ROW(ROW),
        .COLUMN(COLUMN),
        //read mem
        .row_to_read_mem(row_to_read_mem),
        .column_to_read_mem(column_to_read_mem),
        .data_from_mem(data_from_mem),
        //calculate next frame
        .row_1(row_1),
        .row_2(row_2),
        .row_3(row_3),
        //write mem
        .row_to_write_mem(row_to_write_mem),
        .column_to_write_mem(column_to_write_mem),
        .mem_write_en(mem_write_en),
        //finish sign
        .frame_finish(frame_finish)
    );
    
    Game_logic Logic(
        .CLK(CLK),
        .RESET(RESET),
        //input
        .row_1(row_1),
        .row_2(row_2),
        .row_3(row_3),
        .OUT(OUT)
    );
    
    Frame_writer writer(
        .CLK(CLK),
        .RESET(RESET),
        .write_en(mem_write_en),
        //canvas parameter
        .ROW(ROW),
        .COLUMN(COLUMN)
        //write mem
        //.row_to_write_mem(row_to_write_mem),
        //.column_to_write_mem(column_to_write_mem)
    );
    
endmodule
