// Code your testbench here
// or browse Examples
// to keep a tract of initial begin block so i cant predict based on delay in the initial begin block there, priority so for that we
module tb;
  int i =0;
  bit [7:0] data1 , data2;
  event done ;
  event next ;
  task generator();
    for(i=0 ; i<10 ; i++)begin
      data1 = $urandom();
      $display("Data sent by generator is %0d generated at time %0t " , data1 , $time);
      #10;
      wait(next.triggered);  // at 100 ns this will be triggered i.e 90 + 10 hence the time == 100

    end
    // outside the for loop
    -> done;
  endtask
  task receiver();
    forever begin
      #10;
      data2=data1;
      $display("Data received by receiver is %0d " , data2);
      ->next; // current stimuli is copied

    end
  endtask

  task wait_event();
    wait(done.triggered);
    $display("Transmitter sent all the transaction in time %0t " , $time);
    $finish();

  endtask
  initial begin
    fork  // fork join will hold the simulation unless all the process will complete
          // to schedule multiple processes / tasks in parallel

      generator();
      receiver();
      wait_event();

    join
  end
endmodule
