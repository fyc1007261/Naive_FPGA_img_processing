module img_process(
	input reset,
	input sw0,
	input clk,
	output HS,
	output VS,
	output reg[7:0] VGA_R,
	output reg[7:0] VGA_G,
	output reg[7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK
);

wire[9:0] Hcnt;
wire[9:0] Vcnt;

wire[23:0] pixel;
wire[23:0] pixel_last;


clock_frequency_transfer clk_trans(clk, clk_25M);
 
 vga_display screen(
	.clk(clk_25M),//50MHZ
	.reset(reset),
	.Hcnt(Hcnt),
	.Vcnt(Vcnt),
	.hs(HS),
	.vs(VS),
	.blank(VGA_BLANK_N),
	.vga_clk(VGA_CLK)
);


rom img_rom(100*(Vcnt-200)+(Hcnt-200), ~clk_25M, pixel);
rom img_rom_last(100*(Vcnt-200)+1+(Hcnt-200), ~clk_25M, pixel_last);



always @(negedge clk_25M)
begin
	if ((Hcnt<300) && (Vcnt<300) && (Hcnt>=200) && (Vcnt>=200))
	begin
//		VGA_R <= pixel[23:16];
//		VGA_G <= pixel[15:8];
//		VGA_B <= pixel[7:0];
		if (pixel == pixel_last)
		begin
			VGA_R <= 8'd0;
			VGA_G <= 8'd0;
			VGA_B <= 8'd0;
		end
		else
		begin
			VGA_R <= 8'd255;
			VGA_G <= 8'd255;
			VGA_B <= 8'd255;
		end
	end
	else
	begin
		VGA_R <= 8'd0;
		VGA_G <= 8'd0;
		VGA_B <= 8'd255;
	end
end

endmodule