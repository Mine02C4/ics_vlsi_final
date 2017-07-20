`timescale 1ns/10ps
`include "define.h"
module test ();
  reg [`BUS_ADDR_WIDTH-1:0] addr;
  reg [`DATA_WIDTH-1:0] idata;
  wire [`DATA_WIDTH-1:0] odata;
  reg rw_, breq_;
  wire bgrt_;
  reg [`BUS_ADDR_WIDTH-1:0] dsaddr;
  reg [`BUS_ADDR_WIDTH-1:0] ddaddr;
  reg [1:0] dmode;
  reg dreq_;
  wire eop_;
  reg reset_, clk;
  top u0 (addr, idata, odata, rw_,
      breq_, bgrt_, dsaddr, ddaddr, dmode, dreq_, eop_, reset_, clk);
  always begin
    clk <= 1; #1; clk <= 0; #1;
  end
  initial begin
  #1; $dumpfile("dump.vcd"); $dumpvars(0, test.u0);
  $display("Initialize");
  reset_ <= `Enable_;
  rw_ <= `Write;
  breq_ <= `Disable_;
  addr <= 0; idata <= 0; dsaddr <= 0; ddaddr <= 0; dmode <= 0;
  dreq_ <= `Disable_;
#4;
  reset_ <= `Disable_;
#2;
  breq_ <= `Enable_;
  $display("Directly memory RW test");
  rw_ <= `Write; addr <= 10'h120; idata <= 8'h99; #2;
  rw_ <= `Read; addr <= 10'h120; idata <= 0; #2;

  $display("addr=%h odata=%h cs0_=%b cs1_=%b cs2_=%b",
      addr, odata, u0.u0.cs0_, u0.u0.cs1_, u0.u0.cs2_);
  rw_ <= `Write; addr <= 10'h019; idata <= 8'hf5; #2;
  rw_ <= `Read; addr <= 10'h019; idata <= 0; #2;
  $display("addr=%h odata=%h cs0_=%b cs1_=%b cs2_=%b",
      addr, odata, u0.u0.cs0_, u0.u0.cs1_, u0.u0.cs2_);
  $display("Directly timer test");
  // stop
  rw_ <= `Write; addr <= 10'h204; idata <= 4; #2;
  // clear
  rw_ <= `Write; addr <= 10'h204; idata <= 1; #2;
  // start
  rw_ <= `Write; addr <= 10'h204; idata <= 2; #2;
#100
  rw_ <= `Read; addr <= 10'h200; #2;
  $display("odata(count)=%d cs0_=%b cs1_=%b cs2_=%b",
      odata, u0.u0.cs0_, u0.u0.cs1_, u0.u0.cs2_);
#100
  rw_ <= `Read; addr <= 10'h200; #2;
  $display("odata(count)=%d cs0_=%b cs1_=%b cs2_=%b",
      odata, u0.u0.cs0_, u0.u0.cs1_, u0.u0.cs2_);
  breq_ <= `Disable_;
  $display("DMAC single test");
  dreq_ <= `Enable_;
  dsaddr <= 10'h019; ddaddr <= 10'h150; dmode <= `DMAC_MODE_SINGLE;
#2
  dreq_ <= `Disable_;
#10
  breq_ <= `Enable_;
  rw_ <= `Read; addr <= 10'h150; idata <= 0; #2;
#2
  $display("addr=%h odata=%h eop_=%b state=%d",
      addr, odata, eop_, u0.u2.state);
  $display("DMAC burst test");
  rw_ <= `Write; addr <= 10'h090; idata <= 8'h50; #2;
  rw_ <= `Write; addr <= 10'h091; idata <= 8'h51; #2;
  rw_ <= `Write; addr <= 10'h092; idata <= 8'h52; #2;
  rw_ <= `Write; addr <= 10'h093; idata <= 8'h53; #2;
  breq_ <= `Disable_; dreq_ <= `Enable_;
  dsaddr <= 10'h090; ddaddr <= 10'h120; dmode <= `DMAC_MODE_BURST;
#2
  dreq_ <= `Disable_;
#20
  breq_ <= `Enable_;
  rw_ <= `Read; addr <= 10'h120; idata <= 0; #2;
  $display("addr=%h odata=%h eop_=%b state=%d",
      addr, odata, eop_, u0.u2.state);
  rw_ <= `Read; addr <= 10'h121; idata <= 0; #2;
  $display("addr=%h odata=%h eop_=%b state=%d",
      addr, odata, eop_, u0.u2.state);
  rw_ <= `Read; addr <= 10'h122; idata <= 0; #2;
  $display("addr=%h odata=%h eop_=%b state=%d",
      addr, odata, eop_, u0.u2.state);
  rw_ <= `Read; addr <= 10'h123; idata <= 0; #2;
  $display("addr=%h odata=%h eop_=%b state=%d",
      addr, odata, eop_, u0.u2.state);
  $finish;
  end
endmodule
