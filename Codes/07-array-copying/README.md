# Part 07 — Whole-array copying

EDA Playground: [https://edaplayground.com/x/CafY](https://edaplayground.com/x/CafY)
EDA Playground Name: `Whole-Array Copying`

This part fills a fixed array, copies it into another fixed array, demonstrates that the destination has independent storage, and then continues with dynamic-array resizing and copying into a fixed array.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Corrected self-checking source

The deterministic verification version is rendered here and remains available as [`self_checking_testbench.sv`](self_checking_testbench.sv). The exact captured EDA Playground source is preserved separately in [`testbench.sv`](testbench.sv). The `#1` delays separate the setup, fixed-array copy, mutation, dynamic-array resize, and dynamic-to-fixed copy phases so the transitions are visible in a waveform.

~~~systemverilog
// Code your testbench here
// or browse Examples
// Whole-array assignment copies values into a separate fixed-size array.
`timescale 1ns/1ps

module tb;
  int arr1[5];
  int arr2[5];
  int dynamic_arr[];
  int arrfixed[30];
  int status;
  int error_count;

  task automatic check_element(
    input string label,
    input int index,
    input int actual,
    input int expected
  );
    if (actual !== expected) begin
      error_count++;
      $error("FAIL: %s[%0d] expected %0d, got %0d", label, index, expected, actual);
    end
  endtask

  initial begin
    $timeformat(-9, 0, " ns", 8);
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    error_count = 0;
    status = 0;

    // Populate arr1 and make arr2 visibly different before the copy.
    for (int i = 0; i < $size(arr1); i++) begin
      arr1[i] = 5 * i;
      arr2[i] = -1;
    end
    $display("[%0t] arr1 before copy: %0p", $time, arr1);
    $display("[%0t] arr2 before copy: %0p", $time, arr2);

    #1;
    arr2 = arr1;
    status = (arr1 == arr2);
    $display("[%0t] arr2 after whole-array copy: %0p", $time, arr2);

    if (status !== 1) begin
      error_count++;
      $error("FAIL: arrays should compare equal immediately after copying");
    end

    for (int i = 0; i < $size(arr1); i++) begin
      check_element("arr2 after copy", i, arr2[i], arr1[i]);
    end

    #1;
    arr2[2] = 11;
    status = (arr1 != arr2);
    $display("[%0t] arr2 after arr2[2] = 11: %0p", $time, arr2);

    if (status !== 1) begin
      error_count++;
      $error("FAIL: arrays should compare different after arr2[2] changes");
    end

    for (int i = 0; i < $size(arr1); i++) begin
      check_element("arr1 after arr2 mutation", i, arr1[i], 5 * i);
    end
    check_element("arr2 modified element", 2, arr2[2], 11);

    #1;
    dynamic_arr = new[5];
    for (int i = 0; i < dynamic_arr.size(); i++) begin
      dynamic_arr[i] = 5 * i;
    end
    $display("[%0t] dynamic_arr with five elements: %0p", $time, dynamic_arr);
    if (dynamic_arr.size() !== 5) begin
      error_count++;
      $error("FAIL: dynamic_arr should contain five elements");
    end

    #1;
    dynamic_arr = new[30](dynamic_arr);
    $display("[%0t] dynamic_arr after resizing: %0p", $time, dynamic_arr);
    if (dynamic_arr.size() !== 30) begin
      error_count++;
      $error("FAIL: dynamic_arr should contain thirty elements after resizing");
    end
    for (int i = 0; i < 5; i++) begin
      check_element("dynamic_arr preserved element", i, dynamic_arr[i], 5 * i);
    end

    arrfixed = dynamic_arr;
    $display("[%0t] arrfixed after dynamic-array copy: %0p", $time, arrfixed);
    for (int i = 0; i < $size(arrfixed); i++) begin
      check_element("arrfixed copied element", i, arrfixed[i], dynamic_arr[i]);
    end

    if (error_count == 0) begin
      $display("PASS: fixed-array, dynamic-array, and independent-copy checks passed");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 07 self-check failed");
    end

    $finish;
  end
endmodule
~~~

## Preserved EDA Playground source

This block is the captured EDA Playground testbench, including its commented fixed-array experiment and original wording. It is stored unchanged as [`testbench.sv`](testbench.sv); the self-checking code above is the separate corrected verification version.

~~~systemverilog
// Code your testbench here
// or browse Examples
// compare element in scoreboard , golden data + dut response compare elememnt by element and copy used here,
// CONDITION 1 SAME DATA TYPE AND
// CONDITION 2 SAME SIZE
//07
/*
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
*/
module tb;
  int arr[];
  int arrfixed[30];

  initial begin
    arr = new[5];
    //of storing an element
    for(int i =0 ; i<5 ; i++)begin
      arr[i] = 5 * i ;

    end
    $display("the values in the array arr is %0p" , arr ) ;
    $display("the size of array arr is %0d" , arr.size() ) ;

    //arr.delete();
    //why its not having default value printed xxxx cause i deleted and its a 4 state logic

    $display("the values in the array arr is %0p" , arr ) ;
    $display("the size of array arr is %0d" , arr.size() ) ;
   // arr = new [30];
    arr = new [30](arr);
    $display("the values in the array arr is %0p" , arr ) ;

    $display("the size of array arr is %0d" , arr.size() ) ;
    //to store that in fixed size array
    arrfixed = arr ;
    $display("the values in the fixed size array arr is %0p" , arrfixed ) ;

  end
  //have to use new keyword when i want to add elements

endmodule
~~~

## Answers and notes

- `arr2 = arr1` performs whole-array assignment; it is not a reference alias. Later changes to one fixed array do not automatically change the other.
- Changing `arr2[2]` to 11 after the copy demonstrates independence: `arr1[2]` remains 10.
- For fixed unpacked arrays, the source and destination must have assignment-compatible element types and compatible shapes/bounds.
- The two fixed arrays here are both `int [5]`, so the assignment is compatible.
- A dynamic array is sized at run time with `new[n]`. `new[30](dynamic_arr)` resizes it while preserving the existing five values.
- Assigning the resized dynamic array to `arrfixed[30]` copies the values into fixed storage. The destination receives thirty elements because the shapes are compatible.
- Whole-array copying is useful for expected-versus-actual scoreboard data, but comparison is a separate operation. `if (arr1 == arr2)` compares compatible arrays element by element.
- The self-checking testbench uses `error_count`, case-inequality checks for scalar values, and `$fatal(1, ...)` so a simulator run has an unambiguous result.

## Detailed discussion

### Fixed-array assignment is a value copy

After the first loop, `arr1` contains `'{0, 5, 10, 15, 20}` while `arr2` contains `'{-1, -1, -1, -1, -1}`. The statement `arr2 = arr1` copies all five element values into `arr2` in one operation. The arrays remain separate storage objects. Therefore, changing `arr2[2]` from 10 to 11 does not change `arr1[2]`.

This is the snapshot behavior a scoreboard needs when it records expected data before the actual data is modified or processed further. Assignment creates the snapshot; equality or inequality compares the current values.

### Dynamic-array resizing

`dynamic_arr = new[5]` allocates five elements, which are then populated by the loop. The form `new[30](dynamic_arr)` allocates a thirty-element array and copies the old dynamic-array contents into the new object. The first five values remain `0, 5, 10, 15, 20`; the newly added elements are initialized to zero by the simulator used for the saved playground run.

The following assignment then demonstrates compatibility between a thirty-element dynamic array and a thirty-element fixed array:

~~~systemverilog
arrfixed = dynamic_arr;
~~~

The final loop checks every copied element rather than relying only on the printed aggregate.

### Deterministic sequencing

The original handwritten experiment put the comparison in a second `initial` block. Because both blocks start at time 0, that comparison could run before `arr1` was populated or before the copy and mutation completed. The finished version keeps dependent operations in one procedural sequence and uses `#1` delays between visible phases. This makes the waveform and the self-check result repeatable.

### Expected simulation phases

| Time | Phase | Expected observation |
| ---: | --- | --- |
| 0 ns | Fixed-array setup | `arr1` is `'{0, 5, 10, 15, 20}` and `arr2` is `'{-1, -1, -1, -1, -1}`. |
| 1 ns | Fixed-array copy | `arr2 = arr1` makes the arrays equal; the equality check passes. |
| 2 ns | Destination mutation | `arr2[2]` becomes 11 while `arr1[2]` stays 10; independence passes. |
| 3 ns | Dynamic-array setup | `dynamic_arr` has five elements with the same arithmetic pattern. |
| 4 ns | Dynamic-array resize | `dynamic_arr.size()` becomes 30 and the original five values remain. |
| 4 ns | Dynamic-to-fixed copy | `arrfixed = dynamic_arr` completes and all thirty values match. |

The saved EDA Playground run used Riviera-Pro 2025.04 and reported compile success with zero errors and zero warnings. Its output showed the five-element dynamic array, the resized thirty-element array, and the thirty-element fixed-array copy. The local Icarus Verilog 12 installation reports whole-array assignment and comparison as unsupported, so this part requires a simulator with full SystemVerilog unpacked-array support.

### Points to remember

- Whole-array assignment copies values; it does not create an alias.
- Fixed-array assignment requires compatible element types and shapes.
- Dynamic arrays get their size from `new[n]` and can be resized with an initializer.
- A simulator limitation is not automatically a language error; Riviera-Pro verified the saved playground behavior.
