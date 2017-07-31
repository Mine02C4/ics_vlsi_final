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

// Fetch
  wire [31:0] instr_F, instr_D;
  wire [31:0] pc_F, pc_D, pc_E;
  wire [31:0] pc_from_alu;
  reg [31:0] pc;
  assign imem_addr = pc;
  assign pc_F = pc;
  assign pc_from_alu = aluresult_W;

  fetch_decode_clk fdclk (clk, reset,
      instr_F, pc_F,
      instr_D, pc_D
    );

// Decode
  wire [31:0] rdata1_D, rdata1_E;
  wire [31:0] rdata2_D, rdata2_E;
  wire [2:0] alucont_D, alucont_E;
  wire alusrca_D, alusrca_E;
  wire [1:0] alusrcb_D, alusrcb_E;
  wire [15:0] imm_D, imm_E;
  wire [2:0] ra1, ra2;
  wire [2:0] reg_addr_D, reg_addr_E, reg_addr_W;
  wire [3:0] state_D, state_E;
  decoder dec1(instr_D, alucont_D, imm_D, alusrca_D, alusrcb_D, state_D);
  regfile rf1(clk, reg_write_W, ra1, ra2, 3'b0, 32'b0, rdata1_D, rdata2_D);

  decode_execute_clk declk (clk, reset,
      imm_D, pc_D, alucont_D, rdata1_D, rdata2_D, reg_addr_D, state_D,
      imm_E, pc_E, alucont_E, rdata1_E, rdata2_E, reg_addr_E, state_E
    );


// Execute
  wire [31:0] aluresult_E, aluresult_W;
  wire mem_write_E, mem_write_W;
  wire reg_write_E, reg_write_W;
  wire reg_src_E, reg_src_W;
  wire pc_src_E, pc_src_W;
  executor exec1(alucont_E, pc_E, rdata1_E, rdata2_E, imm_E, alusrca_E, alusrcb_E, aluresult_E);
  state_to_control stc1(state_E, mem_write_E, reg_write_E, reg_src_E);

  execute_write_clk ewclk(clk, reset,
      aluresult_E, reg_addr_E, mem_write_E, reg_write_E, reg_src_E,
      aluresult_W, reg_addr_W, mem_write_W, reg_write_W, reg_src_W
    );

// Write
  wire [2:0] reg_addr_W;

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
    input [31:0] pc_F,
    output reg [31:0] instr_D,
    output reg [31:0] pc_D
  );
  always @(posedge clk) begin
    if (reset) begin
      instr_D <= 0;
      pc_D <= 0;
    end else begin
      instr_D <= instr_F;
      pc_D <= pc_F;
    end
  end
endmodule

module decode_execute_clk
  (
    input clk, reset,
    input [15:0] imm_D,
    input [31:0] pc_D,
    input [2:0] alucont_D,
    input [31:0] rdata1_D,
    input [31:0] rdata2_D,
    input [2:0] reg_addr_D,
    input [3:0] state_D,
    output reg [15:0] imm_E,
    output reg [31:0] pc_E,
    output reg [2:0] alucont_E,
    output reg [31:0] rdata1_E,
    output reg [31:0] rdata2_E,
    output reg [2:0] reg_addr_E,
    output reg [3:0] state_E
  );
  always @(posedge clk) begin
    if (reset) begin
      imm_E <= 0;
      pc_E <= 0;
      alucont_E <= 0;
      rdata1_E <= 0;
      rdata2_E <= 0;
      reg_addr_E <= 0;
    end else begin
      imm_E <= imm_D;
      pc_E <= pc_D;
      alucont_E <= alucont_D;
      rdata1_E <= rdata1_D;
      rdata2_E <= rdata2_D;
      reg_addr_E <= reg_addr_D;
    end
  end
endmodule

module execute_write_clk
  (
   input clk, reset,
   input [31:0] aluresult_E,
   input [2:0] reg_addr_E,
   input mem_write_E,
   input reg_write_E,
   input reg_src_E,
   input pc_src_E,
   output reg [31:0] aluresult_W,
   output reg [2:0] reg_addr_W,
   output reg mem_write_W,
   output reg reg_write_W,
   output reg reg_src_W,
   output reg pc_src_W
  );
  always @(posedge clk) begin
    if (reset) begin
      aluresult_W <= 0;
      reg_addr_W <= 0;
      mem_write_W <= 0;
      reg_write_W <= 0;
      reg_src_W <= 0;
      pc_src_W <= 0;
    end else begin
      aluresult_W <= aluresult_E;
      reg_addr_W <= reg_addr_E;
      mem_write_W <= mem_write_E;
      reg_write_W <= reg_write_E;
      reg_src_W <= reg_src_E;
      pc_src_W <= pc_src_E;
    end
  end
endmodule


