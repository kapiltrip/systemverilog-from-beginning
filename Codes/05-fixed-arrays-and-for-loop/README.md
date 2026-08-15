# Part 05 — Fixed arrays and `for` loops

EDA Playground: [https://edaplayground.com/x/8k9Q](https://edaplayground.com/x/8k9Q)

This part introduces unpacked arrays, whole-array display with `%p`, initialization patterns, and procedural population using a `for` loop.

## Answers and notes

- `int arr[10]` declares a fixed-size unpacked array with ten elements indexed from 0 through 9.
- `%0p` prints an aggregate such as an array in a readable form. `$size(arr)` returns its element count.
- Assignment-pattern syntax uses an apostrophe: `'{1, 2, 3, 4, 5}`.
- `'{5{1'b0}}` repeats the value five times; `'{default: 2}` supplies a value for every otherwise unspecified element.
- A dynamic array declared as `int arr[]` must be sized with `new[n]` before assigning individual indices. It can also receive an assignment from a compatible array value that determines its size.
- A `for` loop is appropriate when the index, limit, and increment are explicit. `foreach` is usually safer when the goal is to visit every legal array index.

