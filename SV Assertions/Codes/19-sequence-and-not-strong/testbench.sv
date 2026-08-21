// to make the assertion a2 strong 

module tb;
 reg clk = 0,rd,wr,start;
 
 always #5 clk = ~clk;
 
 
 
 
 
 initial begin
 start = 0;
 #20;
 start = 1;
 #10;
 start = 0;
 end

 //write  
 initial begin
 wr = 0;
 #30;
 wr = 1;
 #10;
 wr = 0;
 end
 //read 
 initial begin
 rd = 0;
 #40;
 rd = 1;
 #20;
 rd = 0;
 end



 sequence seqwrite;
   wr[*1]; // single repetition of write, 
 endsequence
 
 
 
 sequence seqread;
   ##1 rd[*2]; // 1 clock tick delay and 2 repetitions of read 
 endsequence
 
 sequence seqwriteandread;
   (##[0:$] wr && rd) ;  // o to infinite delay but strong wr and read both should be high : its showing error in strong 
   
 endsequence
  a1: assert property (@(posedge clk) $rose(start) |=> seqread and seqwrite) $info("write and read "); 
    // read and write operation do now occur at the same time 
    
    a2: assert property (@(posedge clk) $rose(start) |=> not strong(seqwriteandread)) $info("read and write, not high at the same time"); 
initial begin
 $dumpvars;
 $dumpfile("dump.vcd");
 $assertvacuousoff(0);
 #110;
 $finish;
 end
endmodule
