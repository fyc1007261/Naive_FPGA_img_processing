module img_process(
	input reset,
	input sw0,
	input sw1,
	input sw2,
	input sw3,
	input sw4,
	input reverse_key,
	input clk,
	output HS,
	output VS,
	output reg[7:0] VGA_R,
	output reg[7:0] VGA_G,
	output reg[7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output reg led9
);


parameter integer size = 100;

wire[9:0] Hcnt;
wire[9:0] Vcnt;

wire[23:0] pixel;
wire[23:0] pixel_1;
wire[23:0] pixel_2;
wire[23:0] pixel_3;
wire[23:0] pixel_4;
wire[23:0] pixel_6;
wire[23:0] pixel_7;
wire[23:0] pixel_8;
wire[23:0] pixel_9;


wire[7:0] red_raw;
wire[7:0] green_raw;
wire[7:0] blue_raw;



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


rom img_rom(size*(Vcnt-200)+(Hcnt-200), ~clk_25M, pixel);

rom img_rom_2(size*(Vcnt-200)-size+(Hcnt-200), ~clk_25M, pixel_2);

rom img_rom_4(size*(Vcnt-200)-1+(Hcnt-200), ~clk_25M, pixel_4);

rom img_rom_6(size*(Vcnt-200)+1+(Hcnt-200), ~clk_25M, pixel_6);

rom img_rom_8(size*(Vcnt-200)+size+(Hcnt-200), ~clk_25M, pixel_8);


assign red_raw =  pixel[23:16];

assign green_raw =  pixel[15:8];

assign blue_raw  =  pixel[7:0];


parameter integer threshold = 128;


reg[7:0] grey;
reg[7:0] grey_2;
reg[7:0] grey_4;
reg[7:0] grey_6;
reg[7:0] grey_8;

reg status;
reg view_state;
reg[15:0] key_count;

always @(negedge clk_25M)
begin

if (status && !reverse_key) begin
            key_count = key_count + 1;
            if (key_count == 60000) begin
                key_count = 0;
                status = ~status;
            end
        end else if (!status && reverse_key) begin
            key_count = key_count + 1;
            if (key_count == 60000) begin
                key_count = 0;
                status = ~status;
					 view_state = ~view_state;
            end
        end else begin
            key_count = 0;
        end



if ((Hcnt<300) && (Vcnt<300) && (Hcnt>=200) && (Vcnt>=200))
	begin
		// inside the block
		VGA_R = red_raw;
		VGA_G = green_raw;
		VGA_B = blue_raw;
		if (sw0 == 1 || sw1 == 1 || sw2 == 1 || sw3 == 1 || sw4 ==1)
		begin
			grey = (299 * red_raw + 587 * green_raw + 114 * blue_raw) / 1000;
			if (grey > threshold)
			begin
				VGA_R = 8'd255;
				VGA_G = 8'd255;
				VGA_B = 8'd255;
			end
			else
			begin
				VGA_R = 8'd0;
				VGA_G = 8'd0;
				VGA_B = 8'd0;
			end
			if (sw1 == 1)
			begin
				VGA_R = grey;
				VGA_G = grey;
				VGA_B = grey;
			end
		end
		if (sw2 == 1)
		begin
			grey = (299 * red_raw + 587 * green_raw + 114 * blue_raw) / 1000;
			
			grey_2 = (299 * pixel_2[23:16] + 587 * pixel_2[15:8] + 114 * pixel_2[7:0]) / 1000;
			grey_4 = (299 * pixel_4[23:16] + 587 * pixel_4[15:8] + 114 * pixel_4[7:0]) / 1000;
			grey_6 = (299 * pixel_6[23:16] + 587 * pixel_6[15:8] + 114 * pixel_6[7:0]) / 1000;
			grey_8 = (299 * pixel_8[23:16] + 587 * pixel_8[15:8] + 114 * pixel_8[7:0]) / 1000;
			
			grey = 4* grey - (grey_2+  grey_4+ grey_6+ grey_8);
			
			if (grey > 50) grey = 255;
			else grey = 0;
			
			VGA_R = grey;
			VGA_G = grey;
			VGA_B = grey;
		end
		
		if (sw3 == 1)
		begin
			grey = (299 * red_raw + 587 * green_raw + 114 * blue_raw) / 1000;
			
			grey_2 = (299 * pixel_2[23:16] + 587 * pixel_2[15:8] + 114 * pixel_2[7:0]) / 1000;
			grey_8 = (299 * pixel_8[23:16] + 587 * pixel_8[15:8] + 114 * pixel_8[7:0]) / 1000;
			
			grey = 2* grey - (grey_2+grey_8);
			
			if (grey > 50) grey = 255;
			else grey = 0;
			
			VGA_R = grey;
			VGA_G = grey;
			VGA_B = grey;
		end
		
		if (sw4 == 1)
		begin
			grey = (299 * red_raw + 587 * green_raw + 114 * blue_raw) / 1000;
			
			grey_4 = (299 * pixel_4[23:16] + 587 * pixel_4[15:8] + 114 * pixel_4[7:0]) / 1000;
			grey_6 = (299 * pixel_6[23:16] + 587 * pixel_6[15:8] + 114 * pixel_6[7:0]) / 1000;
			
			grey = 2* grey - (grey_4+grey_6);
			
			if (grey > 50) grey = 255;
			else grey = 0;
			
			VGA_R = grey;
			VGA_G = grey;
			VGA_B = grey;
		end
		if (view_state == 1)
		begin
			VGA_R = 8'd255 - VGA_R;
			VGA_G = 8'd255 - VGA_G;
			VGA_B = 8'd255 - VGA_B;
		end
	end
	
	else
	begin
		// outside the block
		VGA_R = 8'd255;
		VGA_G = 8'd255;
		VGA_B = 8'd255;
	end
	
	
	
end


endmodule



