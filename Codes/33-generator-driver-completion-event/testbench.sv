// Code your testbench here
// or browse Examples
module tb;
  int data1, data2;
  event e1;

  initial begin
    //generator block
    //will gen based on user requeirement
    for(int i =0; i<10 ; i++)begin
      data1= $urandom(); // unsigned 32 bit random value
      $display("Data sent by the generator is : %0d " , data1);

      #10 ;

    end
    ->(e1); // completed the process of generation of stimulus

  end
  // to driver i.e to receive the data
  initial begin
    forever begin
      #10 ;
      data2= data1;  // reading and storing that, to data 2
      $display("Data received by the driver is : %0d " , data2);

    end
  end
  //for controlling the simulation
  initial begin
    wait(e1.triggered);
    $display("all the stimuli generation has been done ");
    $finish();

  end
endmodule
