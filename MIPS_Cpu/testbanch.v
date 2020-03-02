module test();

reg rst,clk = 0;

mips mips(.clk(clk), .rst(rst));

initial begin
	$dumpfile("dump.vcd");
	$dumpvars(0, test);
	$display("clk rst");
	$monitor(" %1d %1d", clk, rst);

	#15 rst=1; #2 rst = 0;

	#40 $finish;
end	

always #1 clk = !clk;	

endmodule
