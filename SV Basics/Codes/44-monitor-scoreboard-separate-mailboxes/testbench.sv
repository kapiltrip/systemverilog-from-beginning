// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
//To inject error form generator class to driver and hence dut
//DEEP COPY OF A TRANSACTION
/*
1) independent object
2) capability to inject an error form gen to driver */
// IT WORKED YAYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY

class transaction ;
  randc bit [3:0] a;
  randc bit [3:0] b;
  bit [4:0] sum;
  function void display();
    $display("value of a is %0d \t and value of b is %0d \t and their sum is %0d " , a,b, sum );
    endfunction
  function transaction copy();
    copy = new();
    copy.a = this.a;
    copy.b = this.b;
    copy.sum = this.sum;
    endfunction


endclass
//inject the error


class generator;
  transaction t;
  mailbox #(transaction) mbx;
  event genDone ;
  //CONSTRUCTOR FOR GENERATOR
  function new (mailbox #(transaction) mbx_generator_driver) ;
    this.mbx=mbx_generator_driver; //
    t=new(); //single space so randc can remember its history and we can get intended behaviour
  endfunction


  task run();
    //t=new();//single object

    for(int i =0 ; i<16;i++ )begin
      //t=new(); // we need  a deep copy INDEPENDENT SPACE OBJECT

      assert(t.randomize()) else $display("Randomization failed ");
      $display("[GEN] : DATA SENT TO DRIVER ");
      t.display();
      mbx.put(t.copy);  // send an independent transaction snapshot
      #20;
      $display("[GEN] : DATA ");
    end
     ->genDone;
    endtask
endclass

class driver;
  virtual add_interface.DRV aif;
  mailbox #(transaction) mbx;
  transaction container;
  event next ;
  function new(mailbox #(transaction) mbx_generator_driver);
    this.mbx=mbx_generator_driver;

  endfunction

   task run();
   forever begin
     mbx.get(container); // transaction type container

     @(negedge aif.clk);
     aif.a=container.a;
     aif.b=container.b;
     $display("[DRV] : INTERFACE TRIGGERED ");
     container.display();  // display the value received form the mailbox
     ->next; // event triggered next ;

    end
   endtask
endclass




interface add_interface;
  logic [3:0] a ; //equivalent logic type defined in interface
  logic [3:0] b;
  logic [4:0] sum;
  logic clk ;
  modport DRV (output a,b,input sum, clk );// A AND B will have o/p direction rest all r inputs

endinterface


class scoreboard;
  transaction trans;
  mailbox #(transaction) mbx; // to send from monitor to scoreboard
  function new( mailbox #(transaction) mbx_monitor_scoreboard);
    this.mbx=mbx_monitor_scoreboard;
  endfunction
  task run();
    forever begin

      mbx.get(trans);
      trans.display();
      compare(trans);

      #40;
    end

  endtask

  task compare(input transaction trans);
    if((trans.sum) == (trans.a + trans.b ))begin
      $display("sum result matches") ;
    end else begin
      $error("Result mismatches ");
    end
  endtask

endclass



class monitor;
  virtual add_interface aif;
  mailbox #(transaction) mbx; // to send from monitor to scoreboard
  transaction trans;
  function new( mailbox #(transaction) mbx_monitor_scoreboard);
    this.mbx=mbx_monitor_scoreboard;
  endfunction

  task run();
    @(negedge aif.clk);
    forever begin
      @(posedge aif.clk);
      #1;
      trans= new(); // cause i want a new transaction object each time a task is called
      trans.a = aif.a;   // from interface to transaction
      trans.b =aif.b;
      trans.sum =aif.sum;
      mbx.put(trans); // after the response from teh dut i put the transaction into the mailbox
      $display("data sent to scoreboard is a,b, sum as following , %0d , %0d , %0d " , aif.a , aif.b , aif.sum);

    end
  endtask
endclass



module tb;
  add_interface aif();

  monitor m;
  scoreboard sco;

  driver d;
  generator g;
  event done ;

  mailbox #(transaction) mbx_generator_driver ;
  mailbox #(transaction) mbx_monitor_scoreboard ;

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
    mbx_generator_driver = new();
    mbx_monitor_scoreboard = new();
    g = new(mbx_generator_driver);
    d = new(mbx_generator_driver);
    d.aif = aif;
    m=new(mbx_monitor_scoreboard);
    sco= new(mbx_monitor_scoreboard);
    done = g.genDone;
    m.aif= aif;

    fork
      g.run();
      d.run();
      m.run();
      sco.run();
    join_none
    wait(done.triggered);
    $finish();
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

  end

endmodule
