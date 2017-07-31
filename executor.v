`include "define.h"

module executor
  (
    input [2:0] alucont,
    input [31:0] pc,
    input [31:0] rdata1,
    input [31:0] rdata2,
    input [15:0] imm,
    input alusrca,
    input [1:0] alusrcb,
    output [31:0] aluresult
  );
  wire [31:0] srca, srcb;
  assign srca = (alusrca == 1) ? rdata1 : pc;
  assign srcb = srcbmux(alusrcb, rdata2, {{16{imm[15]}}, imm});
  alu alu1(srca, srcb, alucont, aluresult);

  function [31:0] srcbmux;
    input [1:0] alusrcb;
    input [31:0] rdata2;
    input [31:0] sign_ext_imm;
    case (alusrcb)
      2'b00:    srcbmux = rdata2;
      2'b10:    srcbmux = sign_ext_imm;
      default:  srcbmux = 0;
    endcase
  endfunction
endmodule

module state_to_control
  (
    input [3:0] state,
    output mem_write,
    output reg_write,
    output reg_src
  );
  `include "parameter.h"
  assign mem_write = (state == SBWR) ? 1 : 0;
  assign reg_write = (
      (state == LBRD) |
      (state == RTYPEEX) |
      (state == ADDIEX)
      ) ? 1 : 0;
  assign reg_src = (state == LBRD) ? 1 : 0;
endmodule

