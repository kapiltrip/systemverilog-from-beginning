// Code your design here
module priorityEncoder(
  input [3:0] x,
  output reg [1:0] y
);
  always_comb begin
    casez(x)
      4'b0001: y =  2'b00  ;
      4'b001? : y= 2'b01 ;
      4'b01?? : y= 2'b10 ;
      4'b1??? : y= 2'b11 ;
      default:  y= 2'bzz;
    endcase

  end
endmodule
