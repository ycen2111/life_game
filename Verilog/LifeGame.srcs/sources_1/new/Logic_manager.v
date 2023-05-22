`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.05.2023 08:18:20
// Design Name: 
// Module Name: Logic_manager
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: FSM structure control the pipline initialize, neighbors finding, and cell manage
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Logic_manager#(
    parameter MAX_ROW_BITS = 5, //512
    parameter MAX_COLUMN_BITS = 5 //512
    )(
    input CLK,
    input RESET,
    input enter, //input new point
    input [MAX_ROW_BITS - 1 : 0] row_size, //matrix row
    input [MAX_COLUMN_BITS - 1 : 0] column_size, //matrix column
    input [MAX_ROW_BITS - 1 : 0] row_in, //start at 1
    input [MAX_COLUMN_BITS - 1 : 0] column_in, //start at 1
    output [2**MAX_ROW_BITS * 2**MAX_COLUMN_BITS - 1 : 0] temp,
    output reg [2**MAX_ROW_BITS * 2**MAX_COLUMN_BITS - 1 : 0] curr_cell
    );
    
    parameter ROW_UNIT_BITS = 2; //16
    parameter COLUMN_UNIT_BITS = 2; //16
    parameter ROW_UNIT = 2**ROW_UNIT_BITS;
    parameter COLUMN_UNIT = 2**COLUMN_UNIT_BITS;
    parameter MAX_ROW = 2**MAX_ROW_BITS;
    parameter MAX_COLUMN = 2**MAX_COLUMN_BITS;
    
    //reg [MAX_ROW * MAX_COLUMN - 1 : 0] curr_cell;
    reg [MAX_ROW * MAX_COLUMN - 1 : 0] curr_temp_cell;
    reg [MAX_ROW_BITS - 1 :0] curr_row, next_row;
    reg [MAX_COLUMN_BITS - 1 :0] curr_column, next_column;
    reg [MAX_ROW_BITS + MAX_COLUMN_BITS - 1 : 0] last_cell_num_1, last_cell_num_2;
    reg [2 - 1 : 0] curr_recording_mark, next_recording_mark;
    
    reg [2:0] curr_state, next_state;
    parameter   IDLE = 3'd0,
                ENTER = 3'd1,
                OVERWRITE = 3'd2,
                RUNNING = 3'd3,
                RUNNING_1 = 3'd4,
                FINISH = 3'd5;
    
    //for find-neighbors
    wire [(ROW_UNIT + 2) * (COLUMN_UNIT + 2) - 1 : 0] cell_in;
    wire [ROW_UNIT * COLUMN_UNIT - 1 : 0] cell_out;
    //cell location marking
    wire [MAX_ROW_BITS + MAX_COLUMN_BITS - 1 : 0] cell_num;
    wire [MAX_ROW_BITS - 1 : 0] ROW;
    wire [MAX_COLUMN_BITS - 1 : 0] COLUMN;
    
    //find cell_id by row and column number
    assign cell_num = enter ? {row_in, column_in} : {curr_row, curr_column};
    assign temp = cell_num;
    //let row and column board equal or bigger than pipline unit
    assign ROW = (row_size < ROW_UNIT) ? ROW_UNIT : row_size;
    assign COLUMN = (column_size < COLUMN_UNIT) ? COLUMN_UNIT : column_size;
    
    //input (N+2)(N+2) matrix, output N*N next-turn matrix after 2 cycles
    Find_neighbors find_neighbors(
        .CLK(CLK),
        .RESET(RESET),
        .cell_in(cell_in),
        .cell_out(cell_out)
    );
    
    //update variable
    always @(posedge CLK) begin
        if (RESET) begin
            curr_state <= IDLE;
            curr_row <= 0;
            curr_column <= 0;
            last_cell_num_1 <= 0;
            last_cell_num_2 <= 0;
            curr_recording_mark <= 0;
        end
        else begin
            curr_state <= next_state;
            curr_row <= next_row;
            curr_column <= next_column;
            last_cell_num_1 <= cell_num;
            last_cell_num_2 <= last_cell_num_1;
            curr_recording_mark <= next_recording_mark;
        end
    end
    
    //FSM block.
    always @(*) begin
        next_state = curr_state;
        next_row = curr_row;
        next_column = curr_column;
        //shift left cycle timer with 1
        //if the most left number of this variable is 1, means pipline is still working
        //otherwise, the pipline is finished
        next_recording_mark = curr_recording_mark << 1;
        
        case (curr_state)
            //init cell, waiting for start
            //IDLE will be appear after RESET signal
            IDLE: begin
                curr_cell = 0;
                curr_temp_cell = 0;
                next_state = ENTER;
            end
            
            //enter signal is on. set next_cell [row_in][column_in] be 1
            //move to RUNNING when enter is low
            ENTER: begin
                if (enter) begin
                    if (row_in != 0 && column_in != 0) begin
                        curr_cell [cell_num] = 1;
                    end
                end
                else
                    next_state = RUNNING;
                
            end
            
            //overwrite data in temp_cell to the cell
            OVERWRITE: begin
                curr_cell = curr_temp_cell;
                next_state = RUNNING;
            end
            
            //start find_neighbors pipline
            //recording_mark shows the process of pipline
            //if LSB equals 0, pipline finished
            //if LSB equals 1, pipline is working
            //the recording_mark will shift left with 1 bit and set RSB with 1 if a new group of data is passed inside.
            //row and column mark the left-top conor of inputted cell_in data.
            RUNNING: begin
                next_recording_mark = next_recording_mark | 2'b1;
            
                if (curr_column + COLUMN_UNIT == COLUMN) begin
                    next_column = 0;
                    if (curr_row + ROW_UNIT == ROW) begin
                        next_row = 0;
                        next_state = RUNNING_1;
                    end
                    else if (curr_row + ROW_UNIT + ROW_UNIT < ROW)
                        next_row = curr_row + ROW_UNIT;
                    else
                        next_row = ROW - ROW_UNIT;
                end
                else if (curr_column + COLUMN_UNIT + COLUMN_UNIT < COLUMN)
                    next_column = curr_column + COLUMN_UNIT;
                else
                    next_column = COLUMN - COLUMN_UNIT;
            end
            
            //waiting for last cell_out recordng
            RUNNING_1: begin
                next_state = FINISH;
            end
            
            //back to next loop
            FINISH: begin
                next_state = OVERWRITE;
            end
            
        endcase
    end
    
    //pipline is finished if curr_recording_mark[1] equals 0
    assign in_recording = curr_recording_mark[1];
    
    always @(*) begin
        if (in_recording) begin
            curr_temp_cell[last_cell_num_2 + (1 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(0 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (2 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(1 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (3 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(2 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (4 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(3 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            /*curr_temp_cell[last_cell_num_2 + (5 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(4 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (6 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(5 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (7 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(6 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (8 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(7 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (9 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(8 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (10 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(9 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (11 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(10 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (12 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(11 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (13 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(12 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (14 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(13 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (15 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(14 << ROW_UNIT_BITS) +: COLUMN_UNIT];
            curr_temp_cell[last_cell_num_2 + (16 << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(15 << ROW_UNIT_BITS) +: COLUMN_UNIT];*/
        end
    end

    genvar i;
    
    generate
        //recombinite cell_in (from 2-D to 1-D array)
        for (i = 0; i < ROW_UNIT + 2; i = i + 1) begin : translate_cells_in
            assign cell_in[i * (COLUMN_UNIT + 2) +: COLUMN_UNIT + 2] = (RESET || enter) ? 0 : curr_cell[cell_num + (i << MAX_COLUMN_BITS) +: COLUMN_UNIT + 2];
        end
        
        //recombinate cell_out (from 1-D to 2-D array)
        /*for (i = 0; i < ROW_UNIT; i = i + 1) begin : translate_cells_out
            always @(*) begin
                if (in_recording) begin
                    next_temp_cell[last_cell_num_2 + ((i+1) << MAX_COLUMN_BITS) + 1 +: COLUMN_UNIT] = cell_out[(i << ROW_UNIT_BITS) +: COLUMN_UNIT];
                end
            end
        end*/
    endgenerate
    
endmodule
