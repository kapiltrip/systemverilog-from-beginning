// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
//INTERFACE : class will communicate with dut how?
class transaction ;
  randc bit [3:0] a;
  randc bit [3:0] b;
  bit [4:0] sum;
  function void display();
    $display("value of a is %0d \t and value of b is %0d \t and their sum is %0d " , a,b, sum );
    endfunction
  // CREATE A DEEP COPY
  function transaction copy(); // copies current ojbects attributes
    copy=new();
    copy.a=this.a;
    copy.b=this.b;
  endfunction
endclass

class generator;
  transaction t;
  mailbox #(transaction) mbx;
  event genDone ;
  function new (mailbox #(transaction) mbx) ;
    this.mbx=mbx; //
    t=new(); //WE HAVE A SINGLE OBJECT NOW RULE 1 ) ADD TRANSACTION CONSTRUCTOR IN GEN CUSTOM CONSTRUCTOR
  endfunction


  task run();
    for(int i =0 ; i<16;i++ )begin
      //t=new(); // we need  a deep copy INDEPENDENT SPACE OBJECT

      assert(t.randomize()) else $display("Randomization failed ");
      $display("[GEN] : DATA SENT TO DRIVER ");
      t.display();
      mbx.put(t.copy); // 1) send a copy and 2) sending deep copy HOW WILL THIS REMOVE THE REPEATED VALUES
      #20; //MANUAL DELAY IS NOT NEEDED HERE, OK
      $display("[GEN] : DATA ");
    end                //what it means to send a copy of the object
     ->genDone; //triggering the event now ,                   // RULE2 SEND A COPY OF TRANSACTION B/W DRIVER AND GENERATOR
    endtask
endclass


class driver;
  virtual add_interface.DRV aif;
  mailbox #(transaction) mbx;
  transaction container;
  event next ;
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;

  endfunction

   task run();
   forever begin
     mbx.get(container); // transaction type container

     @(posedge aif.clk);
     aif.a=container.a;
     aif.b=container.b;
     $display("[DRV] : INTERFACE TRIGGERED ");
     container.display();  // display the value received form the mailbox
     ->next; // event triggered next ;

    end
   endtask
endclass


module tb;
  add_interface aif();
  driver d;
  generator g;
  event done ;

  mailbox #(transaction) mbx;
  initial begin
    aif.clk<=0;
  end
  always #10 aif.clk = ~ aif.clk ;

  add dut(
    .a(aif.a),
    .b(aif.b),
    .clk(aif.clk),
    .sum(aif.sum)
  );

  initial begin
    mbx=new();
    g=new(mbx); // TRANSACTION OJBECT will be created here,
    d=new(mbx);
    d.aif=aif ; // what is the use of this
    done = g.genDone ;
  end
  initial begin
    fork
      g.run();
      d.run();

    join_none //non blocking
    wait(done.triggered);
    $finish();
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

  end
  /*
  initial begin
    #400;
    $finish();

  end
  */
endmodule

interface add_interface;
  logic [3:0] a ; //equivalent logic type defined in interface
  logic [3:0] b;
  logic [4:0] sum;
  logic clk ;
  modport DRV (output a,b,input sum, clk );// A AND B will have o/p direction rest all r inputs

endinterface
