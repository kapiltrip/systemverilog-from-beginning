// both read and write high to be handled later
module tb;
  parameter dw = 8;
  parameter aw = 6;

  reg clk = 0;
  reg rst = 0;
  reg wr_en = 0;
  reg rd_en = 0;
  reg [dw-1:0] din = 0;
  wire [dw-1:0] dout;
  wire empty, full;

  sync_fifo #(
    .dw(dw),
    .aw(aw)
  ) dut (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty)
  );

  initial
    repeat (40)
      #5 clk = ~clk;

  task write();
    for (int i = 0; i < 20; i++) begin
      wr_en = 1'b1;
      rd_en = 1'b0;
      din = $urandom();
      @(posedge clk);
      $display("writing a value of din : %0d , and full is %0d , at an address of %0d ", din, full, dut.waddr);
      wr_en = 0;
      @(posedge clk);
    end
  endtask

  task read();
    for (int i = 0; i < 20; i++) begin
      wr_en = 1'b0;
      rd_en = 1'b1;
      din = {dw{1'b0}}; // lol just playing
      @(posedge clk);
      rd_en = 1'b0;
      @(posedge clk);
      $display("reading a value of dout : %0d , and empty is %0d , at an address of %0d ", dout, empty, dut.raddr);
    end
  endtask

  initial begin
    rst = 1;
    wr_en = 0;
    rd_en = 0;
    repeat (5) @(posedge clk);
    rst = 0;
    write();
    read();
  end

  covergroup c @(posedge clk);
    option.per_instance = 1;

    coverpoint empty {
      bins empty_low = {0};
      bins empty_high = {1};
    }

    coverpoint full {
      bins full_low = {0};
      bins full_high = {1};
    }

    coverpoint rst {
      bins rst_low = {0};
      bins rst_high = {1};
    }

    coverpoint wr_en {
      bins wr_en_low = {0};
      bins wr_en_high = {1};
    }

    coverpoint rd_en {
      bins rd_en_low = {0};
      bins rd_en_high = {1};
    }

    coverpoint din {
      bins lower_din = {[0:84]};
      bins mid_din = {[85:169]};
      bins high_din = {[170:255]};
    }

    coverpoint dout {
      bins lower_dout = {[0:84]};
      bins mid_dout = {[85:169]};
      bins high_dout = {[170:255]};
    }

    // now i will use cross coverage cause i want to see them working in a relation not just individually
    cross_wr_en_rst: cross rst, wr_en {
      ignore_bins reset_high = binsof(rst) intersect {1}; // when reset is 1 wr doesnt matter
      ignore_bins wr_en_low = binsof(wr_en) intersect {0}; // when wr_en is 0 ignore
    }

    cross_rd_en_rst: cross rst, rd_en {
      ignore_bins reset_high = binsof(rst) intersect {1}; // when reset is 1 wr doesnt matter
      ignore_bins rd_en_low = binsof(rd_en) intersect {0}; // when wr_en is 0 ignore
    }

    cross_wr_din: cross rst, wr_en, din {
      ignore_bins reset_high = binsof(rst) intersect {1};
      ignore_bins wr_en_low = binsof(wr_en) intersect {0};
    }

    cross_rd_din: cross rst, rd_en, dout {
      ignore_bins reset_high = binsof(rst) intersect {1};
      ignore_bins rd_en_low = binsof(rd_en) intersect {0};
    }

    cross_full_wr: cross rst, wr_en, full {
      ignore_bins full_wr_en = binsof(full) intersect {1}; // full is high, means ignore
      ignore_bins rst_high = binsof(rst) intersect {1};
      ignore_bins wr_en_low = binsof(wr_en) intersect {0};
    }

    cross_empty_rd: cross rst, rd_en, empty {
      ignore_bins empty_rd_en = binsof(empty) intersect {1}; // full is not high
      ignore_bins rst_high = binsof(rst) intersect {1};
      ignore_bins rd_en_low = binsof(rd_en) intersect {0};
    }
  endgroup

  c ci;

  initial begin
    ci = new();
  end
endmodule
