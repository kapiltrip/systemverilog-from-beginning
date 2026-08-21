// Code your testbench here
// or browse Examples
module tb;
  reg clk , rst , up ; 
  wire [3:0] dout;

  // what is a temp 
  counter dut (clk , rst , up , dout);
  bind counter counter_assert dut2 (clk , rst, up , dout );
  always #5 clk = ~clk ; 
  initial begin
    rst=1; 
    #30; 
    rst=0;
    up=1;
    #200; 
    up=0;
    rst=1; 
    #25; 
    rst =0; 
    
  end
    initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    $assertvacuousoff(0);
    #360;
    $finish;
  end
endmodule
module counter_assert (
  input clk , rst , up, 
  input [3:0] dout
);
// reset is asserted , behaviour of dout 
  dout_rst_asserted : assert property (@(posedge clk) $rose(rst) |-> (dout == 4'b0000)) $info("dout must be 0 for reset asserted ");
  dout_rst_asserted_2 : assert property (@(posedge clk) rst |-> (dout == 4'b0000)) $info("dout must be 0 for reset asserted ");
  dout_beh_3 : assert property (@(posedge clk) $rose(rst) |=>rst  throughout ((dout==4'b0000)[*1:36])) ;  
      
      
  // dout must be valid after rst deassert 
    doutValid : assert property (@(posedge clk) $fell(rst) |-> !$isunknown(dout)); 
      always @(posedge clk ) begin
        doutValid2: assert (!$isunknown(dout));
      end
      // to verify how the up counter behaviour 
      upBeh: assert property (@(posedge clk) disable iff(rst) up|-> (dout == $past(dout) + 4'd1) || (dout ==0));
      // next value must be greater than zero when up =1 and rst =0 
        upHighRst: assert property (@(posedge clk) $fell(rst) |=> (dout != 0 )) ;
          upHighRst2: assert property (@(posedge clk ) $fell(rst) |-> up[->1] |=> !$stable(dout)); // i greater than the prev value hence unstable 
      // i think i can use in upHighRst assertion the non overlapping and the delay operator interchangibly 
            // also i wanna know the use of [-> 1 ] goto operator ? do i used it cause i am expecting up to be high in any interval and also its stronger version i should there ig.
       // curr value of dout must be one less than previous value when up ==0  
       
            upZero : assert property (@(posedge clk) disable iff (rst) !up|-> (dout  == $past(dout)-1  ) || dout==0 || ($past(dout ==0 ))) ; 
        // to comment on the correctness of upZero 
            upZero2: assert property (@(posedge clk) (!up && !rst ) |=> !$stable(dout)); 
              
              
              property p1;
                if(up) 
                  (dout == $past(dout) +1 );
                  else 
                    (dout == $past(dout) -1 );
              endproperty          
              both_property: assert property (@(posedge clk) !rst |-> p1 ); 
                both_prop2: assert property (@(posedge clk) $fell(rst) |=> (dout !=0 )) ; 
  endmodule
