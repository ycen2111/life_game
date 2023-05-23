`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.05.2023 12:05:27
// Design Name: 
// Module Name: Mem_driver
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


module Mem_driver#(
    parameter MAX_ROW_BITS = 9, //512
    parameter MAX_COLUMN_BITS = 9, //512
    parameter MAX_ROW = 2 ** MAX_ROW_BITS,
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS
    )(
    input CLK,
    input RESET,
    input finish,
    input W_enable,
    input [MAX_ROW_BITS - 1 : 0] row_in, //start with 0
    input [MAX_COLUMN_BITS - 1 : 0] column_in,
    input [15 : 0] data_in,
    input [MAX_ROW_BITS - 1 : 0] row_out,
    input [MAX_COLUMN_BITS - 1 : 0] column_out,
    output [15 : 0] data_out
    );

    reg switch;
    reg [1 : 0] finish_edge;
    
    wire [2 ** (MAX_ROW_BITS + MAX_COLUMN_BITS - 4) - 1 : 0] cell_id_in, cell_id_out;
    wire W_enable_1, W_enable_2;
    wire [15 : 0] data_out_1, data_out_2;
    
    
    //(column/16)*MAX_ROW+row
    assign cell_id_in = {column_in[4 +: MAX_ROW_BITS - 4], row_in}; 
    assign cell_id_out = {column_out[4 +: MAX_ROW_BITS - 4], row_out};
    //write mem1, read mem2 when switch =1
    //read mem1, write mem1 when switch =0
    assign W_enable_1 = switch ? W_enable : 0;
    assign W_enable_2 = (~switch) ? W_enable : 0;
    assign data_out = switch ? data_out_2 : data_out_1;
    
    //first memory unit
    Cell_mem mem_1(
        .CLK(CLK),
        .RESET(RESET),
        .W_enable(W_enable_1),
        .data_in_add(cell_id_in),
        .data_in(data_in),
        .data_out_add(cell_id_out),
        .data_out(data_out_1)
    );
    
    //second memory unit
    Cell_mem mem_2(
        .CLK(CLK),
        .RESET(RESET),
        .W_enable(W_enable_2),
        .data_in_add(cell_id_in),
        .data_in(data_in),
        .data_out_add(cell_id_out),
        .data_out(data_out_2)
    );
    
    //find edge of finish signal
    always @(posedge CLK) begin
        if (RESET)
            finish_edge = 0;
        else
            finish_edge = {finish_edge[0], finish};
    end
    
    //change switch state when finish is in posedge
    always @(posedge CLK) begin
        if (RESET)
            switch <= 0;
        else begin
            if (finish_edge == 2'b01)
                switch <= ~switch;
            else
                switch <= switch;
        end
    end

endmodule
