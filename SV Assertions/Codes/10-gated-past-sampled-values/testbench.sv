// Code your testbench here
// or browse Examples
module tb;
  reg a =1 , clk =0;
  reg en =0;
  reg [3:0] b =2; 
  always #5 clk = ~clk ; 
  initial begin
    en =1;
    #100;
    en =0;
    
  end
  initial begin
    for(int i =0; i<15;i++)begin
      a = $urandom_range(0,1); 
      b= $urandom_range(0,15); 
      @(posedge clk); // this is the delay its gonna experience
    end
  end
  /*
  always @(posedge clk)begin
    $display("value of a if %0d and b is %0d " , $sampled(a) , $sampled(b)); 
    $display("value of past a is %0d and past b is %0d" , $past(a) , $past(b)); 
    $display("------------------------------------------------------------------");
  end
  */
  always @(posedge clk)begin
    $display("value of a if %0d and b is %0d and en is (%0d) and time is %0t" , $sampled(a) , $sampled(b) , en , $time); 
    $display("value of past a is %0d and past b is %0d and en is (%0d)" , $past(a,1,en) , $past(b,1,en) , en ) ; 
    $display("------------------------------------------------------------------");
  end
  initial begin
    repeat (20) @(posedge clk); 
    $finish();
  end
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars ; 
    
  end
/*
if a is asserted b must assert in next clock tick 
  assert property (@(posedge clk) $rose(a) |=> $rose(b)
each new request must be followed by ack
  assert property (@(posedge clk) $rose(req) |=> $rose(ack))

if rst deassert , ce must assert in same clock tick 
  assert property (@(posedge cllk) ($fell(rst)) |-> ($rose(ce))); 
    
wr request must be folowed by rd request    
    assert property (@(posedge clk) $rose(wr) |=> $rose(ack))
   
current value of addr must be one greater than previous value if start asserted 
  assert property (@(posedge clk) ($rose(start) |-> (addr == $past(addr)+1 ) )) ; 
                   
if rst deassert dout must be 0 
  assert property (@(posedge clk) $fall(rst) |-> dout==0)

if loading deassert dout must be equal to load value 
  
if rst deassert output of the shift reg must be shifted to left by 1 in the next clock tick
  $fell(rst) |=> sout== {sout[6:0] , 0} ; // left shift 
if rst deaddert current value and past value of the signal differ only in a single bit 
  $fall(rst) |=> $onehot(a ^ $past(a)) // then its in gray ,cause 1  bit change 
a dff output must remain constant if ce is low 
  $fell(c) |-> (q == $past(q))
in a tff if ce assert output must toggle 
  $rose(ce) |-> (q== ~$past(q)) ; 
    assertvacuousoff(0)
*/                 
                                    
endmodule
