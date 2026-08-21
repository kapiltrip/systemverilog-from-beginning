// Code your testbench here
// or browse Examples
//consecutive no of repetitions is not equal then specified its failure [*3] to restrict teh count to 3 then a[*3] ##1 !a 
//a range (min , max) [*min:max] a[*1:3] ## !a 
//non consecutive repetition operator 
// [=] fail is weak in nature until we add a strong qualifier 
// 2 repetitionfor signal a , $rose(b) |-> a[=2] ##1 !a 
//goto 
// a[->2] = !a[*0:$] ##1 a ##1 !a[*0:$] ##1 a ;
// a[=2] =  !a[*0:$] ##1 a ##1 !a[*0:$] ##1 a ## !a[*0:$]  will add a series of 0's 
// in non consecutive the delay we specify is the min delay in the tail and it can match it throughout the expression , and also its weak in nature 

module tb;
 
 reg clk = 0;
 
 reg a = 0;
 reg b = 0;
 reg c = 0;
 
 
 always #5 clk = ~clk;
 
 initial begin
 #15;
 a = 1;
 #10;
 a = 0;
 
 end
 
 initial begin
   #20;
   b = 1;
   repeat(3) @(posedge clk); 
   b = 0; 
   #70;
   b=1;
   #10;
   b=0;
 end

 initial begin
 #94;
 c = 1;
 #10;
 c = 0;
 
 end
 
  A1: assert property (@(posedge clk) $rose(a) |->  b[=3:5] ) $info("Non-consecutive operator used here ,  Success @ %0t",$time); 
  A2: assert property (@(posedge clk) $rose(a) |-> strong( b[->3:5]) ) $info("GOTO Success @ %0t",$time); else $error("used strong qualifier ");
  a3: assert property (@(posedge clk) $rose(a) |-> b[=3] ##1 b ) $info("3 repetitions of b (non consecutive) done after a became high at time %0t ", $time) ;  
  a4: assert property (@(posedge clk) $rose(a) |-> b[->3] ##1 b ) $info("goto operator used in the assertion ") ; 
        
  //3 non consecutive repetitions of b then in the next clock tick b becomes high in the next clock tick non consecutive and goto operator both we will try 
 
 initial begin 
 $dumpfile("dump.vcd");
 $dumpvars;
 $assertvacuousoff(0);
 #200;
 $finish();
 end
 
endmodule
        
//write req must be followed by read req , if read do not assert before timeout , then system should reset 
    (!rst[*1:$] ##1 timeout) |-> rst ;
    (!rst[*1:$] ##1 tout ) [*n] |-> rst ;
    2) write request must be followed by read request 
    $rose(wr)|=> $rose(rd)
    3)if a assert b must assert in 5 clock tick
      $rose(a) |-> ##5 $rose(b) 
      4) if reset is deasserted then ce must assert within to 1 to 3 clock ticks 
        $fell(rst) |-> ##[1:3] $rose(ce)
      5) if req assert and ack not recieved in 3 clock ticks then req must reassert 
        $rose(req) |-> ##3 $rose(req)
        $rose(req) ##1 !ack[*3] |-> $rose(req)
        6) if a assert a must remin high for 3 clock ticks
          $rose(a) |-> a[*3]; 
    7) system must start with rst asserted for three consecutive clock ticks 
      initial a1: assert property (@(posedge clk) rst[*3])
    8) ce must assert somewhere, during simulation if reset deassert 
          $fell(rst) |->##[1:$] rose(ce)   // go to or non consecutive repetition 
          
    9) transaction starts with ce become high and ends with ce becomes low , each transaction must contain at least one read and write request 
          $rise(ce)|-> (rd[->] and wr[->]) ##1 !ce;
    10) if ce assert somewhere, after rst deassert then we must receive at least one write, request 
          $fell(rst) |-> ##[1:$] $rose(ce) |-> wr[->] ##1 !wr; 
    11)  a must assert twice during simulation  a[=2] 
      12) is a became high somewhere, then b must become high in the immediate next clock tick 
      $rose(a)|=> $rose(b)
      
      13)
      if req is received and all the data is sent to slave indicated by done signal then ready must be high in the next clock tick 
        
      $rose(req) |-> ##[1:$] done |-> $rose(ready)
        $rose(req) ##1 done[->] ##1 rdy ; 
        
