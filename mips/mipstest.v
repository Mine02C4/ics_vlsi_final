//-------------------------------------------------------
// mips.v
// Max Yi (byyi@hmc.edu) and David_Harris@hmc.edu 12/9/03
// Model of subset of MIPS processor described in Ch 1
//-------------------------------------------------------
`timescale 1ns/100ps

// top level design for testing
module top #(parameter WIDTH = 8, REGBITS = 3)();

   reg                 clk;
   reg                 reset;
   wire                memread, memwrite;
   wire    [WIDTH-1:0] adr, writedata;
   wire    [WIDTH-1:0] memdata;

   // 5nsec --> 200MHz
   parameter STEP = 5.0;

   // instantiate devices to be tested
   //mips #(WIDTH,REGBITS) dut(clk, reset, memdata, memread, memwrite, adr, writedata);
   mips dut(clk, reset, memdata, memread, memwrite, adr, writedata);

   // external memory for code and data
   exmemory #(WIDTH) exmem(clk, memwrite, adr, writedata, memdata);

   // initialize test
   initial
      begin
         clk <= 0; reset <= 1; # 22; reset <= 0;
         // dump waveform
         $dumpfile("dump.vcd");
         $dumpvars(0, top.dut);
         // stop at 1,000 cycles
         #(STEP*1000);
         $finish;
      end

   // generate clock to sequence tests
   always #(STEP/2)
      begin
         clk <= ~clk;
      end

   always@(negedge clk)
      begin
         if(memwrite) begin
            $display("Data [%d] is stored in Address [%d]", writedata, adr);
            if(adr == 5 & writedata == 7) begin
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
module exmemory #(parameter WIDTH = 8)
                 (clk, memwrite, adr, writedata, memdata);

   input                  clk;
   input                  memwrite;
   input      [WIDTH-1:0] adr, writedata;
   output reg [WIDTH-1:0] memdata;

   reg  [31:0] RAM [(1<<WIDTH-2)-1:0];
   wire [31:0] word;

   initial
      begin
         $readmemh("mipstest.dat", RAM);
      end

   // read and write bytes from 32-bit word
   always @(posedge clk)
      if(memwrite) 
         case (adr[1:0])
            2'b00: RAM[adr>>2][7:0] <= writedata;
            2'b01: RAM[adr>>2][15:8] <= writedata;
            2'b10: RAM[adr>>2][23:16] <= writedata;
            2'b11: RAM[adr>>2][31:24] <= writedata;
         endcase

   assign word = RAM[adr>>2];
   always @(*)
      case (adr[1:0])
         2'b00: memdata <= word[31:24];
         2'b01: memdata <= word[23:16];
         2'b10: memdata <= word[15:8];
         2'b11: memdata <= word[7:0];
      endcase
endmodule
