# Part 40 — Interface, Modport, and Virtual Interface

[← Part 39](../39-parameterized-transaction-mailbox/README.md) · [Learning index](../README.md) · [Part 41 →](../41-layered-adder-testbench-and-object-copies/README.md)

| Saved-playground field | Value |
|---|---|
| Original queue label | `010` |
| Indexed EDA name | `SV 40 - Interface, Modport, and Virtual Interface` |
| Stable playground | [VgAA](https://edaplayground.com/x/VgAA) |
| Saved code ID | `7362135` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| EPWave | Enabled in the saved settings |
| Live result | **Pass:** finish at 100 ns |

This part bridges static RTL structure and dynamic class-based verification. The interface bundles `a`, `b`, `sum`, and `clk`; the DUT connects to a concrete interface instance; the class driver stores a virtual-interface reference to that instance.

## Connection map

~~~text
driver object d
  └─ virtual add_interface.DRV aif ──┐
                                     ▼
                               tb.aif() instance
                               ├─ a,b ──> add DUT
                               ├─ clk ──> add DUT
                               └─ sum <── add DUT
~~~

The modport describes the driver's view: it may drive `a` and `b`, while it reads `sum` and `clk`. Directions are relative to the component using the modport, not a universal declaration that changes the underlying interface signal itself.

## Questions from the code, explained

### How does a class communicate with the DUT?

**Question in the source**

> `//INTERFACE : class will communicate with dut how?`

**Answer**

A class cannot contain a concrete module/interface instance because class objects are dynamic software-like objects, while modules and interfaces belong to the static elaborated hierarchy. The top-level module creates `add_interface aif()`. It then assigns that concrete instance into the driver's virtual-interface variable with `d.aif = aif`. The driver dereferences that reference to read and drive signals.

### Does `virtual` here mean method overriding or C++-style polymorphism?

No. In `virtual add_interface.DRV aif`, `virtual interface` is a reference type for a statically instantiated interface. It is not a virtual method and nothing is being overridden. The common word `virtual` serves different language constructs; the declaration's full type determines its meaning.

### Is `add_interface aif()` an instance or a handle?

It is a concrete interface instance in the module hierarchy. The parentheses are the instance's port-connection syntax, even though this interface has no ports. The class member `virtual add_interface.DRV aif` is the handle-like reference. The assignment connects the reference to the concrete instance.

### Should clock initialization use blocking or nonblocking assignment?

For a simple time-zero testbench initialization, blocking `aif.clk = 0` is appropriate and immediately establishes the value in the current procedural flow. Nonblocking assignment is mainly used for clocked sequential state updates. The repeating clock generator also uses blocking assignment after each delay, which is conventional testbench clock generation.

### Are changes between clock ticks ignored?

The interface signal changes are real and visible. The synchronous `add` module samples `a` and `b` only when its `always @(posedge clk)` process runs, so intermediate values that are replaced before the next positive edge do not affect `sum`. After each edge, the nonblocking assignment updates `sum` later in that time slot.

### Is there a race at the positive edge?

Yes. The driver waits for `posedge aif.clk` and then uses blocking assignments to `a` and `b`, while the DUT also samples them on that same edge. Both processes run in the active region, so the DUT may see either the previous or new input values depending on scheduling order. Drive before the sampling edge (for example at the negative edge) or use a clocking block with defined skew to remove this race.

## Design code

~~~systemverilog
// Code your design here
module add(
  input [3:0]a,b,
  output reg [4:0] sum,
  input clk
);
  always @(posedge clk)begin
       sum <= a+b;

  end
endmodule
~~~

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
//INTERFACE : class will communicate with dut how?
interface add_interface;
  logic [3:0] a ; //equivalent logic type defined in interface
  logic [3:0] b;
  logic [4:0] sum;
  logic clk ;
  modport DRV (output a,b,input sum, clk );// A AND B will have o/p direction rest all r inputs

endinterface

  class driver;
    // specific modport restriction we define the input outputs of the driver
    virtual add_interface.DRV aif; //virtual comes under polymorphism like definition will be overridden in the derived class ig in cpp it means that
    task run();
      forever begin
        @(posedge aif.clk);
        aif.a=3;
        aif.b=4;

      end
    endtask
  endclass



  module tb;
    add_interface aif();
    add dut(
      .a(aif.a),
      .b(aif.b),
      .sum(aif.sum),
      .clk(aif.clk)

    );
    initial begin
      aif.clk=0;  // use blockign or non blocking

    end

    always #10 aif.clk = ~aif.clk ;
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      #100;
      $finish();
    end
    //to connect interface with driver in testbench top
    driver d;
    initial begin
      d=new();
      d.aif= aif;
      d.run();
    end
  endmodule











  /*
  module tb;
  add_interface aif(); // bracket is needed when adding instance / is it instance or handler ?
    initial begin
     aif.clk=0;
  end
  always #10 aif.clk = ~aif.clk ;

  add dut(
    .a(aif.a),
    .b(aif.b),
    .sum(aif.sum),
    .clk(aif.clk)
  );

  initial begin
    aif.a<=4;                               // prefer non blocking operator
    aif.b<=4;
    // if input changes b/w clock tick it will be ignored
    repeat (3) @(posedge aif.clk);
    #10;
    aif.a<=7;
    aif.b<=3;
    #10;                        //instead we can use @
    aif.a<=2;
    aif.b<=8;
    #10;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    #100;
    $finish();
    //interface with all reg type then we r not allowed to connect varialbe to the out put of dut
    // to apply using initial block if i declare by reg type
  end
endmodule
*/
~~~

## What happened when it ran

The saved Questa run compiled with 0 errors, simulated to 100 ns, and produced the requested VCD. Its only reported warning was the access-setting optimization warning. The run proves the connection is legal; it does not remove the same-edge sampling race described above.

## Points to remember

- Instantiate an interface statically; reference it virtually from classes.
- A modport controls a component's permitted view and directions.
- Bind every virtual interface before a component dereferences it.
- “Virtual interface” and “virtual method” are different concepts.
- Separate stimulus drive time from DUT sample time or use a clocking block.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera SystemVerilog interfaces paper](https://www.accellera.org/images/eda/sv-bc/att-10226/Interfaces_Future.pdf) · [EDA Playground EPWave/settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html)
