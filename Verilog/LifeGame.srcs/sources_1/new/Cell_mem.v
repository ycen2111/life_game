`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2023 22:01:29
// Design Name: 
// Module Name: Cell_mem
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


module Cell_mem#(
    parameter MAX_ROW_BITS = 9, //512
    parameter MAX_COLUMN_BITS = 9 //512
    )(
    input CLK,
    input RESET,
    input W_enable,
    input [2 ** (MAX_ROW_BITS + MAX_COLUMN_BITS - 4) - 1 : 0] data_in_add,
    input [15 : 0] data_in,
    input [2 ** (MAX_ROW_BITS + MAX_COLUMN_BITS - 4) - 1 : 0] data_out_add,
    output reg [15 : 0] data_out
    );
    
    reg [15:0] Mem [2 ** (MAX_ROW_BITS + MAX_COLUMN_BITS - 4) - 1 : 0];

    //initial $readmemh("Mem.txt", Mem);

    //write data into memory
    always @(posedge CLK) begin
        if (RESET)
            $readmemh("Mem.txt", Mem);
        else begin
            if (W_enable)
                Mem[data_in_add] <= data_in;
            else
                Mem[data_in_add] <= Mem[data_in_add];
        end
    end
    
    //read data out of memory
    always @(posedge CLK) begin
        if (RESET)
            data_out <= 0;
        else
            data_out <= Mem[data_out_add];
    end
    
endmodule
