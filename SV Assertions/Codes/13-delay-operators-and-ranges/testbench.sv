// Code your testbench here
// or browse Examples
//delay operators 
//constant delay we know when to evaluate 
// variable delay , we have an idea that censequent must become true in the range ##(min, max )delay 
// unbounded delay : if req becomes high ack must also become high somewhere during the simulation 
// ##[: $]
// cause overlapping and non overlapping alone wont allow to evaluate after 1 clock tick
module tb;
 
 reg clk = 0;
 
 reg req = 0;
 reg ack = 0;
 
 always #5 clk = ~clk;
 
 initial begin
   repeat(3) begin
     #1;
     req = 1;
     #5;
     req = 0;
     repeat(3) @(negedge clk);
   end
 end
 
  initial begin
    for(int i =0 ; i<15;i++)begin
      repeat(3) @(posedge clk);
      ack = $urandom_range(0,1); 
      @(posedge clk); 
      ack=0; 
      
    end
  end
 
  A1: assert property (@(posedge clk) $rose(req) |=> ##2 $rose(ack)) $info("Success at %0t",$time);
    A2: assert property (@(posedge clk) $rose(req) |-> ##[2:5] $rose(ack) ) $info("Success with min 2 and max 5 delay at %0t" , $time); 
      
 
 initial begin 
 $dumpfile("dump.vcd");
 $dumpvars;
 $assertvacuousoff(0);
 #200;
 $finish();
 end
 
endmodule
