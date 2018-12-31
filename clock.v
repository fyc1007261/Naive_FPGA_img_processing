module clock_frequency_transfer(
	CLOCK_50M, clk_25M
);

input CLOCK_50M;
reg clk_25M;
output clk_25M;

always@(posedge(CLOCK_50M))
	begin
		clk_25M <= ~clk_25M;
	end


endmodule
