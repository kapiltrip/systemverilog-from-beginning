// Code your testbench here
// or browse Examples
//simple immediate assertions => precedural block 
//observed deffered / final deffered immediate assertion . can use outside the procedural block for combinational blocks / 
// observed final deffered simple immediate assertion and final deffered immediate assertion required a procedural block 
/* 
assert (s == a ^ b ) $info("pass action "); else $error("Fail action "); 
assert #0 () $info("pass action "); // deffered assert 
assert final () ; final assert 
*/
module tb(); 
  reg a=0, b=0,c=0,d=0;
  reg [1:0] sel =0;
  mux dut (
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .sel(sel),
    .y(y)
  );
  always #5 a = ~a ; 
  always #10 b = ~b;
  always #15 c = ~c; 
  always #20 d = ~d; 
  initial begin
    sel= 2'b00; 
    #50;
    sel= 2'b01; 
    #50;
    sel= 2'b10; 
    #50;
    sel= 2'b11;                
  end
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars; 
    #300; 
    $finish; 
    
  end
endmodule
