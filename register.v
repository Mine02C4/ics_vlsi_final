`include "define.h"

module regfile
  #(parameter WIDTH = 8, REGBITS = 3)
  (
    input clk, 
    input regwrite, 
    input  [REGBITS-1:0] ra1, ra2, wa, 
    input  [31:0] wd, 
    output [31:0] rdata1, rdata2
  );

  reg [31:0] RAM [(1<<REGBITS)-1:0];

  always @(posedge clk)
    if (regwrite)
      RAM[wa] <= wd;	

  assign rd1 = ra1 ? RAM[ra1] : 0;
  assign rd2 = ra2 ? RAM[ra2] : 0;
endmodule

