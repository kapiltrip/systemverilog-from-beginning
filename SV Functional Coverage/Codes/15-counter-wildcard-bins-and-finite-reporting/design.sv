// Code your design here
module counter(
  input clk , en ,
  output reg [3:0] y
);

  always_ff @(posedge clk ) begin
    if(!en)begin
      y<= 4'd0;
    end else
      y<= y+ 4'd1;

  end
endmodule
