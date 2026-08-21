module tb;
 reg a = 0, b = 0, c = 0; //Data Signal
 reg clk = 0; // Clock
 
 
 always #5 clk = ~clk; ///Generation of 10 ns Clock


 initial begin
 #28;
 b = 1;
 #30;
 b= 0; 
 end
 

 initial begin
 #63;
 c = 1;
 #10;
 c= 0; 
 end
 

 initial begin
 #28;
 a = 1;
 #40;
 a = 0; 
 end
 
 /////////reference sequence
 
 sequence seq_bc;
 b[*3] ##1 c;
 endsequence
 sequence seq_a;
   a[*4];
 endsequence
  
  a1: assert property (@(posedge clk) $rose(b) |-> a throughout seq_bc) $info ("A is high throughout the seq_bc at time %0t" , $time );  
 //To stay constant throughout seq_bc b stable 1 for 3 clock tick , a high for 4 clock ticks consecutive 
  a2: assert property (@(posedge clk) $rose (b) |-> seq_a within seq_bc) $info("Within operator passed at time %0t " , $time) ; 
    a3: assert property (@(posedge clk) $rose(b) |-> seq_a intersect seq_bc) $info("intersection happened at time %0t" , $time ) ; 
      
 initial begin
 $dumpfile("dump.vcd");
 $dumpvars;
 #150;
 $finish;
 end
 
 
endmodule
/*     
      //sclk toggles for entire duration of chip select 
      assert property (@(posedge clk) $fell(cs) |=> !cs throughout ($changed(sclk)) ); 
      
      SCLK MUST TOGGLE FOR ENTIRE DURATION OF CHIP SELECTION 
        assert property (@(posedge clk) !cs |=> !cs throughout ($changed(sclk ) ) ;     
        assert property (@(posedge clk) !cs |=> !cs throughout ($changed (sclk))) ; 
        assert property (@(posedge clk) ce|=> ce throughout (dout == $past(dout) +1 ))
        
        TWO REQUEST FROM A AND THREE REQUEST FROM B MUST COMPLETE AT SAME TIME 
        assert property (@(posedge clk) $rose (start) |-> a[->2] intersect b[->3]) ; 
        // a must hold till master received three requests from b 
        assert property (@(posedge clk) $rose(start) |-> a throughout b [->3]) ; 
        rst must remain deasserted for atleast one read and write, request 
        !rst throughout rd[->1] and wr[->1]
        req must be followed by ack after completionof data transfer . 
        load must assert at same clock tick when ack is received 
        req ##1 ack[->1] intersect load[->1] 
        between start adn stop there must be atleast one request followed by ack 
        $rose(start) |-> (req[->] ##1 ack) within stop[->1 ] ;   
        
        read and write request must not occur at same time 
        $rose(rd) |->not (wr[->1]) within rd[*2] //-< this is the reference 
*/
