library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fib is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        go     : in  std_logic;
        n      : in  std_logic_vector(5 downto 0);
        result : out std_logic_vector(31 downto 0);
        done   : out std_logic
        );
end fib;

-- TODO: Add your FSMD architecture here.

architecture fsmd of fib is    
	type state_t is (start, init, if_cond, for_loop, delay, complete);
	signal state_r : state_t;
	signal n_r : std_logic_vector(5 downto 0);
	signal x_r : std_logic_vector(31 downto 0);
	signal y_r : std_logic_vector(31 downto 0);
	signal i_r : std_logic_vector(31 downto 0);
	signal temp : std_logic_vector(31 downto 0);
begin
	process(clk, rst)
	begin
		if(rst = '1') then
			state_r <= start;
			result <= (others => '0');
			done <= '0';
		elsif(rising_edge(clk)) then
			case state_r is 
				when start =>
					if(go  = '1') then
						n_r <= n;
						state_r <= init;						
					end if;
				when init =>
					done <= '0';
					x_r <= (others => '0');
					y_r <= std_logic_vector(to_unsigned(1, y_r'length));
					i_r <= std_logic_vector(to_unsigned(2, i_r'length));
					state_r <= if_cond;
				when if_cond =>
					if (n = "000000") then
						result <= x_r;
						state_r <= complete;
					else
						state_r <= for_loop;
					end if;
				when for_loop =>
					if (unsigned(i_r) > unsigned(n_r)) then
						result <= y_r;
						state_r <= complete;
					else
						temp <= std_logic_vector(unsigned(x_r) + unsigned(y_r));
						x_r <= y_r;
						i_r <= std_logic_vector(unsigned(i_r) + 1);
						state_r <= delay;
					end if;
				when delay =>
					y_r <= temp;
					state_r <= for_loop;
				when complete=>
					done <= '1';
					if(go = '0')then
					state_r <= start;
					end if;
			end case;
		end if;
	end process;    
end fsmd;


-- TODO: Complete the FSM+D architecture here. Some signals are provided to
-- speed things up. You only need to connect the FSM and datapath together.

architecture fsm_plus_d of fib is

    signal n_en       : std_logic;
    signal result_en  : std_logic;
    signal result_sel : std_logic;
    signal x_en       : std_logic;
    signal x_sel      : std_logic;
    signal y_en       : std_logic;
    signal y_sel      : std_logic;
    signal i_en       : std_logic;
    signal i_sel      : std_logic;
    signal n_eq_0     : std_logic;
    signal i_le_n     : std_logic;

begin
    U_data : entity work.datapath
	port map(
		clk => clk,
      		rst => rst,
        	n   => n,
        	result => result,
	        n_en => n_en,
        	result_en => result_en,
        	result_sel => result_sel,
        	x_en => x_en,
        	x_sel => x_sel,
        	y_en  => y_en,
        	y_sel => y_sel,
        	i_en => i_en,
        	i_sel => i_sel,
	        n_eq_0 => n_eq_0,
	        i_le_n => i_le_n
		);

    U_fsm : entity work.fsm
	port map(
        	clk => clk,
        	rst => rst,
        	go => go,
        	done => done,
        	n_en => n_en,
        	result_en => result_en,
        	result_sel => result_sel,
        	x_en => x_en,
        	x_sel => x_sel,
        	y_en => y_en,
        	y_sel => y_sel,
        	i_en => i_en,
        	i_sel => i_sel,
        	n_eq_0 => n_eq_0,
        	i_le_n => i_le_n
		);
    
end fsm_plus_d;
