`include "define.h"
module addrdec (
    input [`BUS_ADDR_WIDTH-1:0] addr,
    output cs0_, output cs1_, output cs2_, output cs3_);
    assign cs0_ = (addr[`BUS_ADDR_WIDTH-1:8] == 0) ? `Enable_ : `Disable_;
    assign cs1_ = (addr[`BUS_ADDR_WIDTH-1:8] == 1) ? `Enable_ : `Disable_;
    assign cs2_ = (addr[`BUS_ADDR_WIDTH-1:8] == 2) ? `Enable_ : `Disable_;
    assign cs3_ = (addr[`BUS_ADDR_WIDTH-1:8] == 3) ? `Enable_ : `Disable_;
endmodule


