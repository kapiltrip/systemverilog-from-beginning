# Part 07 — Whole-array copying

EDA Playground: [https://edaplayground.com/x/CafY](https://edaplayground.com/x/CafY)

This is the final open EDA Playground in the captured sequence. It fills one fixed array and copies the complete array into another with one assignment.

## Answers and notes

- `arr2 = arr1` performs whole-array assignment; it is not a reference alias. Later changes to one fixed array do not automatically change the other.
- Changing `arr2[2]` to 11 after the copy demonstrates that independence: `arr1[2]` remains 10.
- For fixed unpacked arrays, the source and destination must have assignment-compatible element types and compatible shapes/bounds.
- The two arrays here are both `int [5]` unpacked arrays, so the assignment is compatible.
- Dynamic-array assignment can resize the destination to match the source, so “same size” is specifically the important rule for this fixed-array example rather than a universal rule for every array kind.
- Whole-array copying is useful for expected-versus-actual scoreboard data, but comparison is a separate operation. `if (arr1 == arr2)` can compare compatible arrays element by element.
- Both `initial` blocks start concurrently at time 0, so the current comparison races with array initialization and modification. Put the comparison after the assignments in the first block, or synchronize the second block with an event/delay, to make the result deterministic.
