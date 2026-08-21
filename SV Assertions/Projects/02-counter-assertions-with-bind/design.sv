// Code your design here
module counter(
  input wire clk , rst, up,
  output reg [3:0] dout 
);

  always @(posedge clk )begin
    if(rst)begin
      dout<= 4'b0000;
      
    end else begin
      if(up)
        dout <= dout + 4'd1; 
      else 
        dout <= dout - 4'd1; 
      
    end 
  end
endmodule
