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
    parameter MAX_COLUMN_BITS = 10, //1024
    parameter MAX_ROW = 2 ** MAX_ROW_BITS,
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS
    )(
    input CLK,
    input RESET,
    //using entering
    input enter,
    input finish,
    input W_enable,
    //write cell's row and column
    input [MAX_ROW_BITS - 1 : 0] ROW_IN, //start with 0
    input [MAX_COLUMN_BITS - 1 : 0] COLUMN_IN,
    input [15 : 0] data_in,
    //read cell's row and column
    input [MAX_ROW_BITS - 1 : 0] ROW_OUT,
    input [MAX_COLUMN_BITS - 1 : 0] COLUMN_OUT,
    output [17 : 0] data_out,
    //output single bit
    output data_out_1_bit,
    //input single bit
    input write_1_bit,
    input data_in_1_bit
    );

    reg switch;
    reg [1 : 0] finish_edge;
    reg [MAX_COLUMN_BITS - 1 : 0] column_out_delay;
    
    wire [MAX_ROW_BITS + MAX_COLUMN_BITS - 4 : 0] cell_id_in, cell_id_out;
    wire W_enable_1, W_enable_2;
    wire [17 : 0] data_out_1, data_out_2;
    wire [3 : 0] data_out_1_bit_id;
    wire [3 : 0] data_in_1_bit_id;
    
    wire [MAX_ROW_BITS - 1 : 0] row_in, row_out;
    wire [MAX_COLUMN_BITS - 1 : 0] column_in, column_out;
    
    assign row_in = ROW_IN - 1;
    assign row_out = ROW_OUT - 1;
    assign column_in = COLUMN_IN - 1;
    assign column_out = COLUMN_OUT - 1;
    
    //row*64 + column/16
    assign cell_id_in = {row_in, column_in[4 +: MAX_COLUMN_BITS - 4]}; 
    assign cell_id_out = {row_out, column_out[4 +: MAX_COLUMN_BITS - 4]};
    //read mem1, write mem1 when switch =0
    assign W_enable_1 = switch ? W_enable : 0;
    assign W_enable_2 = (~switch) ? W_enable : 0;
    assign data_out = enter? (switch ? data_out_2 : data_out_1) : (switch ? data_out_1 : data_out_2);
    //output exact required 1 cell
    assign data_out_1_bit_id = column_out_delay[3:0];
    assign data_out_1_bit = data_out[data_out_1_bit_id];
    
    assign data_in_1_bit_id = column_in[3:0];
    
    //first memory unit
    Cell_mem mem_1(
        .CLK(CLK),
        .RESET(RESET),
        .W_enable(W_enable_1),
        .write_1_bit(write_1_bit),
        .data_in_1_bit(data_in_1_bit),
        .element_id(data_in_1_bit_id),
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
        .write_1_bit(write_1_bit),
        .data_in_1_bit(data_in_1_bit),
        .element_id(data_in_1_bit_id),
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
    
    always @(posedge CLK) begin
        column_out_delay <= column_out;
    end

endmodule
