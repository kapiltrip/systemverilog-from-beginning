# Part 10 — Tasks and Functions

[← Part 09](../09-class-object-basics/README.md) · [Learning index](../README.md) · [Part 11 →](../11-pass-by-reference/README.md)

EDA Playground: [Tasks and Functions](https://edaplayground.com/x/ecCx)  
EDA Playground Name: `Tasks and Functions`  
Saved code ID: `7356696`

## Why this example matters

Functions and tasks both package reusable behavior, but they serve different timing roles. A function returns a value and must complete without consuming simulation time; a task can contain timing controls and is therefore suitable for sequences that wait for clock edges or delays.

When choosing between them, ask whether the caller needs an expression result and whether the procedure must suspend. That decision is more reliable than choosing from the procedure's length or number of arguments.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
/*
module tb; 
  function bit [4:0] add(input bit [3:0] a , b);
    return a+b;
    
  endfunction 
  bit [4:0] result ;  // so no need to make the result initialized by 0 
  bit [3:0] ain= 4'b0100; 
  bit [3:0] bin =4'b1101  ; 
  // i can rather pass ain, bin to the function 

  function void displayAINBIN();
    $display("Inside the function display ain "); 
  endfunction 
    initial begin
    result = add(4'b0000 , 4'b1110 ); 
    $display("Value of addition is %0d" , result );
      displayAINBIN();
  end
endmodule
*/
// cannot add delay in function , 
// task 
module tb();
  bit [2:0] c;
  bit [2:0] d; 
  bit [3:0] e; 
  bit clk=0; 
  always #10 clk = ~clk; 
  
  //task add (input bit [3:0] c , input bit [3:0] d , output bit [4:0 ]e );
  task add();
    e=c+d; 
    $display("THE SUM IS : %0d ", e ); 
  endtask
 /* bit [3:0] a,b; 
  bit [4:0] y ;
  initial begin
      a =7; 
      b=4;
    add(a,b,y);
    $display("Value of y is %0d" , y); 
  end
  */
  
  task stimuli_clk();
    @(posedge clk);
    c=$urandom(); // 32 bit unsigned value will be generated 
    d=$urandom(); //
    add();
    $display("Clock generated of hte random values after waiting for posedges  are %0d" , e);
  endtask 
  task addWithTiming();
    c=1; 
    d=3;
    add();
    #10; 
    c=2;
    d=4;
    add(); 
    #30;
    c=5;
    d=8;
    
  endtask
  initial begin
    //addWithTiming(); 
    for(int i =0; i<11;i++)begin
      stimuli_clk();
    end
  end
  initial begin
    #110; 
    $finish(); 
    
  end
endmodule
// passby value task add (reg int x, y )
~~~

## Questions from the code, explained

### Why does result not need an explicit zero initialization?

**Question in the source**

>   bit [4:0] result ;  // so no need to make the result initialized by 0 

**Where it appears**

`testbench.sv:9` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment is beside result in a commented function example; result is assigned from add before it is displayed.

**Answer**

It does not need a pre-assignment of zero because the function call writes its returned five-bit value into result before the display.

**Why this works**

The declaration bit [4:0] result creates a five-bit variable, but the useful value in this sequence comes from result = add(...). The function returns a five-bit sum, and the assignment replaces the previous contents before result is read. Explicit initialization would still be useful if result could be read before that assignment, if a reset value were part of the model, or if the procedure could take a path that skipped the assignment. The comment is therefore valid for this straight-line sequence, not a general rule that result variables never need initialization.

**Watch for**

Trace all reads and writes. Initialization is unnecessary only when every read is dominated by a definite prior assignment.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Can the function receive the existing input variables?

**Question in the source**

>   // i can rather pass ain, bin to the function 

**Where it appears**

`testbench.sv:12` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment follows ain and bin declarations in the commented function example and contrasts literal arguments in the call.

**Answer**

Yes. The function can be called with ain and bin as actual arguments when their types and widths are compatible with the formal inputs.

**Why this works**

A function formal argument describes how a value enters the function. Passing ain and bin evaluates the caller's expressions and supplies those values to the function's input formals. The function's return value is still assigned to result. The choice between literals and variables affects where the inputs come from, not the function's return semantics. Width and signedness conversions must still be considered when the actual and formal declarations differ.

**Watch for**

Passing variables makes stimulus changes visible to the call, but it does not make an input formal a caller-visible output. Use an output or ref argument when the function is intended to update caller storage.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Why can a function not contain a delay?

**Question in the source**

> // cannot add delay in function , 

**Where it appears**

`testbench.sv:24` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment introduces the task-based portion of the testbench after the commented function example.

**Answer**

A function is required to complete in zero simulation time; a timing control such as # delay or event control belongs in a task or another timing-capable process.

**Why this works**

The language separates functions, which compute and return a value without consuming simulation time, from tasks, which may contain timing controls and may have multiple output/ref arguments. The testbench's stimuli_clk task waits for posedge clk, assigns randomized c and d, and then calls add. The add task itself performs the sum without a delay, while addWithTiming explicitly waits between stimulus phases. This split lets the example use a function-like calculation without timing and tasks for timed stimulus.

**Watch for**

Put waits in a task or surrounding procedural block. Calling a task from a function would not make timing legal inside the function's execution context.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### What value does $urandom generate here?

**Question in the source**

>     c=$urandom(); // 32 bit unsigned value will be generated 

**Where it appears**

`testbench.sv:50` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment is beside c=$urandom() and d=$urandom() in stimuli_clk, whose destinations are three-bit variables.

**Answer**

$urandom returns a 32-bit unsigned random value; assignment to the three-bit c or d keeps only the destination's representable bits.

**Why this works**

The system function produces an unsigned 32-bit value, but the left-hand side in this source is bit [2:0]. Assignment converts the result to the destination width, so the stored value is the relevant three-bit portion. The random value is generated each time the task reaches those assignments after waiting for a rising clock edge. The exact sequence is simulator seed dependent and should not be treated as a fixed expected transcript unless the seed and tool behavior are controlled.

**Watch for**

Do not describe c and d as holding all 32 random bits. Their declarations constrain what is stored and displayed.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### What does a pass-by-value task argument mean?

**Question in the source**

> // passby value task add (reg int x, y )

**Where it appears**

`testbench.sv:80` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The final comment records an alternative task signature that is not active code in the saved source.

**Answer**

A value argument supplies a copy of the actual value to the task; assignments to that formal do not update the caller's variable.

**Why this works**

For a pass-by-value input, the task receives a value in its formal argument. The task can use that value while it runs, but changing the formal changes the task's local argument state rather than the caller's storage. That differs from ref, where the formal denotes the caller's variable and updates are visible to the caller. The comment is an inactive experiment, so this README explains its language meaning without claiming that the saved page compiled or executed that signature.

**Watch for**

Choose value for an input snapshot and ref/output when caller-visible mutation is intended. Keep the distinction separate from whether the task itself may consume simulation time.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

## Further reading

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).



