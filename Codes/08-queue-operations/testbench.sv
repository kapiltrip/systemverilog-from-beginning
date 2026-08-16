// Code your testbench here
// or browse Examples
// QUEUES
module tb;
  int q[$];
  int data=0;  // SO I HAVE TO DEFINE DATA HERE, FOR USING IT LATEER ? ALSO TELL ME WHY CANT I DEFINTE LIKE THIS IN
               // THE INITIAL BLOCK , int data = q.pop_front()
  int data1=0;
  initial begin
    q = {1,2,3};
    $display("The value of the queue is holding is %0p" , q);
  end
  // to push data now in the queue
  initial begin
    q.push_front(4);
    $display("The value of the queue is holding is %0p" , q);
    q.push_back(7);
    $display("The value of the queue is holding is %0p" , q);
    //at an index 2
    q.insert(2,10); // index, number to be inserted
    $display("The value of the queue is holding is %0p" , q);
    // POP OPERATIONS

    data = q.pop_front();
    $display("The value of the queue is holding is %0p , and the data removed is %0d" , q , data );
    data1 = q.pop_front();
    $display("The value of the queue is holding is %0p , and the data removed is %0d" , q , data1 );
    q.delete(1);
    $display("The value of the queue is holding is %0p" ,q);

  end
endmodule
