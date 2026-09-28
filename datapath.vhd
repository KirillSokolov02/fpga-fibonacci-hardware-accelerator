library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        n      : in  std_logic_vector(5 downto 0);
        result : out std_logic_vector(31 downto 0);

        n_en       : in std_logic;
        result_en  : in std_logic;
        result_sel : in std_logic;
        x_en       : in std_logic;
        x_sel      : in std_logic;
        y_en       : in std_logic;
        y_sel      : in std_logic;
        i_en       : in std_logic;
        i_sel      : in std_logic;

        n_eq_0 : out std_logic;
        i_le_n : out std_logic
        );
end datapath;

architecture default_arch of datapath is
	signal n_r : std_logic_vector(5 downto 0);
	signal i_r : std_logic_vector(31 downto 0);
	signal x_r : std_logic_vector(31 downto 0);
	signal y_r : std_logic_vector(31 downto 0);
	signal result_r : std_logic_vector(31 downto 0);
	signal zero : std_logic_vector(31 downto 0);
	signal x_mux_out : std_logic_vector(31 downto 0);
	signal y_mux_out : std_logic_vector(31 downto 0);
	signal result_mux_out : std_logic_vector(31 downto 0);
	signal i_mux_out : std_logic_vector(31 downto 0);
	signal i_adder_out : std_logic_vector(31 downto 0);
	signal y_adder_out : std_logic_vector(31 downto 0);
begin
    zero <= (others => '0');
    process(clk,rst) begin
	if(rst = '1') then
	elsif (rising_edge(clk)) then
		if(n_en = '1') then
			n_r <= n;
		end if;
		if(i_en = '1') then
			i_r <= i_mux_out;
		end if;
		if(x_en = '1') then
			x_r <= x_mux_out;
		end if;
		if(y_en = '1') then
			y_r <= y_mux_out;
		end if;
		if(result_en = '1') then
			result_r <= result_mux_out;
		end if;
	end if;
    end process;
	i_mux_out <= i_adder_out when i_sel = '1' else std_logic_vector(to_unsigned(2, i_r'length));
	x_mux_out <= y_r when x_sel = '1' else (others => '0');
	y_mux_out <= y_adder_out when y_sel = '1' else std_logic_vector(to_unsigned(1, y_r'length));
	result_mux_out <= y_r when result_sel = '1' else (others => '0');
	i_adder_out <= std_logic_vector(unsigned(i_r) + 1);
	y_adder_out <= std_logic_vector(unsigned(x_r) + unsigned(y_r));
	n_eq_0 <= '1' when n = "000000" else '0';
	i_le_n <= '1' when (unsigned(n) >= unsigned(i_r)) else '0';
	result <= result_r;
end default_arch;