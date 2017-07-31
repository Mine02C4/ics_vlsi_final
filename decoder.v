`include "define.h"

module decoder
  (
    input [31:0] instr,
    output [2:0] alucont,
    output [15:0] imm,
    output alusrca,
    output [1:0] alusrcb,
    output [3:0] nextstate
  );
  `include "parameter.h"

  wire [5:0] op;
  wire [1:0] aluop;
  assign op = instr[31:26];
  assign nextstate = nextstate_mux(op);
  assign imm = instr[15:0];
  alu_decoder adec (nextstate, aluop);
  alucontrol ac1(aluop, instr[5:0], alucont);

  function [EXMODE_WIDTH - 1:0] nextstate_mux;
    input [5:0] op;
    case(op)
      LB:      nextstate_mux = LBRD;
      SB:      nextstate_mux = SBWR;
      //Added by matutani
      LW:      nextstate_mux = LBRD;
      SW:      nextstate_mux = SBWR;
      //
      RTYPE:   nextstate_mux = RTYPEEX;
      BEQ:     nextstate_mux = BEQEX;
      ADDI:    nextstate_mux = ADDIEX;
      J:       nextstate_mux = JEX;
      default: nextstate_mux = FETCH1; // should never happen
    endcase
  endfunction
endmodule

module alu_decoder
  (
    input [3:0] nextstate,
    output [1:0] aluop
  );
  `include "parameter.h"
  assign aluop = aluopmux(nextstate);
  function [1:0] aluopmux;
    input [EXMODE_WIDTH - 1:0] nextstate;
    case(nextstate)
      RTYPEEX:  aluopmux = 2'b10;
      BEQEX:    aluopmux = 2'b01;
      default:  aluopmux = 2'b00;
    endcase
  endfunction
endmodule

