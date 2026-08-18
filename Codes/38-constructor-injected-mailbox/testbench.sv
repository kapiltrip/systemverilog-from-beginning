// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
// mailboxes between 2 classes i.e between generator and driver and monitor and scoreboard
class generator ;
  int data= 12;
  mailbox mbx;
  function new(mailbox mbx);
    this.mbx=mbx;
  endfunction
  task run();
    mbx.put(data);
    $display("[GEN] : SENT DATA : %0d" , data);
  endtask
endclass

class driver;
  int container =0 ;
  mailbox mbx2;

  function new(mailbox mbx);
    this.mbx2=mbx;
  endfunction

  task run();
    mbx2.get(container);
    $display("[DRV] : RCVD DATA : %0d" , container);
  endtask

endclass
module tb;
  generator g;
  driver d;
  mailbox mbx3;

  initial begin
    mbx3= new();
    g=new(mbx3);
    d=new(mbx3);


    g.run();
    d.run();

  end
endmodule
