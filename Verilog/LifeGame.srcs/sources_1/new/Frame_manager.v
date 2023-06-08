`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2023 19:10:53
// Design Name: 
// Module Name: Frame_manager
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


module Frame_manager#(
    parameter MAX_ROW_BITS = 9, //512
    parameter MAX_COLUMN_BITS = 10, //1024
    parameter MAX_ROW = 2 ** MAX_ROW_BITS,
    parameter MAX_COLUMN = 2 ** MAX_COLUMN_BITS
    )(
    input CLK,
    input RESET,
    input enter,
    input new_frame,
    input [MAX_ROW_BITS - 1:0] ROW,
    input [MAX_COLUMN_BITS - 1:0] COLUMN,
    //read mem
    output [MAX_ROW_BITS - 1:0] row_to_read_mem,
    output [MAX_COLUMN_BITS - 1:0] column_to_read_mem,
    input [15:0] data_from_mem,
    //calculate next frame
    output [17:0] row_1,
    output [17:0] row_2,
    output [17:0] row_3,
    //write mem
    output [MAX_ROW_BITS - 1:0] row_to_write_mem,
    output [MAX_COLUMN_BITS - 1:0] column_to_write_mem,
    output mem_write_en,
    //finish sign
    output frame_finish
    );

    reg [16:0] cache [0 : MAX_ROW - 1];
    reg [15:0] temp_cache [0:2];
    reg [1:0] frame_edge;
    reg [MAX_ROW_BITS - 1:0] curr_row, next_row;
    reg [MAX_ROW_BITS - 1:0] past_row_1, past_row_2, past_row_3, past_row_4;
    reg [MAX_COLUMN_BITS - 1:0] past_column_1, past_column_2, past_column_3, past_column_4;
    reg [MAX_COLUMN_BITS - 1:0] curr_column, next_column;
    
    parameter MEM_UNIT = 16;
    parameter IDLE = 0,
                READ_FIRST_COLUMN_1 = 1,
                READ_FIRST_COLUMN_2 = 2,
                READ_FIRST_COLUMN_3 = 3,
                LOOP_1 = 4,
                LOOP_2 = 5,
                LOOP_3 = 6,
                LOOP_4 = 7,
                LOOP_5 = 8;
    
    reg [10:0] curr_state, next_state;
    reg [1:0] mem_write_en_counter;
    reg mem_write;
    
    assign frame_finish = (curr_state == IDLE);
    
    assign row_to_read_mem = curr_row;
    assign column_to_read_mem = curr_column;
    
    assign row_1 = {temp_cache[0][0], cache[past_row_4]};
    assign row_2 = {temp_cache[1][0], cache[past_row_3]};
    assign row_3 = {temp_cache[2][0], cache[past_row_2]};
    
    assign mem_write_en = mem_write_en_counter[1];
    assign row_to_write_mem = past_row_4;
    assign column_to_write_mem = past_column_4 - MEM_UNIT;
    
    always @(posedge CLK) begin
        if (RESET) begin
            past_row_1 <= 0;
            past_row_2 <= 0;
            past_row_3 <= 0;
            past_row_4 <= 0;
            past_column_1 <= 0;
            past_column_2 <= 0;
            past_column_3 <= 0;
            past_column_4 <= 0;
            mem_write_en_counter <= 0;
        end
        else begin
            past_row_1 <= curr_row;
            past_row_2 <= past_row_1;
            past_row_3 <= past_row_2;
            past_row_4 <= past_row_3;
            past_column_1 <= curr_column;
            past_column_2 <= past_column_1;
            past_column_3 <= past_column_2;
            past_column_4 <= past_column_3;
            mem_write_en_counter <= {mem_write_en_counter[0], mem_write};
        end
    end
    
    always@(posedge CLK) begin
        if (RESET) begin
            curr_state <= IDLE;
            frame_edge <= 0;
            curr_row <= 1;
            curr_column <= 1;
        end
        else begin
            curr_state <= next_state;
            frame_edge <= {frame_edge[0], new_frame};
            curr_row <= next_row;
            curr_column <= next_column;
        end
    end
    
    always @(*) begin
        next_state = curr_state;
        next_row = curr_row;
        next_column = curr_column;
        
        case (curr_state)
            IDLE: begin
                if (frame_edge == 2'b10 && enter) begin
                    next_state = READ_FIRST_COLUMN_1;
                end
            end
            
            READ_FIRST_COLUMN_1 : begin
                next_row = curr_row + 1;
                next_state = READ_FIRST_COLUMN_2;
            end
            
            READ_FIRST_COLUMN_2: begin
                next_row = curr_row + 1;
                if (curr_row == ROW) begin
                    next_row = 1;
                    next_column = curr_column + MEM_UNIT;
                    next_state = READ_FIRST_COLUMN_3;
                end
            end
            
            READ_FIRST_COLUMN_3: begin
                next_row = curr_row + 1;
                next_state = LOOP_1;
            end
            
            LOOP_1: begin
                next_row = curr_row + 1;
                next_state = LOOP_2;
            end
            
            LOOP_2: begin
                next_row = curr_row + 1;
                next_state = LOOP_3;
            end
            
            LOOP_3: begin
                next_row = curr_row + 1;
                if (curr_row == ROW) begin
                    next_row = 1;
                    next_column = curr_column + MEM_UNIT;
                    next_state = LOOP_4;
                end
            end
            
            LOOP_4: begin
                next_row = curr_row + 1;
                next_state = LOOP_5;
            end
            
            LOOP_5: begin
                next_row = curr_row + 1;
                if (curr_column < COLUMN + MEM_UNIT - 1)
                    next_state = LOOP_3;
                else begin
                    next_state = IDLE;
                    next_row = 1;
                    next_column = 1;
                end
            end
            
        endcase
    end
    
    always @(posedge CLK) begin
        if (RESET) begin
            cache[0] <= 0;
            cache[ROW] <= 0;
            temp_cache[0] <= 0;
            temp_cache[1] <= 0;
            temp_cache[2] <= 0;
            mem_write <= 0;
        end
        else if (curr_state == READ_FIRST_COLUMN_2) begin
            cache[past_row_1] <= {data_from_mem, 1'd0};
        end
        else if (curr_state == LOOP_1) begin
            mem_write <= 1'd1;
            temp_cache[0] <= 0;
            temp_cache[1] <= data_from_mem;
        end
        else if (curr_state == LOOP_2) begin
            temp_cache[2] <= data_from_mem;
        end
        else if (curr_state == LOOP_3) begin
            temp_cache[0] <= temp_cache[1];
            temp_cache[1] <= temp_cache[2];
            temp_cache[2] <= data_from_mem;
            cache[past_row_4] <= {temp_cache[0], cache[past_row_4][16]};
        end
        else if (curr_state == LOOP_4) begin
            temp_cache[0] <= temp_cache[1];
            temp_cache[1] <= temp_cache[2];
            temp_cache[2] <= 0;
            mem_write <= 1'd0;
            cache[past_row_4] <= {temp_cache[0], cache[past_row_4][16]};
        end
        else if (curr_state == LOOP_5) begin
            temp_cache[0] <= temp_cache[1];
            temp_cache[1] <= temp_cache[2];
            temp_cache[2] <= data_from_mem;
            
            if (curr_column < COLUMN + MEM_UNIT - 1)
                mem_write <= 1'd1;
                
            cache[past_row_4] <= {temp_cache[0], cache[past_row_4][16]};
        end
    end
    
endmodule
