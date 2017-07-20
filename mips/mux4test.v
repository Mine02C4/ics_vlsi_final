`timescale 1ns/10ps
module test ();

reg d0, d1, d2, d3;
reg [1:0] sel;
wire od;

mux4 u0 (d0, d1, d2, d3, sel, od);

initial begin
	$dumpfile("dump.vcd");
	$dumpvars(0, test.u0);
	d0 <= 1; d1 <= 0; d2 <= 1; d3 <= 0;
	sel <= 1; #2;
	$display("d1=%d",od);
	sel <= 2; #2;
	$display("d2=%d",od);
end

endmodule
