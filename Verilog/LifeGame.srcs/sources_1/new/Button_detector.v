`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2023 14:17:55
// Design Name: 
// Module Name: Button_detector
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


module Button_detector(
    input CLK,
    input RESET,
    //button signal input
    input [4:0] button_in,
    //detect button releasing
    output up_releasing,
    output down_releasing,
    output left_releasing,
    output right_releasing,
    output center_releasing
    );
    
    reg [1:0] up_record, down_record, left_record, right_record, center_record;
    
    always @(posedge CLK) begin
        if (RESET) begin
            up_record <= 0;
            down_record <= 0;
            left_record <= 0;
            right_record <= 0;
            center_record <= 0;
        end
        else begin
            up_record <= {up_record[0], button_in[0]};
            down_record <= {down_record[0], button_in[1]};
            left_record <= {left_record[0], button_in[2]};
            right_record <= {right_record[0], button_in[3]};
            center_record <= {center_record[0], button_in[4]};
        end
    end
    
    assign up_releasing = (up_record == 2'b10);
    assign down_releasing = (down_record == 2'b10);
    assign left_releasing = (left_record == 2'b10);
    assign right_releasing = (right_record == 2'b10);
    assign center_releasing = (center_record == 2'b10);
        
endmodule
