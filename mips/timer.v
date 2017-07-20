`include "define.h"
module timer (
    input [`MEM_ADDR_WIDTH-1:0] addr,
    input [`DATA_WIDTH-1:0] idata,
    input [`DATA_WIDTH-1:0] odata,
    input cs_, input rw_, input clk
    );
    reg [31:0] count;
    reg en;
    wire clear, start, stop;
    assign clear = (cs_ == 0 && rw_ == 0 && addr == 4 && idata == 1);
    assign start = (cs_ == 0 && rw_ == 0 && addr == 4 && idata == 2);
    assign stop  = (cs_ == 0 && rw_ == 0 && addr == 4 && idata == 4);

    always @(posedge clk)
      if (clear) count <= 0;
      else if (en) count <= count + 1;
    always @(posedge clk)
      if (start) en <= `Enable;
      else if (stop) en <= `Disable;
    assign odata =  (addr[1:0] == 0) ? count[7:0] :
                    (addr[1:0] == 1) ? count[15:8] :
                    (addr[1:0] == 2) ? count[23:16] :
                    (addr[1:0] == 3) ? count[31:24] : 0;
endmodule
