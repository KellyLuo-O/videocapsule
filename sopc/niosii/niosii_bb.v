
module niosii (
	clk_clk,
	colorimetrie_0_inputs_outputs_clk_pixel,
	colorimetrie_0_inputs_outputs_synchro_trame,
	colorimetrie_0_inputs_outputs_b,
	colorimetrie_0_inputs_outputs_g,
	colorimetrie_0_inputs_outputs_r,
	colorimetrie_0_inputs_outputs_pixel_address,
	colorimetrie_0_inputs_outputs_pixel_value,
	colorimetrie_0_inputs_outputs_ram_we,
	pio_0_external_connection_export,
	reset_reset_n);	

	input		clk_clk;
	input		colorimetrie_0_inputs_outputs_clk_pixel;
	input		colorimetrie_0_inputs_outputs_synchro_trame;
	input	[7:0]	colorimetrie_0_inputs_outputs_b;
	input	[7:0]	colorimetrie_0_inputs_outputs_g;
	input	[7:0]	colorimetrie_0_inputs_outputs_r;
	output	[18:0]	colorimetrie_0_inputs_outputs_pixel_address;
	output	[8:0]	colorimetrie_0_inputs_outputs_pixel_value;
	output		colorimetrie_0_inputs_outputs_ram_we;
	output	[7:0]	pio_0_external_connection_export;
	input		reset_reset_n;
endmodule
