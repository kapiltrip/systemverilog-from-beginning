// Code your testbench here
// or browse Examples
//repetition operator 
// consecutive and non consecutive 
//we know the exact count for which we know to keepa signal high
/*
a1: assert property (@(posedge clk) $rose(rd) |-> rd[*3] ) $info("consecutive repeat success for repetition operator "); 
// read should be high for 3 clock ticks 
  a2: assert property(@(posedge clk) $rose(a) |-> b[*2:4] ) $info("success at %0t" , $time ); 
    // if repetition of more then the upper bound range wont cause an error 
    */
module tb;
 
 reg clk = 0;
 
 reg req1 = 0;
 reg req2 = 0;
 int delay1 = 0, delay2 = 0;

 
 
 always #5 clk = ~clk;
 
 initial begin
 for(int i = 0; i < 4; i++)
 begin
   delay1 = $urandom_range(4,8); // to get random delay 
 #delay1;
 req1 = 1;
 #20;
 req1 = 0;
 #30;
 end
 end
 
 initial begin
 for(int i = 0; i < 4; i++)
 begin
 delay2 = $urandom_range(3,5);
 #delay2;
 req2 = 1;
 repeat(delay2) #10;
 req2 = 0;
 #20;
 end
 end
 
 /////if req1 asserts, then it should remain stable for 2 clock ticks
  a1 : assert property (@(posedge clk) $rose(req1) |->  req1[*2] ) $info("success at time %0t", $time); 
 ////////if req2 asserts, then it should remain stable for 3 to 5 clock ticks 
 
 a2 : assert property (@(posedge clk) $rose(req2) |-> req2 [*3:5] ) $info("success at time %0t" , $time); 
      
 initial begin 
 #250;
 $finish();
 end
 
 
   initial begin
     $dumpfile("dump.vcd"); 
     $dumpvars ; 
     
   end
endmodule
