// Code your testbench here
// or browse Examples
//To inject error form generator class to driver and hence dut
//DEEP COPY OF A TRANSACTION
/*
1) independent object
2) capability to inject an error form gen to driver */
class transaction ;
  randc bit [3:0] a;
  randc bit [3:0] b;
  bit [4:0] sum;
  function void display();
    $display("value of a is %0d \t and value of b is %0d \t and their sum is %0d " , a,b, sum );
    endfunction
  virtual function transaction copy ();  // making a new handle of type transaction
    copy=new();                  //copying the current objects attributes to that handle
    copy.a= this.a;
    copy.b=this.b;
    copy.sum=this.sum;
  endfunction  // value is getting generated but the copy is sending 0 to the object handle
endclass
//inject the error
class error extends transaction ;
  //constraint data_c {a ==0 ; b==0; }
   function transaction copy ();  // making a new handle of type transaction
    copy=new();                  //copying the current objects attributes to that handle
    copy.a= 0;
    copy.b=0;
    copy.sum=this.sum;
   endfunction
endclass

class generator;
  transaction t;
  mailbox #(transaction) mbx;
  event genDone ;
  //CONSTRUCTOR FOR GENERATOR
  function new (mailbox #(transaction) mbx) ;
    this.mbx=mbx; //
    t=new(); //single space so randc can remember its history and we can get intended behaviour
  endfunction


  task run();
    //t=new();//single object

    for(int i =0 ; i<16;i++ )begin
      //t=new(); // we need  a deep copy INDEPENDENT SPACE OBJECT

      assert(t.randomize()) else $display("Randomization failed ");
      $display("[GEN] : DATA SENT TO DRIVER ");
      t.display();
      mbx.put(t.copy);  //im not sending the real transaction obj instead im sending the copy
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
  error err;

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
    g=new(mbx); // TRANSACTION OJBECT will be created here, this will be removed
    d=new(mbx);
    err=new();

    g.t=err; // will send an error injecting of error

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
