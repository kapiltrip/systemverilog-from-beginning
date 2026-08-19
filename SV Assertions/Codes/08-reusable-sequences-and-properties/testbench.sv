// Code your testbench here
// or browse Examples
module tb;
  reg ce=0,wr=0,rd=0,clk =0,rst=0;
  always #5 clk = ~ clk ; 
  initial begin
    rst=1; 
    #30; 
    rst=0; 
  end
  initial begin
    ce=0;
    #30;
    ce=1;
    
  end
  initial begin
    #30;
    wr=1;
    #10;
    rd=1;
    #20;
    wr=0;
    rd=0;   
  end
  
  sequence cewr(logic a , logic b);
      a && b; 
  endsequence 
  
  property p1;
    (@(posedge clk) $fell(rst) |-> cewr(ce,wr));   
  endproperty
  
  property p2(logic a , logic b );
    (@(posedge clk) $fell(rst) |=> (a&&b ));   
  endproperty
  
     CHECK_WRP1 : assert property (p1) $info("checked by p1 passes at time %0t" , $time);
       CHECK_WRP2 : assert property (p2(ce,rd)) $info("check passes through p2 at time %0t" , $time);  
     
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars; 
      $assertvacuousoff(0); // to filter vacuous success
      repeat (20) @(posedge clk) ; 
      $finish();
    end
         
endmodule
