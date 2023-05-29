`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering
// 
// Create Date: 16.02.2023 15:37:38
// Design Name: DR ALISTER HAMILTON & Yang Cen
// Module Name: MouseTransmitter
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description: output a 8 bits value to mouse using IIC format
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MouseTransmitter(
    output [3:0] state_check,

    //Standard Inputs
    input RESET,
    input CLK,
    //Mouse IO - CLK
    input CLK_MOUSE_IN,
    output CLK_MOUSE_OUT_EN, // Allows for the control of the Clock line
    //Mouse IO - DATA
    input DATA_MOUSE_IN,
    output DATA_MOUSE_OUT,
    output DATA_MOUSE_OUT_EN,
    //Control
    input SEND_BYTE,
    input [7:0] BYTE_TO_SEND,
    output BYTE_SENT
);

    assign state_check=Curr_State;

    //////////////////////////////////////////////////////////
    // Clk Mouse delayed to detect clock edges
    
    reg ClkMouseInDly;
    
    always@(posedge CLK)
        ClkMouseInDly <= CLK_MOUSE_IN;
    
    //////////////////////////////////////////////////////////
    //Now a state machine to control the flow of write data
    
    reg [3:0] Curr_State, Next_State;
    reg Curr_MouseClkOutWE, Next_MouseClkOutWE;
    reg Curr_MouseDataOut, Next_MouseDataOut;
    reg Curr_MouseDataOutWE, Next_MouseDataOutWE;
    reg [15:0] Curr_SendCounter, Next_SendCounter;
    reg Curr_ByteSent, Next_ByteSent;
    reg [7:0] Curr_ByteToSend, Next_ByteToSend;
    
    //Sequential
    always@(posedge CLK) begin
        if(RESET) begin
            Curr_State <= 4'h0;
            Curr_MouseClkOutWE <= 1'b0;
            Curr_MouseDataOut <= 1'b0;
            Curr_MouseDataOutWE <= 1'b0;
            Curr_SendCounter <= 0;
            Curr_ByteSent <= 1'b0;
            Curr_ByteToSend <= 0;
        end 
        else begin
            Curr_State <= Next_State;
            Curr_MouseClkOutWE <= Next_MouseClkOutWE;
            Curr_MouseDataOut <= Next_MouseDataOut;
            Curr_MouseDataOutWE <= Next_MouseDataOutWE;
            Curr_SendCounter <= Next_SendCounter;
            Curr_ByteSent <= Next_ByteSent;
            Curr_ByteToSend <= Next_ByteToSend;
        end
    end
    
    //Combinatorial
    always @(*) begin
    //default values
        Next_State = Curr_State;
        Next_MouseClkOutWE = 1'b0;
        Next_MouseDataOut = 1'b0;
        Next_MouseDataOutWE = Curr_MouseDataOutWE;
        Next_SendCounter = Curr_SendCounter;
        Next_ByteSent = 1'b0;
        Next_ByteToSend = Curr_ByteToSend;
        
        case(Curr_State)
            //IDLE
            4'h0 : begin
                if(SEND_BYTE) begin
                        Next_State = 4'h1;
                        Next_ByteToSend = BYTE_TO_SEND;
                    end
                Next_MouseDataOutWE = 1'b0;
                end
                
            //Bring Clock line low for at least 100 microsecs i.e. 10000 clock cycles @ 100MHz
            4'h1 : begin
                if(Curr_SendCounter == 12000) begin //120ms
                    Next_State = 4'h2;
                    Next_SendCounter = 0;
                end 
                else
                    Next_SendCounter = Curr_SendCounter + 1'b1;
                Next_MouseClkOutWE = 1'b1;
            end
            
            //Bring the Data Line Low and release the Clock line
            4'h2 : begin
                Next_State = 4'h3;
                Next_MouseDataOutWE = 1'b1;
            end
            
            //Start Sending
            4'h3 : begin // change data at falling edge of clock, start bit = 0
                if(ClkMouseInDly & ~CLK_MOUSE_IN)
                    Next_State = 4'h4;
            end
            
            //Send Bits 0 to 7 - We need to send the byte
            4'h4 : begin // change data at falling edge of clock
                if(ClkMouseInDly & ~CLK_MOUSE_IN) begin
                    if(Curr_SendCounter == 7) begin
                        Next_State = 4'h5;
                        Next_SendCounter = 0;
                    end 
                    else
                        Next_SendCounter = Curr_SendCounter + 1'b1;
                end
                Next_MouseDataOut = Curr_ByteToSend[Curr_SendCounter];
            end
            
            //Send the parity bit
            4'h5 : begin // change data at falling edge of clock
                if(ClkMouseInDly & ~CLK_MOUSE_IN)
                    Next_State = 4'h6;
                Next_MouseDataOut = ~^Curr_ByteToSend[7:0];
            end
            
            //Release Data line
            4'h6 : begin
                Next_State = 4'h7;
                Next_MouseDataOutWE = 1'b0;
            end
            
            /*
            Wait for Device to bring Data line low, then wait for Device to bring Clock line low, and finally wait for
            Device to release both Data and Clock.
            */
            /*....................
            FILL IN THIS AREA
            ...................*/
            //Wait for Device to bring Data line low
            4'h7: begin
                if(~DATA_MOUSE_IN)
                    Next_State = 4'h8;
            end
            
            //ait for Device to bring Clock line low
            4'h8: begin
                if(~CLK_MOUSE_IN)
                    Next_State = 4'h9;
            end
            
            //wait for Device to release both Data and Clock (Both clk and data equals 1(or z, not sure about it))
            4'h9: begin
                if(DATA_MOUSE_IN & CLK_MOUSE_IN) begin
                    Next_State = 4'h0;
                    Next_ByteSent = 1'b1; //? not sure
                end
            end
            
            //default
            default: begin
                Next_State = 4'h0;
                Next_MouseClkOutWE = 1'b0;
                Next_MouseDataOut = 1'b0;
                Next_MouseDataOutWE = 1'b0;
                Next_SendCounter = 0;
                Next_ByteSent = 1'b0;
                Next_ByteToSend = 0;
            end
        endcase
    end
    
    ///////////////////////////////////////////////////////////////
    //Assign OUTPUTs
    //Mouse IO - CLK
    assign CLK_MOUSE_OUT_EN = Curr_MouseClkOutWE;
    //Mouse IO - DATA
    assign DATA_MOUSE_OUT = Curr_MouseDataOut;
    assign DATA_MOUSE_OUT_EN = Curr_MouseDataOutWE;
    //Control
    assign BYTE_SENT = Curr_ByteSent;
    
endmodule