// Code your testbench here
// or browse Examples
// AND parametrized mailbox

class transaction ;
  rand bit [3:0] din1;
  rand bit [3:0] din2;
  bit [4:0] dout ;


endclass
class generator;
  transaction t;
  mailbox #(transaction) mbx;
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;

  endfunction
  task main();
    for(int i =0; i<10 ; i++)begin
      t=new();  // handler for transaction class new handle for each transaction
      assert(t.randomize ) else $display("Randmoization falied ");
      $display("GEN: DATA SENT IN din1 and din 2 is %0d and %0d after randomization   " , t.din1 , t.din2);
      mbx.put(t);
      #10;
    end
  endtask
endclass
class driver;
  transaction container ;
  mailbox #(transaction) mbx;

  function new(mailbox #(transaction) mbx);  // parametrized it to work with transaction class

    this.mbx=mbx;
  endfunction

  task main();
    forever begin
      mbx.get(container); // can i do it without making its handler
      $display("[DRV] : DATA RCVD : din1 is %0d and in din2 is %0d ", container.din1, container.din2);
      #10;

    end
  endtask
endclass
module tb;
  generator g;
  driver d ;
  mailbox #(transaction) mbx;
  initial begin
    mbx=new();
    g= new(mbx);
    d=new(mbx);
    fork
      //to hold the simulation until we can complete the transaction
      g.main();
      d.main();

    join
  end
endmodule
