# Part 08 — Queue Operations

EDA Playground: [Queue Operations](https://edaplayground.com/x/bKTC)  
EDA Playground Name: `Queue Operations`  
Saved code ID: `7356536`

This README documents the exact source currently saved in the linked EDA Playground. The source panes are preserved verbatim; the explanations below do not replace or correct the code.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Verbatim design.sv

~~~systemverilog
// Code your design here
~~~

## Verbatim testbench.sv

~~~systemverilog
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
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes. No corrected or self-checking replacement is included in this part. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### Where should data be declared for the later queue operation?

**Original code question**

>   int data=0;  // SO I HAVE TO DEFINE DATA HERE, FOR USING IT LATEER ? ALSO TELL ME WHY CANT I DEFINTE LIKE THIS IN 
>                // THE INITIAL BLOCK , int data = q.pop_front()

**Where it appears**

`testbench.sv:6–7` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

data is declared at module scope and is assigned the value returned by q.pop_front() in a second initial block, while another initial block initializes the queue.

**Answer**

A module-scope declaration makes data visible to both the declaration context and the later display; declaring it inside an initial block is legal, but it would be local to that block and its initializer could race with the other initial block's queue initialization.

**Deep explanation**

A declaration inside an initial block has block scope. It can be written as int data = q.pop_front(), and that declaration executes when the block reaches it. It cannot be referenced by a different initial block because the local name is not visible there. In this source, the queue is initialized in one initial process and popped in another; both processes start at time zero, so there is also no ordering guarantee that q = {1,2,3} runs first. The module-level data variable solves visibility, not the cross-process race. A reliable observation would require synchronization, but the original source is preserved unchanged here.

**Practical implication or pitfall**

Separate scope and scheduling: move a declaration only when visibility is the issue, and add an event or other synchronization only when ordering is the issue. A local declaration does not fix a race between initial blocks.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

## Source references

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).



