`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2023 11:31:45
// Design Name: 
// Module Name: VGA_manager
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


module VGA_reader(
    //Standard Signal
    input CLK,
    input RESET,
    // Frame Buffer (Dual Port memory) Interface
    output [18:0] VGA_ADDR,
    input VGA_DATA,
    //VGA Port Interface
    output reg VGA_HS,
    output reg VGA_VS,
    output [11:0] VGA_COLOUR,
    //output finish sign
    output read_finish
    );
    //The original clock is 100MHz, so must halve the clock in top module
    //Halve the clock to 25MHz to drive the VGA display
    reg VGA_CLK;
    reg VGA_counter;
    always@(posedge CLK) begin
        if(RESET) begin
            VGA_CLK <= 0;
            VGA_counter <= 0;
        end
        else begin
            if (VGA_counter == 1)
                VGA_CLK <= ~VGA_CLK; 
            VGA_counter <= ~VGA_counter;
        end
    end
/*
Define VGA signal parameters e.g. Horizontal and Vertical display time, pulse widths, front and back 
porch widths etc. 
*/
    // Use the following signal parameters
    parameter HTs = 800; // Total Horizontal Sync Pulse Time
    parameter HTpw = 96; // Horizontal Pulse Width Time 
    parameter HTDisp = 640; // Horizontal Display Time
    parameter Hbp = 48; // Horizontal Back Porch Time
    parameter Hfp = 16; // Horizontal Front Porch Time
    parameter VTs = 521; // Total Vertical Sync Pulse Time
    parameter VTpw = 2; // Vertical Pulse Width Time
    parameter VTDisp = 480; // Vertical Display Time
    parameter Vbp = 29; // Vertical Back Porch Time
    parameter Vfp = 10; // Vertical Front Porch Time
//    ������������..
//    FILL IN THIS AREA
//    ������������.
    // Define Horizontal and Vertical Counters to generate the VGA signals
    reg [9:0] HCounter;
    reg [9:0] VCounter;
    
    //Define the counter that cover the full signal process
    reg [9:0] HSCounter;
    reg [9:0] VSCounter;
    
    //Define the enable signal to let the pixel data be transmitted only in display time
    wire  VGA_OUTPUT_EN;
    
    initial begin
        VGA_CLK=0;
        HSCounter=0;
        VSCounter=0;
        
    end
/*
Create a process that assigns the proper horizontal and vertical counter values for raster scan of the 
display. 
*/
    //Generate the horizontal counter
    always @(posedge VGA_CLK or posedge RESET) begin
        if(RESET) begin
            HSCounter <= 10'b0;
        end
        else begin
            if(HSCounter < HTs - 1'b1) begin
                HSCounter <= HSCounter + 1'b1;
            end
            else begin
                HSCounter <= 10'b0;
            end
        end
    end
    
    //Generate the vertical counter according to the horizontal counter
    always @(posedge VGA_CLK or posedge RESET) begin
        if(RESET) begin
            VSCounter <= 10'b0;
        end
        else if(HSCounter == HTs - 1'b1) begin
            if(VSCounter < VTs - 1'b1) begin
                VSCounter <= VSCounter + 1'b1;
            end
            else begin
                VSCounter <= 10'b0;
            end
        end
    end
 
/*
Need to create the address of the next pixel. Concatenate and tie the look ahead address to the frame 
buffer address.
*/
    assign VGA_ADDR = {VCounter, HCounter};
    //assign VGA_ADDR = {HCounter, VCounter[8:0]};
/*
Create a process that generates the horizontal and vertical synchronisation signals, as well as the pixel 
colour information, using HCounter and VCounter. Do not forget to use CONFIG_COLOURS input to 
display the right foreground and background colours.
*/
    //Horizontal and vertical synchronisation signals

    //HCounter and VCounter will hold the address 
    always @ (HSCounter or VSCounter) begin
        HCounter = (HSCounter - (HTpw + Hbp));
        VCounter = (VSCounter - (VTpw + Vbp));
        VGA_HS = (HSCounter<HTpw)? 1'b0 : 1'b1;
        VGA_VS = (VSCounter<VTpw)? 1'b0 : 1'b1;
    end
    
    
    //Enable output signal
    assign VGA_OUTPUT_EN = (((HSCounter >= HTpw + Hbp) && (HSCounter <  HTpw + Hbp + HTDisp))
                            &&((VSCounter >= VTpw + Vbp) && (VSCounter < VTpw + Vbp + VTDisp)))   
                            ? 1'b1 : 1'b0;
                            
    assign read_finish = (VSCounter >= VTpw + Vbp + VTDisp) || (VSCounter < VTpw + Vbp);
    
/*
Finally, tie the output of the frame buffer to the colour output VGA_COLOUR. 
*/
    //Output pixel colour sinal, 8'h00 (zero) whilst not during the display time, i.e.,VGA_OUTPUT_EN == 0
    assign VGA_COLOUR = (VGA_OUTPUT_EN && VGA_DATA) ? 12'hFFF : 12'h000;
endmodule
