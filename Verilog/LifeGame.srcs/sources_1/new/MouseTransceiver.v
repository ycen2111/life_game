`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering
// 
// Create Date: 16.02.2023 15:53:52
// Design Name: DR ALISTER HAMILTON & Yang Cen
// Module Name: MouseTransceiver
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description: Main mouse block.combines mouse receiver, transmitter, and staeMaster together, and count the exactly position
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MouseTransceiver(
    //output [3:0] M_state_check,
    //output [3:0] T_state_check,
    //output [2:0] R_state_check,,

    //Standard Inputs
    input RESET,
    input CLK,
    //IO - Mouse side
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    // Mouse data information
    output reg [3:0] MouseStatus,
    output reg [11:0] MouseX,
    output reg [11:0] MouseY
);

    // X, Y Limits of Mouse Position e.g. VGA Screen with 160 x 120 resolution
    parameter [11:0] MouseLimitX = 640;
    parameter [11:0] MouseLimitY = 480;
    
    wire [3:0] M_state_check, T_state_check, R_state_check;
    
    /////////////////////////////////////////////////////////////////////
    //TriState Signals
    //Clk
    reg ClkMouseIn;
    wire ClkMouseOutEnTrans;
    //Data
    wire DataMouseIn;
    wire DataMouseOutTrans;
    wire DataMouseOutEnTrans;
    
    //Clk Output - can be driven by host or device
    assign CLK_MOUSE = ClkMouseOutEnTrans ? 1'b0 : 1'bz;
    //Clk Input
    assign DataMouseIn = DATA_MOUSE;
    //Clk Output - can be driven by host or device
    assign DATA_MOUSE = DataMouseOutEnTrans ? DataMouseOutTrans : 1'bz;
    
    /////////////////////////////////////////////////////////////////////
    //This section filters the incoming Mouse clock to make sure that
    //it is stable before data is latched by either transmitter
    //or receiver modules
    reg [7:0] MouseClkFilter;
    
    always@(posedge CLK) begin
        if(RESET)
            ClkMouseIn <= 1'b0;
        else 
        begin
            //A simple shift register
            MouseClkFilter[7:1] <= MouseClkFilter[6:0];
            MouseClkFilter[0] <= CLK_MOUSE;
            
            //falling edge
            if(ClkMouseIn & (MouseClkFilter == 8'h00))
                ClkMouseIn <= 1'b0;
            //rising edge
            else if(~ClkMouseIn & (MouseClkFilter == 8'hFF))
                ClkMouseIn <= 1'b1;
        end
    end
    
    ///////////////////////////////////////////////////////
    //Instantiate the Transmitter module
    wire SendByteToMouse;
    wire ByteSentToMouse;
    wire [7:0] ByteToSendToMouse;
    
    MouseTransmitter T(
    .state_check(T_state_check),
    
    //Standard Inputs
    .RESET (RESET),
    .CLK(CLK),
    //Mouse IO - CLK
    .CLK_MOUSE_IN(ClkMouseIn),
    .CLK_MOUSE_OUT_EN(ClkMouseOutEnTrans),
    //Mouse IO - DATA
    .DATA_MOUSE_IN(DataMouseIn),
    .DATA_MOUSE_OUT(DataMouseOutTrans),
    .DATA_MOUSE_OUT_EN (DataMouseOutEnTrans),
    //Control
    .SEND_BYTE(SendByteToMouse),
    .BYTE_TO_SEND(ByteToSendToMouse),
    .BYTE_SENT(ByteSentToMouse)
    );
    
    ///////////////////////////////////////////////////////
    //Instantiate the Receiver module
    wire ReadEnable;
    wire [7:0] ByteRead;
    wire [1:0] ByteErrorCode;
    wire ByteReady;
    
    MouseReceiver R(
    .state_check(R_state_check),
    
    //Standard Inputs
    .RESET(RESET),
    .CLK(CLK),
    //Mouse IO - CLK
    .CLK_MOUSE_IN(ClkMouseIn),
    //Mouse IO - DATA
    .DATA_MOUSE_IN(DataMouseIn),
    //Control
    .READ_ENABLE (ReadEnable),
    .BYTE_READ(ByteRead),
    .BYTE_ERROR_CODE(ByteErrorCode),
    .BYTE_READY(ByteReady)
    );
    
    ///////////////////////////////////////////////////////
    //Instantiate the Master State Machine module
    wire [7:0] MouseStatusRaw;
    wire [7:0] MouseDxRaw;
    wire [7:0] MouseDyRaw;
    wire SendInterrupt;
    
    MouseMasterSM MSM(
    .state_check(M_state_check),
    
    //Standard Inputs
    .RESET(RESET),
    .CLK(CLK),
    //Transmitter Interface
    .SEND_BYTE(SendByteToMouse),
    .BYTE_TO_SEND(ByteToSendToMouse),
    .BYTE_SENT(ByteSentToMouse),
    //Receiver Interface
    .READ_ENABLE (ReadEnable),
    .BYTE_READ(ByteRead),
    .BYTE_ERROR_CODE(ByteErrorCode),
    .BYTE_READY(ByteReady),
    //Data Registers
    .MOUSE_STATUS(MouseStatusRaw),
    .MOUSE_DX(MouseDxRaw),
    .MOUSE_DY(MouseDyRaw),
    .SEND_INTERRUPT(SendInterrupt)
    );
    
    //Pre-processing - handling of ovSearch commandserflow and signs.
    //More importantly, this keeps tabs on the actual X/Y
    //location of the mouse.
    wire signed [12:0] MouseDx;
    wire signed [12:0] MouseDy;
    wire signed [12:0] MouseNewX;
    wire signed [12:0] MouseNewY;
    
    //DX and DY are modified to take account of overflow and direction
    assign MouseDx = (MouseStatusRaw[6]) ? (MouseStatusRaw[4] ? {MouseStatusRaw[4],12'h00} :{MouseStatusRaw[4],12'hFF} ) : {{5{MouseStatusRaw[4]}},MouseDxRaw[7:0]};
    
    // assign the proper expression to MouseDy
/*        ....................
        FILL IN THIS AREA
        ...................*/
    assign MouseDy = (MouseStatusRaw[7]) ? (MouseStatusRaw[5] ? {MouseStatusRaw[5],12'h00} :{MouseStatusRaw[5],12'hFF} ) : {{5{MouseStatusRaw[5]}},MouseDyRaw[7:0]};
        
    // calculate new mouse position
    assign MouseNewX = {1'b0,MouseX} + MouseDx;
    assign MouseNewY = {1'b0,MouseY} - MouseDy;
    
    //Broadcast the Interrupt
    reg Interrupt;
    
    always@(posedge CLK) begin
        if(RESET) begin
            MouseStatus <= 0;
            MouseX <= MouseLimitX/2;
            MouseY <= MouseLimitY/2;
            Interrupt <= 0;
        end 
        else if (SendInterrupt) begin
            //Status is stripped of all unnecessary info
            MouseStatus <= MouseStatusRaw[3:0];
            Interrupt <= 1;
            
            //X is modified based on DX with limits on max and min
            if(MouseNewX < 0)
                MouseX <= 0;
            else if(MouseNewX > (MouseLimitX-1))
                MouseX <= MouseLimitX-1;
            else
                MouseX <= MouseNewX[11:0];
            //Y is modified based on DY with limits on max and min
            /*....................
            FILL IN THIS AREA
            ...................*/
            if(MouseNewY < 0) //check it later
                MouseY <= 0;
            else if(MouseNewY > (MouseLimitY-1))
                MouseY <= MouseLimitY-1;
            else
                MouseY <= MouseNewY[11:0];
        end
        else
            Interrupt <= 0;
    end
    
endmodule
