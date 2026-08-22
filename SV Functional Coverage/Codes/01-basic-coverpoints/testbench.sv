`timescale 1ns/1ns

module tb;
    logic [1:0] a;
    logic [1:0] b;
    int error_count = 0;

    top dut (
        .a(a),
        .b(b)
    );

    // With no sampling event in the declaration, sample() is called manually.
    // Each 2-bit coverpoint automatically gets one bin per possible value:
    // 00, 01, 10, and 11.
    covergroup cvr_a;
        option.per_instance = 1;
        coverpoint a;
        coverpoint b;
    endgroup

    cvr_a ci = new();

    initial begin
        $timeformat(-9, 0, " ns", 8);
        a = 2'b00;
        #1;

        for (int i = 0; i < 10; i++) begin
            a = $urandom_range(3, 0);

            // Let the continuous assignment update b before sampling both
            // coverpoints and checking the DUT.
            #1;
            ci.sample();

            if (b !== a) begin
                error_count++;
                $error("Mismatch at %0t: a=%b b=%b", $time, a, b);
            end

            $display("sample=%0d time=%0t a=%b b=%b", i + 1, $time, a, b);
            #9;
        end

        if (error_count == 0) begin
            $display("PASS: all 10 samples propagated correctly; functional coverage was sampled.");
        end else begin
            $fatal(1, "FAIL: %0d propagation errors", error_count);
        end

        $finish;
    end
endmodule
