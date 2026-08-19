// Code your testbench here
// or browse Examples
class first ;
  rand int data1;
  constraint data1_c { data1<10 ; data1>0 ; }
endclass
class second;
  rand int data1;
  constraint data1_c {data1 > 10 ; data1 <20 ; }
endclass
class main;
  semaphore sem;
  first f ;
  second s;
  int data1;

  task send_first();
    sem.get(1); // to get the semaphore access
    for(int i =0 ; i<10 ; i++)begin
      f.randomize();
      data1= f .data1;  // what is this line doing
      $display("First access of semaphore and Data sent is : %0d " , f.data1 );
      #10;

    end
    sem.put(1);
    $display("semaphore unoccupied by first task ");
  endtask
  task send_second();
    sem.get(1); // to get the semaphore access
    for(int i =0 ; i<10 ; i++)begin
      s.randomize();
      data1= s.data1;  // what is this line doing
      $display("First access of semaphore and Data sent is : %0d " , s.data1 );
      #10;
    end
    sem.put(1);
      $display("semaphore unoccupied for second task  ");
  endtask

task run();
  sem = new(1);
  f=new();
  s=new();
  fork
    send_first();
    send_second();

  join // blocking in nature second waits till first, release the semaphore since sem(1)
endtask
endclass

module tb;
  main m ;
  initial begin
    m=new();
    m.run();

  end
  initial begin
    #250;
    $finish();

  end
endmodule
