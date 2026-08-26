`timescale 1ns/1ps

// Video 142: loadable 4-bit up-counter DUT.
module counter (
  input wire clk, rst , up , load ,
  input wire [7:0] loadIn ,
  input wire [7:0] x ,
  output reg [7:0] y
);
  always @(posedge clk)begin
    if(rst)
      y<= 8'd0 ;
    else begin
      if(load) begin
        y<= loadIn ;
      end
      else if(up )
        y<= y+1 ;
      else
        y<= y-1 ;

    end

  end
endmodule
interface counter_if();
  logic clk , rst , up , load ;
  logic [7:0] loadIn ;
  logic [7:0] y ;
endinterface
