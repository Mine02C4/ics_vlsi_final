`include "define.h"
module dmactr (
    // DMAC -- MEM, IO
    output reg [`BUS_ADDR_WIDTH-1:0] addr,
    output reg [`DATA_WIDTH-1:0] odata,
    input [`DATA_WIDTH-1:0] idata,
    output reg rw_,
    // DMAC -- busarb
    output reg breq_,
    input bgrt_,
    // Proc -> DMAC
    input [`BUS_ADDR_WIDTH-1:0] dsaddr,
    input [`BUS_ADDR_WIDTH-1:0] ddaddr,
    input [1:0] dmode,
    input dreq_, output reg eop_,
    input reset_, input clk
    );
  parameter DMAC_S_WAIT     = 0;
  parameter DMAC_S_READ1    = 1;
  parameter DMAC_S_WRITE1   = 2;
  parameter DMAC_S_COMPLETE = 3;

  reg [1:0] state, nextstate;
  reg [`BUS_ADDR_WIDTH-1:0] count;
  always @(posedge clk) begin
    if (reset_ == `Enable_) begin
      addr <= 0;
      odata <= 0;
      breq_ <= `Disable_;
      eop_ <= `Disable_;
      rw_ <= `Read;
      state <= DMAC_S_WAIT;
      count <= 0;
      nextstate <= DMAC_S_WAIT;
    end else begin
      eop_ <= `Disable_;
      case (state)
        DMAC_S_WAIT:
          if (dreq_ == `Enable_) begin
            breq_ <= `Enable_;
            state <= DMAC_S_READ1;
            count <= 0;
          end
        DMAC_S_READ1:
          if (bgrt_ == `Enable_) begin
            addr <= dsaddr + count;
            rw_ <= `Read;
            odata <= idata;
            state <= DMAC_S_WRITE1;
          end
        DMAC_S_WRITE1: begin
          addr <= ddaddr + count;
          rw_ <= `Write;
          odata <= idata;
          if (dmode == `DMAC_MODE_BURST) begin
            if (count + 1 == `DMAC_BURST_SIZE) begin
              state <= DMAC_S_COMPLETE;
            end else begin
              count <= count + 1;
              state <= DMAC_S_READ1;
            end
          end else
            state <= DMAC_S_COMPLETE;
        end
        DMAC_S_COMPLETE: begin
          eop_ <= `Enable_;
          breq_ <= `Disable_;
          state <= DMAC_S_WAIT;
        end
      endcase
    end
  end
endmodule

