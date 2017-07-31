`timescale 1ns/100ps
`include "define.h"
module test#(parameter WIDTH = 32, REGBITS = 3)
  ();

  reg clk;
  reg reset;
  wire [31:0] imem_data;
  wire [31:0] dmem_data;
  wire [31:0] imem_addr;
  wire [31:0] dmem_addr;
  wire [31:0] write_mem_data;
  wire write_enable;

   // 5nsec --> 200MHz
   parameter STEP = 5.0;

   // instantiate devices to be tested
   //mips #(WIDTH,REGBITS) dut(clk, reset, memdata, memread, memwrite, adr, writedata);
   // mips dut(clk, reset, memdata, memread, memwrite, adr, writedata);
   core core1(clk, reset, imem_data, dmem_data, imem_addr, dmem_addr, write_mem_data, write_enable);

   // external memory for code and data
   exmemory exmem(clk, write_enable, imem_addr, write_mem_data, dmem_addr, imem_data, dmem_data);

   // initialize test
   initial
      begin
         clk <= 0; reset <= 1; # 22; reset <= 0;
         $dumpfile("dump.vcd");
         $dumpvars(0, core1);
         // stop at 1,000 cycles
         #(STEP*10);
         $finish;
      end

  always #(STEP/2) begin
    clk <= ~clk;
  end
  
  always #(STEP)  begin
    $display("pc[%d]", core1.pc);
    $display("pc_src_W[%d]", core1.pc_src_W);
    $display("pc_src_E[%d]", core1.pc_src_E);
    $display("state_E[%d]", core1.state_E);
    $display("alusrca[%d]", core1.exec1.alusrca);
    $display("a[%d]", core1.exec1.alu1.a);
    $display("rdata1_D ra1[%d] [%d]", core1.ra1, core1.rdata1_D);
  end

  always @(negedge clk) begin
    if(write_enable) begin
      $display("Data [%d] is stored in Address [%d]", write_mem_data, dmem_addr);
      if(dmem_addr == 20 & write_mem_data == 7) begin
        $display("Simulation completely successful");
        $finish;
      end else begin
        $display("Simulation failed");
        $finish;
      end
    end
  end
endmodule

// external memory accessed by MIPS
module exmemory
  (clk, write_enable, imem_addr,
   write_mem_data, dmem_addr, imem_data, dmem_data);

  input clk;
  input write_enable;
  input [31:0] imem_addr;
  input [31:0] write_mem_data;
  input [31:0] dmem_addr;
  output [31:0] imem_data;
  output [31:0] dmem_data;

  reg  [31:0] RAM [255:0];
  wire [31:0] word;
  
  assign imem_data = RAM[imem_addr>>2];
  assign dmem_data = RAM[dmem_addr>>2];

  initial
    begin
      $readmemh("mips32test.dat", RAM);
    end

  always @(posedge clk) begin
    if(write_enable) begin
      RAM[dmem_addr>>2][31:0] <= write_mem_data;
    end
  end
endmodule

