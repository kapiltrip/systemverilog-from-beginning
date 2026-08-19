// Code your design here
module mux(
  input a,b,c,d,
  input [1:0] sel , 
  output reg y // to be used in procedural block 
);
  always @(*) begin
    case (sel)
      2'b00: y=a; 
      2'b01: y=b; 
      2'b10: y=c; 
      2'b11: y=d; 
      
    endcase
  end
  always @(*)begin
    case (sel)
      2'b00 : y_equals_a :assert (y==a) else $error("Y is not equals to a at time %0t" , $time) ; 
      2'b01 : y_equals_b :assert (y==b) else $error("Y is not equals to b at time %0t" , $time) ; 
      2'b10 : y_equals_c :assert (y==c) else $error("Y is not equals to c at time %0t" , $time) ; 
      2'b11 : y_equals_d :assert (y==d) else $error("Y is not equals to d at time %0t" , $time) ; 
      
    endcase
  end
endmodule
