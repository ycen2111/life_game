`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2023 11:13:22
// Design Name: 
// Module Name: VGA_buffer
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


module VGA_buffer(
    // Port A - Read/Write
    input A_CLK,
    input [18:0] A_ADDR, // 640*480 = 2 ** 18.23
    input A_DATA_IN, // Pixel Data In
    output reg A_DATA_OUT,
    input A_WE, // Write Enable
    //Port B - Read Only
    input B_CLK,
    input [18:0] B_ADDR, // Pixel Data Out
    output reg B_DATA
    );
    
    // A 640 x 480 (512) 1-bit memory to hold frame data
    //The LSBs of the address correspond to the X axis, and the MSBs to the Y axis
    reg [0:0] Mem [1024 * 512 - 1 : 0];
    
    // Load initial pattern
    initial $readmemb("VGA_buffer.txt", Mem);
    
    // Port A - Read/Write e.g. to be used by microprocessor
    always@(posedge A_CLK) begin
        if(A_WE)
            Mem[A_ADDR] <= A_DATA_IN;
        A_DATA_OUT <= Mem[A_ADDR];
    end
    
    // Port B - Read Only e.g. to be read from the VGA signal generator module for display
    always@(posedge B_CLK) begin
        B_DATA <= Mem[B_ADDR];
    end
    
endmodule
