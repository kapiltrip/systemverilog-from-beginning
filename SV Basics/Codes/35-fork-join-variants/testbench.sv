// Code your testbench here
// or browse Examples
module tb;
  task first ();
    $display("Task 1 started at %0t " , $time);
    #20;
    $display("Task 1 completed at %0t " , $time);
  endtask
  task second ();
    $display("Task 2 started at %0t " , $time);
    #30;
    $display("Task 2 completed at %0t " , $time);
  endtask

  task third ();
    $display("Reached next to join at time  %0t " , $time);

  endtask

  initial begin
    fork                 // allow to join multiple process in parallel
      first();           // will block first, then second

      second();
    //join
    //join_any

    join_none // totally non blocking
    // to call all the tasks in parallel , join_any or join_none
    // only when all the processes in fork join complete its execution
    third(); // will even finish at 2000 ns
    $display("Reached third after the end of first at time  %0t " , $time);
  end
endmodule
