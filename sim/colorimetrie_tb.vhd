library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity colorimetrie_tb is
end entity colorimetrie_tb;


architecture tb of colorimetrie_tb is
    constant CLK_PERIOD : time := 20 ns;

    signal tb_address : std_logic_vector(1 downto 0);
	signal tb_writedata : std_logic_vector(31 downto 0);
	signal tb_R : std_logic_vector(7 downto 0);
	signal tb_G : std_logic_vector(7 downto 0);
	signal tb_B : std_logic_vector(7 downto 0);
	signal tb_clk_pixel : std_logic;
	signal tb_synchro_trame : std_logic;
		
	signal tb_cs : std_logic;
	signal tb_wr : std_logic;
	signal tb_rd : std_logic;
	signal tb_reset : std_logic;
	signal tb_clk : std_logic;
		
	signal tb_readdata : std_logic_vector(31 downto 0);
begin 

    -- Processus de génération de clock
    clk_process : process
    begin
        for i in 0 to 10000 loop
            tb_clk <= '0';
            wait for CLK_PERIOD / 2;  -- moitié de la période
            tb_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    uut : entity work.colorimetrie
    port map
    (
        address => tb_address,
        writedata => tb_writedata,
        R => tb_R,
        G => tb_G,
        B => tb_B,
        clk_pixel => tb_clk_pixel,
        synchro_trame => tb_synchro_trame,
        cs => tb_cs,
        wr => tb_wr,
        rd => tb_rd,
        reset => tb_reset,
        clk => tb_clk,
        readdata => tb_readdata
    );

    process 
    begin 

    tb_reset <= '0';
    tb_cs <= '1';
    wait for 10 ns;

    -- envoie de pixel
    for i in 0 to 5 loop 
        tb_wr <= '1';
        tb_R <= x"01";
        tb_G <= x"02";
        tb_B <= x"03";
        tb_clk_pixel <= '1';
        wait for 20 ns;
        tb_clk_pixel <= '0';
        wait for 20 ns;
    end loop;

    -- lecture des moyennese RGB
    tb_wr <= '0';
    tb_rd <= '1';
    tb_address <= "01";
    wait for 20 ns;
    tb_address <= "10";
    wait for 20 ns;
    tb_address <= "11";
    wait for 20 ns;

    -- synchro_trame ==> remise à 0 des signaux
    tb_wr <= '1';
    tb_rd <= '0';
    tb_synchro_trame <= '1';
    tb_clk_pixel <= '1';
    wait for 20 ns;
    tb_clk_pixel <= '0';
    wait for 20 ns;
    tb_synchro_trame <= '0';

    -- lecture des moyennes RGB , à 0 parce que remise à niveau des signaux avant
    tb_wr <= '0';
    tb_rd <= '1';
    tb_address <= "01";
    wait for 20 ns;
    tb_address <= "10";
    wait for 20 ns;
    tb_address <= "11";
    wait for 20 ns;

    wait for 100000 ns;

    end process; 

end architecture tb;