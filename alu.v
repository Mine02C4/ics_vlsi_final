`include "define.h"

module alu
  (
    input [31:0] a, b, 
    input [2:0] alucont, 
    output [31:0] result
  );

  wire [31:0] b2, sum, slt;

  assign b2 = alucont[2] ? ~b:b; 
  assign sum = a + b2 + alucont[2];
  // slt should be 1 if most significant bit of sum is 1
  assign slt = sum[31:0];

  assign result = alumux(a, b, alucont, sum, slt);

  function [31:0] alumux;
    input [31:0] a, b; 
    input [1:0] alucont;
    input [31:0] sum, slt;
    case (alucont)
      2'b00: alumux = a & b;
      2'b01: alumux = a | b;
      2'b10: alumux = sum;
      2'b11: alumux = slt;
    endcase
  endfunction
endmodule

module alucontrol
  (
    input [1:0] aluop, 
    input [5:0] funct, 
    output [2:0] alucont
  );

  assign alucont = alumux(aluop, funct);

  function [31:0] alumux;
    input [1:0] aluop;
    input [5:0] funct;
    case(aluop)
      2'b00: alumux = 3'b010;  // add for lb/sb/addi
      2'b01: alumux = 3'b110;  // sub (for beq)
      default: case(funct)       // R-Type instructions
        6'b100000: alumux = 3'b010; // add (for add)
        6'b100010: alumux = 3'b110; // subtract (for sub)
        6'b100100: alumux = 3'b000; // logical and (for and)
        6'b100101: alumux = 3'b001; // logical or (for or)
        6'b101010: alumux = 3'b111; // set on less (for slt)
        default:   alumux = 3'b101; // should never happen
      endcase
    endcase
  endfunction
endmodule

