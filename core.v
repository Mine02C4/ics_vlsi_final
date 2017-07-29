`include "define.h"

module core
  (
    input clk, reset,
    input [31:0] imem_data,
    input [31:0] dmem_data,
    output [31:0] imem_addr,
    output [31:0] dmem_addr,
    output [31:0] write_mem_data,
    output write_enable
  );
  `include "parameter.h"

  wire [31:0] instr_F, instr_D;
  wire [31:0] pc_F, pc_D, pc_E;
  wire [15:0] imm_D, imm_E;

// Fetch
  reg [31:0] pc;
  assign imem_addr = pc_F;

  fetch_decode_clk fdc (clk, reset, instr_F, instr_D);

  alucontrol ac(aluop, instr_D[5:0], alucont);

  always @(posedge clk) begin
    if (reset) begin
      pc <= 0;
    end else begin
      pc <= pc + 4;
    end
  end
endmodule

module fetch_decode_clk
  (
    input clk, reset,
    input [31:0] instr_F,
    output reg [31:0] instr_D
  );
  always @(posedge clk) begin
    if (reset) begin
      instr_D <= 0;
    end else begin
      instr_D <= instr_F;
    end
  end
endmodule

module decode_execute_clk
  (
    input clk, reset,
    input [15:0] imm_D,
    output reg [15:0] imm_E
  );
  always @(posedge clk) begin
    if (reset) begin
      imm_E <= 0;
    end else begin
      imm_E <= imm_D;
    end
  end
endmodule

