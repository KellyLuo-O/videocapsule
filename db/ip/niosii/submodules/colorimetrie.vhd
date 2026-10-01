library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity colorimetrie is 
	port (
		address : in std_logic_vector(1 downto 0);
		writedata : in std_logic_vector(31 downto 0);
		R : in std_logic_vector(7 downto 0);
		G : in std_logic_vector(7 downto 0);
		B : in std_logic_vector(7 downto 0);
		clk_pixel : in std_logic;
		synchro_trame : in std_logic;
		
		cs : in std_logic;
		wr : in std_logic;
		rd : in std_logic;
		reset : in std_logic;
		clk : in std_logic;
		
		readdata : out std_logic_vector(31 downto 0)
		
	);
end colorimetrie;


architecture arch of colorimetrie is 
	constant SUM_MAX : positive := 22848000;
	constant PX_MAX : positive := 89600; 	--320*280
	
	signal sum_r : natural range 0 to SUM_MAX := 0;
	signal sum_g : natural range 0 to SUM_MAX := 0;
	signal sum_b : natural range 0 to SUM_MAX := 0;
	
	signal nb_value_r : natural range 0 to PX_MAX := 0;
	signal nb_value_g : natural range 0 to PX_MAX := 0; 
	signal nb_value_b : natural range 0 to PX_MAX := 0; 
	
begin 
	process(clk, reset)
	begin 
		if (reset = '1') then
			readdata <= (others => '0');
		
		elsif rising_edge(clk) then
			
			if (cs = '1' and rd = '1') then 
				if (address = "01") then 
					if nb_value_r /= 0 then 
						readdata <= std_logic_vector(to_unsigned(sum_r/nb_value_r, 32));
					else 
						readdata <= std_logic_vector(to_unsigned(sum_r, 32));
					end if;
				elsif (address = "10") then 
					if nb_value_g /= 0 then 
						readdata <= std_logic_vector(to_unsigned(sum_g/nb_value_g, 32));
					else 
						readdata <= std_logic_vector(to_unsigned(sum_g, 32));
					end if;
				elsif (address = "11") then 
					if nb_value_b /= 0 then 
						readdata <= std_logic_vector(to_unsigned(sum_b/nb_value_b, 32));
					else 
						readdata <= std_logic_vector(to_unsigned(sum_b, 32));
					end if;
				end if;
			end if;
		
		end if;
	
	end process;
	
	
	process (clk_pixel, reset)
	begin 
	
		if (reset = '1') then
			sum_r <= 0;
			sum_g <= 0;
			sum_b <= 0;
			nb_value_r <= 0;
			nb_value_g <= 0;
			nb_value_b <= 0;
			
		elsif rising_edge(clk_pixel) then 
			if (cs = '1' and wr = '1') then 
						
				if (synchro_trame = '1') then 
					sum_r <= 0;
					sum_g <= 0;
					sum_b <= 0;
					nb_value_r <= 0;
					nb_value_g <= 0;
					nb_value_b <= 0;
				else
					sum_r <= sum_r + to_integer(unsigned(R));
					sum_g <= sum_g + to_integer(unsigned(G));
					sum_b <= sum_b + to_integer(unsigned(B));
					nb_value_r <= nb_value_r + 1;
					nb_value_g <= nb_value_g + 1;
					nb_value_b <= nb_value_b + 1;
				end if;

			end if;
		end if;
	end process;

end architecture arch;