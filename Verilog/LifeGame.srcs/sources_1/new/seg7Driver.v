`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.02.2023 14:16:16
// Design Name: 
// Module Name: seg7Driver
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


module seg7Driver(
    input CLK, 
    input init_process,
    input [11:0] DATA_X,
    input [11:0] DATA_Y,
    input axis,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] HEX_OUT
    );
    
    //turn on or off dot LED
    parameter DOT = 1'd0;
    //display a "-"
    parameter DASH_SIGN = 8'b10111111;
    
    //sweep switch counter and select
    reg [7:0] curr_counter, next_counter = 0;
    reg [1:0] curr_SEG_SELECT, next_SEG_SELECT = 2'b00;
    reg Curr_disPosition, Next_disPosition;
    //4 bytes HEX display value
    wire [15:0] displayStream;
    //one byte that will be displayed in this moment
    wire [3:0] inputData;
    //decoded byte code
    wire [7:0] HEX_read;
    
    //decoded one byte to output
    seg7decoder seg(
        .SEG_SELECT_IN(curr_SEG_SELECT),
        .BIN_IN(inputData),
        .DOT_IN(DOT),
        .SEG_SELECT_OUT(SEG_SELECT_OUT),
        .HEX_OUT(HEX_read)
    );
    
    //counting sweep frequency
    always @(posedge CLK) begin
        if (curr_counter == 0)
            next_SEG_SELECT <= curr_SEG_SELECT + 1'b1;

        next_counter <= curr_counter + 1'b1;
    end
    
    //copy next value into current variables
    always @(posedge CLK) begin
        curr_counter <= next_counter;
        curr_SEG_SELECT <= next_SEG_SELECT;
        Curr_disPosition <= Next_disPosition;
    end
    
    //determine display content
    assign displayStream = axis ? {4'hb, DATA_Y} : {4'ha, DATA_X};
    //pass 1 byte into 7-segments decoder in each time
    assign inputData = (curr_SEG_SELECT == 2'b00) ? displayStream[3:0] : (curr_SEG_SELECT == 2'b01) ? displayStream[7:4] : (curr_SEG_SELECT == 2'b10) ? displayStream[11:8] : displayStream[15:12];
    //output "-" sign if mouse is in init state
    assign HEX_OUT = init_process ? DASH_SIGN : HEX_read;
endmodule
