# Part 33 — Generator–Driver Completion Event

[← Part 32](../32-event-races-and-triggered-state/README.md) · [Learning index](../README.md) · [Part 34 →](../34-two-way-event-handshake/README.md)

| Saved-playground field | Value |
|---|---|
| Original queue label | `003` |
| EDA Playground Name | `SV 33 - Generator-Driver Completion Event` |
| Stable playground | [J57K](https://edaplayground.com/x/J57K) |
| Saved code ID | `7361613` |
| Simulator | Aldec Riviera Pro 2025.04 |
| Compile / run options | `-timescale 1ns/1ns` / `+access+r` |
| Live result | **Pass:** finishes at 100 ns |

This part separates three responsibilities into concurrent processes: a stimulus generator, a receiver that samples a shared variable, and a controller that ends simulation when generation is complete.

## Execution and data-flow trace

The generator writes `data1` immediately at time 0 and then once every 10 ns. The receiver waits 10 ns before its first read. Because both processes wake at the same timestamps thereafter and use blocking assignments in the same scheduling region, the code has an ordering dependency: the receiver can observe whichever `data1` value exists when its process runs.

The live output exposes this weakness:

- The very first time-0 generated value is never reported by the receiver.
- At 10 ns, the generator's second value is the first received value.
- At 100 ns, the receiver prints the final value again just before the completion controller calls `$finish`.

So `data2 = data1` is not a reliable transaction channel. It is a snapshot of shared mutable state. A mailbox introduced in Parts 37–39 queues every transaction and prevents overwriting before consumption.

## Important corrections

### Is `$urandom()` unsigned if the display shows negative numbers?

`$urandom()` produces a 32-bit unsigned result, but the destination `int data1` is a signed 32-bit variable. When `%0d` interprets a value whose top bit is 1 as signed, it prints a negative decimal number. Use `int unsigned`, `bit [31:0]`, or an unsigned display interpretation when the intent is to view the result as nonnegative.

### What does the event solve?

`e1` communicates completion only. After the loop, `->(e1)` wakes the controller, which prints the completion message and calls `$finish`. It does not guarantee that every generated value was consumed. Completion control and lossless data transport are separate requirements.

## Testbench code

~~~systemverilog
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
~~~

## What happened when it ran

Riviera compiled with 0 errors and 0 warnings. The generator printed ten values, the receiver began with the second generated value, and simulation stopped at 100 ns after the completion event. The final receiver line repeated the last generated value.

## Points to remember

- Shared variables do not queue transactions.
- An event can signal “producer finished” without proving “consumer processed everything.”
- Same-time blocking accesses from parallel processes can be order-dependent.
- A signed destination can make an unsigned random bit pattern print as negative.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera event-variable material](https://www.accellera.org/images/eda/sv-ec/att-0976/01-event.pdf) · [Accellera SystemVerilog 3.1 donation](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf)
