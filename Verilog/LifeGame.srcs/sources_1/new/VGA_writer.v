`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.05.2023 17:39:54
// Design Name: 
// Module Name: VGA_gen
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


module VGA_writer#(
    parameter MAX_CELL_LENGTH_BITS = 6,
    parameter MAX_ROW_BITS = 9, //512
    parameter MAX_COLUMN_BITS = 10, //1024
    parameter MAX_ROW = 2 ** MAX_ROW_BITS,
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS
    )(
    input CLK,
    input RESET,
    input read_finish,
    //input screen parameter
    input [2:0] cell_length_level,
    input [MAX_ROW_BITS + MAX_CELL_LENGTH_BITS - 1 : 0] start_row_num,
    input [MAX_COLUMN_BITS + MAX_CELL_LENGTH_BITS - 1 : 0] start_column_num,
    //receive cell content
    output [MAX_ROW_BITS - 1 : 0] cell_row_num,
    output [MAX_COLUMN_BITS - 1 : 0] cell_column_num,
    input cell_value,
    //rewrite VGA buffer
    output [18 : 0] VGA_add,
    output VGA_data_out,
    output WE_buffer
    );
    
    parameter SCREEN_COLUMN = 640 - 1;
    parameter SCREEN_ROW = 480 - 1;
    parameter   IDLE = 0,
                WRITE_VGA = 1;
    
    //VGA row and column
    reg [9 : 0] curr_screen_row, next_screen_row, past_screen_row;
    reg [9 : 0] curr_screen_column, next_screen_column, past_screen_column;
    
    reg [1 : 0] curr_state, next_state;
    
    reg [1:0] read_finish_edge;
    reg curr_WE_buffer, next_WE_buffer;
    
    //record read_finish and detect its signal edge
    always @(posedge CLK) begin
        if (RESET)
            read_finish_edge <= 0;
        else
            read_finish_edge <= {read_finish_edge[0], read_finish};
    end
    
    always @(posedge CLK) begin
        if (RESET) begin
            curr_state <= IDLE;
            curr_screen_row <= 0;
            curr_screen_column <= 0;
            curr_WE_buffer <= 0;
        end
        else begin
            curr_state <= next_state;
            curr_screen_row <= next_screen_row;
            curr_screen_column <= next_screen_column;
            past_screen_row <= curr_screen_row;
            past_screen_column <= curr_screen_column;
            curr_WE_buffer <= next_WE_buffer;
        end
    end
    
    always @(*) begin
        next_state = curr_state;
        next_screen_row = curr_screen_row;
        next_screen_column = curr_screen_column;
        next_WE_buffer = curr_WE_buffer;
        
        case (curr_state)
            IDLE: begin
                //detect posedge of write_en
                if (read_finish_edge == 2'b01) begin
                    next_state = WRITE_VGA;
                    next_WE_buffer = 1;
                end
            end
            
            WRITE_VGA: begin
                if (curr_screen_column < SCREEN_COLUMN) begin
                    next_screen_column = curr_screen_column + 1;
                    
                end
                else begin
                    next_screen_column = 0;
                    
                    if (curr_screen_row < SCREEN_ROW) begin
                        next_screen_row = curr_screen_row + 1;
                    end
                    else begin
                        next_screen_row = 0;
                        next_WE_buffer = 0;
                        next_state = IDLE;
                    end
                end
            end
        endcase
    end
    
    //output row and column number to cell Mem
    //(start_num + curr_screen_num) / cell_length
    assign cell_column_num = (start_column_num + curr_screen_column) >> cell_length_level;
    assign cell_row_num = (start_row_num + curr_screen_row) >> cell_length_level;
    assign VGA_add = {past_screen_row[8:0], past_screen_column};
    assign VGA_data_out = cell_value;
    assign WE_buffer = curr_WE_buffer;
    
endmodule
