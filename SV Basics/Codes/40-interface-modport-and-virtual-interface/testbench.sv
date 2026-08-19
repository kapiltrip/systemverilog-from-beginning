// Code your testbench here
// or browse Examples
//INTERFACE : class will communicate with dut how?
interface add_interface;
  logic [3:0] a ; //equivalent logic type defined in interface
  logic [3:0] b;
  logic [4:0] sum;
  logic clk ;
  modport DRV (output a,b,input sum, clk );// A AND B will have o/p direction rest all r inputs

endinterface

  class driver;
    // specific modport restriction we define the input outputs of the driver
    virtual add_interface.DRV aif; //virtual comes under polymorphism like definition will be overridden in the derived class ig in cpp it means that
    task run();
      forever begin
        @(posedge aif.clk);
        aif.a=3;
        aif.b=4;

      end
    endtask
  endclass



  module tb;
    add_interface aif();
    add dut(
      .a(aif.a),
      .b(aif.b),
      .sum(aif.sum),
      .clk(aif.clk)

    );
    initial begin
      aif.clk=0;  // use blockign or non blocking

    end

    always #10 aif.clk = ~aif.clk ;
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      #100;
      $finish();
    end
    //to connect interface with driver in testbench top
    driver d;
    initial begin
      d=new();
      d.aif= aif;
      d.run();
    end
  endmodule











  /*
  module tb;
  add_interface aif(); // bracket is needed when adding instance / is it instance or handler ?
    initial begin
     aif.clk=0;
  end
  always #10 aif.clk = ~aif.clk ;

  add dut(
    .a(aif.a),
    .b(aif.b),
    .sum(aif.sum),
    .clk(aif.clk)
  );

  initial begin
    aif.a<=4;                               // prefer non blocking operator
    aif.b<=4;
    // if input changes b/w clock tick it will be ignored
    repeat (3) @(posedge aif.clk);
    #10;
    aif.a<=7;
    aif.b<=3;
    #10;                        //instead we can use @
    aif.a<=2;
    aif.b<=8;
    #10;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    #100;
    $finish();
    //interface with all reg type then we r not allowed to connect varialbe to the out put of dut
    // to apply using initial block if i declare by reg type
  end
endmodule
*/
