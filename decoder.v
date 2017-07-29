`include "define.h"

module decoder
  (
    input [31:0] instr,
    output  nextstate
  );
  `include "parameter.h"

  wire [OP_WIDTH-1:0] op;
  assign op = instr[INSTR_WIDTH - 1:INSTR_WIDTH - OP_WIDTH];
  assign nextstate = nextstate_mux(op);
  alu_decoder adec (instr[31:26]);

  function [EXMODE_WIDTH - 1:0] nextstate_mux;
    input [OP_WIDTH - 1:0] op;
    case(op)
      LB:      nextstate_mux = MEMADR;
      SB:      nextstate_mux = MEMADR;
      //Added by matutani
      LW:      nextstate_mux = MEMADR;
      SW:      nextstate_mux = MEMADR;
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
    input [5:0] op,
    output  aluop
  );
  `include "parameter.h"
endmodule

