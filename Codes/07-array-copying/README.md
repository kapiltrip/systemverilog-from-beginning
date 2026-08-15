# Part 07 — Whole-array copying

EDA Playground: [https://edaplayground.com/x/CafY](https://edaplayground.com/x/CafY)

This is the final open EDA Playground in the captured sequence. It fills one fixed array and copies the complete array into another with one assignment.

## Complete testbench code

The complete source that was run successfully in Riviera-PRO is rendered here and remains available as [`testbench.sv`](testbench.sv).

~~~systemverilog
// Code your testbench here
// or browse Examples
// compare element in scoreboard , golden data + dut response compare elememnt by element and copy used here, 
// CONDITION 1 SAME DATA TYPE AND 
// CONDITION 2 SAME SIZE 
module tb ;
  int arr1[5];
  int arr2[5];
  int status ; 
  
  initial begin
    for(int i =0; i<5 ; i++)begin
      arr1[i]= 5*i ; 
      
    end
    $display("the content of arr1 is %0p" , arr1); 

    arr2= arr1; 
    $display("the content of arr2 is %0p" , arr2); 
    arr2[2] = 11; 
    $display("the content of arr2 is now  %0p" , arr2); 
    
  end
  initial begin
    status = (arr1 !=  arr2 ); 
    $display("The following arrays are : having status as %0d" , status ); // should return true 
    
  end
endmodule
~~~

## Answers and notes

- `arr2 = arr1` performs whole-array assignment; it is not a reference alias. Later changes to one fixed array do not automatically change the other.
- Changing `arr2[2]` to 11 after the copy demonstrates that independence: `arr1[2]` remains 10.
- For fixed unpacked arrays, the source and destination must have assignment-compatible element types and compatible shapes/bounds.
- The two arrays here are both `int [5]` unpacked arrays, so the assignment is compatible.
- Dynamic-array assignment can resize the destination to match the source, so “same size” is specifically the important rule for this fixed-array example rather than a universal rule for every array kind.
- Whole-array copying is useful for expected-versus-actual scoreboard data, but comparison is a separate operation. `if (arr1 == arr2)` can compare compatible arrays element by element.
- Both `initial` blocks start concurrently at time 0, so the current comparison races with array initialization and modification. Put the comparison after the assignments in the first block, or synchronize the second block with an event/delay, to make the result deterministic.

## Detailed discussion

### Whole-array assignment is a value copy

After the loop, `arr1` contains `'{0, 5, 10, 15, 20}`. The statement `arr2 = arr1` copies all five element values into `arr2` in one operation. The arrays remain separate storage objects. Therefore, changing `arr2[2]` from 10 to 11 does not change `arr1[2]`.

This behavior is exactly what a scoreboard needs when it takes a snapshot of expected data before actual data is modified or processed further. Copying and comparison are separate operations: assignment creates the snapshot, while equality or inequality determines whether two current values match.

### Compatibility rules

The two fixed arrays have compatible element types and shapes: both contain five `int` elements. Whole-array assignment is therefore legal in a SystemVerilog simulator with full unpacked-array support. The local Icarus Verilog version used for repository checks does not elaborate this feature, but Riviera-PRO compiled and ran it with zero errors.

### The race between the two `initial` blocks

Both blocks begin at time 0, and there is no event or delay ordering the comparison after the copy and mutation. The simulator may execute the `status` assignment before, during, or after the first block's sequence within the same time slot. A result observed in one run is therefore not a portable guarantee.

A deterministic version keeps the dependent operations in one procedural sequence:

~~~systemverilog
initial begin
  foreach (arr1[i])
    arr1[i] = 5 * i;

  arr2 = arr1;
  $display("equal after copy = %0d", arr1 == arr2);

  arr2[2] = 11;
  status = (arr1 != arr2);
  $display("different after modification = %0d", status);
end
~~~

Alternatively, separate processes can synchronize through an event, mailbox, clocking block, or other explicit handshake. The key rule is that data production must complete before comparison begins.

### Expected deterministic reasoning

1. Populate `arr1` as `'{0, 5, 10, 15, 20}`.
2. Copy it to `arr2`; equality is true.
3. Change `arr2[2]` to 11.
4. `arr1` remains `'{0, 5, 10, 15, 20}`.
5. `arr2` becomes `'{0, 5, 11, 15, 20}`.
6. The inequality comparison is true.

### Points to remember

- Whole-array assignment copies values; it does not create an alias.
- Compatible fixed arrays can be assigned and compared as aggregates.
- Separate `initial` blocks are concurrent and need explicit synchronization when one depends on another.
- A simulator limitation is not automatically a language error; Riviera-PRO verified this example.
