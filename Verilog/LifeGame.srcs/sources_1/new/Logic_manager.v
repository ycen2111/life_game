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


module Logic_manager(
    input CLK,
    input RESET,
    input enter, //input new point
    input [9 : 0] ROW, //matrix row
    input [9 : 0] COLUMN, //matrix column
    input [9 : 0] row_in, //start at 1
    input [9 : 0] column_in, //start at 1
    output [8 : 0] test
    );
    
    parameter ROW_UNIT = 16;
    parameter COLUMN_UNIT = 16;
    parameter MAX_ROW = 100 + 2;
    parameter MAX_COLUMN = 100 + 2;
    
    reg [MAX_COLUMN : 0] curr_cell [0 : MAX_ROW];
    reg [MAX_COLUMN : 0] next_cell [0 : MAX_ROW];
    reg [9:0] curr_row, next_row, last_row_1, last_row_2;
    reg [9:0] curr_column, next_column, last_column_1, last_column_2;
    reg [2:0] curr_running_state, next_running_state;
    reg curr_in_recording, next_in_recording;
    
    reg [3:0] curr_state, next_state;
    parameter   IDLE = 'd00,
                ENTER = 'd01,
                OVERWRITE = 'd02,
                RUNNING_1 = 'd03,
                RUNNING_2 = 'd04;
    
    //for find-neighbors
    wire [(ROW_UNIT + 2) * (COLUMN_UNIT + 2) - 1 : 0] cell_in;
    wire [ROW_UNIT * COLUMN_UNIT - 1 : 0] cell_out;
    
    assign test = {curr_cell[1][1+:3],curr_cell[2][1+:3],curr_cell[3][1+:3]};
    
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
            last_row_1 <= 0;
            last_row_2 <= 0;
            last_column_1 <= 0;
            last_column_2 <= 0;
            curr_running_state <= 0;
            curr_in_recording <= 0;
        end
        else begin
            curr_state <= next_state;
            curr_row <= next_row;
            curr_column <= next_column;
            last_row_1 <= curr_row;
            last_row_2 <= last_row_1;
            last_column_1 <= curr_column;
            last_column_2 <= last_column_1;
            curr_running_state <= next_running_state;
            curr_in_recording <= next_in_recording;
        end
    end
    
    //FSM block.
    always @(*) begin
        next_state = curr_state;
        next_row = curr_row;
        next_column = curr_column;
        next_running_state = curr_running_state;
        next_in_recording = curr_in_recording;
        
        case (curr_state)
            //init case, reset all elements in next_cell be 0.
            //IDLE will be appear after RESET signal
            IDLE: begin
                if (curr_row < ROW + 2) begin
                    next_cell[curr_row] = 0;
                    next_row = curr_row + 1;
                end
                else begin
                    if (enter)
                        next_state = ENTER;
                    else
                        next_state = OVERWRITE;
                    next_row = 0;
                end
            end
            
            //enter signal is on. set next_cell [row_in][column_in] be 1
            //move to OVERWRITE when enter is low
            ENTER: begin
                if (enter) begin
                    if (row_in != 0 && column_in != 0) begin
                        next_cell [row_in][column_in] = 1;
                    end
                end
                else
                    next_state = OVERWRITE;
            end
            
            //overwrite data in next_cell to curr_cell
            OVERWRITE: begin
                if (curr_row < ROW + 2) begin
                    curr_cell[curr_row] = next_cell[curr_row];
                    next_row = curr_row + 1;
                end
                else begin
                    next_state = RUNNING_1;
                    next_row = 0;
                end
            end
            
            //start find_neighbors pipline
            //running_state marks this pipline
            //if running_state=0 or 1, find_neighbors is within first 2 cycles of pipline, hence no cell_out will be received at these time
            //if running_state = 2, find_neighbors has both cell_in input and cell_out output
            //if running_state > 2, move to next state
            //row and column mark the left-top conor of inputted cell_in data.
            RUNNING_1: begin
                if (curr_column + COLUMN_UNIT == COLUMN) begin
                    next_column = 0;
                    if (curr_row + ROW_UNIT == ROW) begin
                        next_row = 0;
                        next_running_state = 2;
                        next_state = RUNNING_2;
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
                    
                if (curr_running_state < 2)
                    next_running_state = curr_running_state + 1;
                else
                    next_in_recording = 1;
            end
            
            //running_state = 3 or 4, all data has been inputted and is waiting for receiving last two piplined cell_out
            //move to OVERWRITE and ready for next loop
            RUNNING_2: begin
                if (curr_running_state < 5)
                    next_running_state = curr_running_state + 1;
                else begin
                    next_running_state = 0;
                    next_in_recording = 0;
                    next_state = OVERWRITE;
                end
            end
            
            
        endcase
    end

    genvar i;
    
    generate
        //recombinite cell_in (from 2-D to 1-D array)
        for (i = 0; i < ROW_UNIT + 2; i = i + 1) begin : translate_cells_in
            assign cell_in[i * (COLUMN_UNIT + 2) +: COLUMN_UNIT + 2] = (RESET || enter) ? 0 : curr_cell[curr_row + i][curr_column +: COLUMN_UNIT + 2];
        end
        
        //recombinate cell_out (from 1-D to 2-D array)
        for (i = 0; i < ROW_UNIT; i = i + 1) begin : translate_cells_out
            always @(*) begin
                if (next_in_recording) begin
                    next_cell[last_row_2 + i + 1][last_column_2 + 1 +: COLUMN_UNIT] = /*cell_out[i * COLUMN_UNIT +: COLUMN_UNIT]*/1;
                end
            end
        end
    endgenerate
    
endmodule
