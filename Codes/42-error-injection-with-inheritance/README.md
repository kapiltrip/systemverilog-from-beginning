# Part 42 — Error Injection with Inheritance

[← Part 41](../41-layered-adder-testbench-and-object-copies/README.md) · [Learning index](../README.md) · Next part not captured yet

| Saved-playground field | Value |
|---|---|
| Original queue label | `012` |
| Indexed EDA name | `SV 42 - Error Injection with Inheritance` |
| Stable playground | [Cxwq](https://edaplayground.com/x/Cxwq) |
| Saved code ID | `7365122` |
| Simulator | Aldec Riviera Pro 2025.04 |
| Compile / run options | `-timescale 1ns/1ns` / `+access+r` |
| Live result | **Compile failure:** undefined `copy` member at `testbench.sv:39` |

This stage attempts to inject constrained error traffic by assigning a derived `error` object into the generator's base-class `transaction` handle. That is the right polymorphic direction, but two independent defects prevent the intended behavior. Keeping both defects visible makes this a useful architecture-debugging lesson.

## Intended object flow

~~~text
error object (a==0, b==0)
        │ assigned through base transaction handle
        ▼
     generator.t ── randomize ── copy ── mailbox ── driver ── DUT
~~~

Because `error extends transaction`, an `error` handle may be assigned to a `transaction` handle. A virtual method call through that base handle can still dispatch to derived behavior. Merely assigning the handle is not enough, however; later code must preserve the dynamic object and the copy policy must preserve its relevant type/state.

## Why the saved source fails to compile

The transaction class in this playground no longer declares the `copy()` method present in Part 41, yet the generator still calls `t.copy` at `testbench.sv:39`. Riviera reports:

> Member `copy` not found in `t`.

The original source is preserved unchanged. A minimal compile repair would restore a transaction copy method. A robust polymorphic design would declare a virtual copy/clone method in the base class and override it in `error`, so copying a derived object does not silently turn it back into an unconstrained base transaction.

## Why error injection would still be defeated after that compile repair

The top performs:

~~~systemverilog
g.t = err;
~~~

but the first statement of `generator.run()` performs:

~~~systemverilog
t = new();
~~~

That second line overwrites the derived `error` handle with a fresh base `transaction` object before the first randomization. Therefore the `a==0` and `b==0` constraint would never control the generated traffic. Remove that overwrite, or move object creation behind a virtual factory method that returns the desired dynamic type.

## Question from the code: what is the use of `d.aif = aif`?

As in Part 41, the assignment binds the driver's virtual-interface variable to the concrete interface instance in `tb`. It is unrelated to error injection but essential to signal access. Without it, `d.aif` remains null.

## A safer architecture direction

The next revision should separate four policies:

1. **Creation:** a factory or injected prototype decides whether the next item is `transaction` or `error`.
2. **Randomization:** dynamic constraints on the chosen object create legal or deliberately erroneous stimulus.
3. **Copying:** a virtual clone method returns an independent object while preserving the dynamic type and copied fields.
4. **Checking:** a monitor and scoreboard determine whether the DUT response matches the intended error scenario.

This design avoids hard-coded `new()` calls that accidentally discard derived behavior.

## Design code

~~~systemverilog
// Code your design here
// Code your design here
// Code your design here
module add(
  input [3:0]a,b,
  input clk,
  output reg [4:0] sum
);
  always @(posedge clk)begin
       sum <= a+b;

  end
endmodule
~~~

## Testbench code

~~~systemverilog
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

endclass
//inject the error
class error extends transaction ;
  constraint data_c {a ==0 ; b==0; }
endclass

class generator;
  transaction t;
  mailbox #(transaction) mbx;
  event genDone ;
  function new (mailbox #(transaction) mbx) ;
    this.mbx=mbx; //
    t=new(); //WE HAVE A SINGLE OBJECT NOW RULE 1 ) ADD TRANSACTION CONSTRUCTOR IN GEN CUSTOM CONSTRUCTOR
  endfunction


  task run();
    t=new();//single object

    for(int i =0 ; i<16;i++ )begin
      //t=new(); // we need  a deep copy INDEPENDENT SPACE OBJECT

      assert(t.randomize()) else $display("Randomization failed ");
      $display("[GEN] : DATA SENT TO DRIVER ");
      t.display();
      mbx.put(t.copy);  //VALUES
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

    g.t=err; // will send an error

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
~~~

## What happened when it ran

The saved Riviera run stopped during compilation with 1 error and 0 warnings: `Member "copy" not found in "t"` at `testbench.sv:39`. No runtime stimulus was generated. The second defect—the `t = new()` overwrite—was found by source tracing and would remain after only restoring `copy()`.

## Points to remember

- A base-class handle can reference a derived object.
- A later base-class `new()` assignment discards that derived object from the handle.
- Copy/clone policy should preserve both values and dynamic type when polymorphic error injection depends on them.
- Fix the first compiler error, then continue tracing runtime object identity; compilation success alone would not make this test correct.
- The environment still needs a monitor and scoreboard before it can verify DUT behavior.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera class handles/copy material](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) · [Accellera SystemVerilog interfaces paper](https://www.accellera.org/images/eda/sv-bc/att-10226/Interfaces_Future.pdf) · [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html)
