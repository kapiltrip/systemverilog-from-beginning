// Code your testbench here
// or browse Examples
//[*lower:$] // not known upper bound 

//psel high until( after ) penable deassert 
//a1: assert property (@(posedge clk) $rose(psel) |-> psel[*1:$] ##1 $fell(penable)) $info("success at %0t", $time); 
// 5 write cycles during when reset is disabled
//  5 read cycles 
//  read cycles must stay high for 2 clock ticks consecutive repetition operation 
  // read adn wr should stay low 

module tb;
 
 reg clk = 0;
 
 reg rd = 0;
 reg wr = 0;
 reg rst = 0;
 
 reg done = 0;
 
 int delayw,delayr;
 
 always #5 clk = ~clk;
 
 initial begin
 rst = 1;
 #20;
 rst = 0; 
 end
 
 task write();
 for(int i = 0; i<5 ; i++) 
 begin
 @(negedge clk);
 delayw = $urandom_range(1,3);
 wr = 1;
 @(posedge clk);
 wr = 0; 
 repeat(delayw) @(posedge clk); 
 end
 endtask
 
 task read();
 for(int i = 0; i<5 ; i++) 
 begin
 @(negedge clk);
 delayr = $urandom_range(1,3);
 repeat(delayr) @(posedge clk);
 rd = 1;
 repeat(2)@(posedge clk);
 rd = 0; 
 end 
 endtask
 

 initial begin
 #20;
 fork
 write();
 read();
 join
 end
 
 initial begin
 #295;
 done = 1;
 #10;
 done = 0;
 
 end
  a1: assert property (@(posedge clk) $rose(rd) |-> rd[*2] ##1 !rd ) $info("Read high for 2 clock ticks and then it went 0 at time %0t " , $time); 
// 5 read adn write cycles with the dut 
    a2: assert property (@(posedge clk) $fell(rst) |-> wr[=5]) $info("5 write successful"); 
      a3: assert property (@(posedge clk ) $fell(rst) |-> $rose(rd) [=5] ) info("five read cycles "); 
        
  
 initial begin 
 $dumpfile("dump.vcd");
 $dumpvars;
 $assertvacuousoff(0);
 #310;
 $finish();
 end

endmodule
