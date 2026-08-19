// Code your testbench here
// or browse Examples
module tb;
  //reg [3:0] a ; 
  reg a ; 
  reg clk =0 ; 
  always #5 clk = ~clk ; 
  initial begin
    for(int i =0; i<10;i++)begin
      a = $urandom_range(0,1);
      #10;
    end
  end
  always @(posedge clk)begin
    $info("value of a is %0b and $fell(a) is " , a, $fell(a));
    //$info("Value of a is %0b preponed region and a's value in reactive region is %0b  rose a is : %0b " , $sampled(a) ,a , $rose(a)); // 
  end
  
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars; 
      $assertvacuousoff(0); // to filter vacuous success
      //repeat (20) @(posedge clk) ; 
      #120;
      $finish();
    end
endmodule
