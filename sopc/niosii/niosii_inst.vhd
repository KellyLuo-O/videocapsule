	component niosii is
		port (
			clk_clk                                     : in  std_logic                     := 'X';             -- clk
			colorimetrie_0_inputs_outputs_clk_pixel     : in  std_logic                     := 'X';             -- clk_pixel
			colorimetrie_0_inputs_outputs_synchro_trame : in  std_logic                     := 'X';             -- synchro_trame
			colorimetrie_0_inputs_outputs_b             : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- b
			colorimetrie_0_inputs_outputs_g             : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- g
			colorimetrie_0_inputs_outputs_r             : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- r
			colorimetrie_0_inputs_outputs_pixel_address : out std_logic_vector(18 downto 0);                    -- pixel_address
			colorimetrie_0_inputs_outputs_pixel_value   : out std_logic_vector(8 downto 0);                     -- pixel_value
			colorimetrie_0_inputs_outputs_ram_we        : out std_logic;                                        -- ram_we
			pio_0_external_connection_export            : out std_logic_vector(7 downto 0);                     -- export
			reset_reset_n                               : in  std_logic                     := 'X'              -- reset_n
		);
	end component niosii;

	u0 : component niosii
		port map (
			clk_clk                                     => CONNECTED_TO_clk_clk,                                     --                           clk.clk
			colorimetrie_0_inputs_outputs_clk_pixel     => CONNECTED_TO_colorimetrie_0_inputs_outputs_clk_pixel,     -- colorimetrie_0_inputs_outputs.clk_pixel
			colorimetrie_0_inputs_outputs_synchro_trame => CONNECTED_TO_colorimetrie_0_inputs_outputs_synchro_trame, --                              .synchro_trame
			colorimetrie_0_inputs_outputs_b             => CONNECTED_TO_colorimetrie_0_inputs_outputs_b,             --                              .b
			colorimetrie_0_inputs_outputs_g             => CONNECTED_TO_colorimetrie_0_inputs_outputs_g,             --                              .g
			colorimetrie_0_inputs_outputs_r             => CONNECTED_TO_colorimetrie_0_inputs_outputs_r,             --                              .r
			colorimetrie_0_inputs_outputs_pixel_address => CONNECTED_TO_colorimetrie_0_inputs_outputs_pixel_address, --                              .pixel_address
			colorimetrie_0_inputs_outputs_pixel_value   => CONNECTED_TO_colorimetrie_0_inputs_outputs_pixel_value,   --                              .pixel_value
			colorimetrie_0_inputs_outputs_ram_we        => CONNECTED_TO_colorimetrie_0_inputs_outputs_ram_we,        --                              .ram_we
			pio_0_external_connection_export            => CONNECTED_TO_pio_0_external_connection_export,            --     pio_0_external_connection.export
			reset_reset_n                               => CONNECTED_TO_reset_reset_n                                --                         reset.reset_n
		);

