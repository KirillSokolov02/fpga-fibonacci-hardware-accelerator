library ieee;
use ieee.std_logic_1164.all;

entity fsm is
    port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        go   : in  std_logic;
        done : out std_logic;

        n_en       : out std_logic;
        result_en  : out std_logic;
        result_sel : out std_logic;
        x_en       : out std_logic;
        x_sel      : out std_logic;
        y_en       : out std_logic;
        y_sel      : out std_logic;
        i_en       : out std_logic;
        i_sel      : out std_logic;

        n_eq_0 : in std_logic;
        i_le_n : in std_logic
        );
end fsm;

architecture default_arch of fsm is    
	type state_t is (restart, start, init, if_cond, for_loop, complete);
	signal state_r : state_t;
	signal next_state : state_t;
	signal n_r : std_logic_vector(5 downto 0);
	signal x_r : std_logic_vector(31 downto 0);
	signal y_r : std_logic_vector(31 downto 0);
	signal i_r : std_logic_vector(31 downto 0);
	signal temp : std_logic_vector(31 downto 0);
begin
	process(clk, rst) begin
		if(rst = '1') then 
			state_r <= start;
		elsif(rising_edge(clk)) then
			state_r <= next_state;
		end if;
	end process;

	process(state_r, go, n_eq_0, i_le_n) begin
        done <= '0';
        n_en <= '0';
        result_en <= '0';
        result_sel<= '0';
        x_en  <= '0';
        x_sel <= '0';
        y_en  <= '0';
        y_sel <= '0';
        i_en  <= '0';
        i_sel  <= '0';
		case state_r is
			when restart =>
				done <= '1';
				result_en <= '0';
				n_en <= '1';
				if(go = '1' ) then
					next_state <= init;
				else
			        next_state <= restart;
				end if;
			when start =>
				result_en <= '0';
				n_en <= '1';
				if(go = '1' ) then
					done <= '0';
					next_state <= init;
			    else
			        next_state <= start;
				end if;
			when init =>
				result_en <= '0';
				--done <= '1';
				x_sel <= '0';
				y_sel <= '0';
				i_sel <= '0';
				i_en <= '1';
				x_en <= '1';
				y_en <= '1';
				next_state <= if_cond;
			when if_cond =>
				if(n_eq_0 = '1') then
					result_sel <= '0';
					result_en <= '1';
					next_state <= complete;
				else
					next_state <= for_loop;
				end if;
			when for_loop =>
				if(i_le_n = '0') then
					result_sel <= '1';
					result_en <= '1';
					next_state <= complete;
				else
					x_sel <= '1';
					i_sel <= '1';
					i_en <= '1';
					x_en <= '1';
					y_sel <= '1';
					y_en <= '1';
					next_state <= for_loop;
					end if;
			when complete =>
				done <= '1';
				if(go = '0')then
					next_state <= restart;
				else
			        next_state <= complete;
				end if;
		end case;
	end process;
end default_arch;