module inv_reg (input a, input clk, output reg y);
	always @(posedge clk)
		y <= ~a;
endmodule
