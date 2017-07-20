`include "define.h"
module top (
    input [`BUS_ADDR_WIDTH-1:0] addr0,
    input [`DATA_WIDTH-1:0] idata0,
    output [`DATA_WIDTH-1:0] odata0,
    input rw0_, input breq0_, output bgrt0_,
    // Proc -> DMAC
    input [`BUS_ADDR_WIDTH-1:0] dsaddr,
    input [`BUS_ADDR_WIDTH-1:0] ddaddr,
    input [1:0] dmode,
    input dreq_, output eop_,
    input reset_, input clk
    );
  wire [`BUS_ADDR_WIDTH-1:0] addr1;
  wire [`DATA_WIDTH-1:0] idata1;
  wire [`DATA_WIDTH-1:0] odata1;
  wire rw1_, breq1_, bgrt1_;

  wire [`BUS_ADDR_WIDTH-1:0] addr;
  wire [`DATA_WIDTH-1:0] idata;
  wire [`DATA_WIDTH-1:0] odata;
  wire rw_;

  assign odata0 = odata; assign odata1 = odata;
  assign addr = (bgrt0_ == `Enable_) ? addr0 :
                (bgrt1_ == `Enable_) ? addr1 : 0;
  assign idata =  (bgrt0_ == `Enable_) ? idata0 :
                  (bgrt1_ == `Enable_) ? idata1 : 0;
  assign rw_ =  (bgrt0_ == `Enable_) ? rw0_ :
                (bgrt1_ == `Enable_) ? rw1_ : 0;
  slaves u0 (addr, idata, odata, rw_, reset_, clk);
  busarb u1 (breq0_, breq1_, bgrt0_, bgrt1_, reset_, clk);
  dmactr u2 (addr1, idata1, odata1, rw1_, breq1_, bgrt1_,
      dsaddr, ddaddr, dmode, dreq_, eop_, reset_, clk);
endmodule


