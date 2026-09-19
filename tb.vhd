LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb IS
END tb;

ARCHITECTURE behavior OF tb IS 
    COMPONENT TopLevel
    GENERIC(
        N : integer := 18;
        P : integer := 8;
        A : integer := 3;
        D : integer := 9
    );
    PORT(
        clk, rst, start: IN std_logic;
        data_out: OUT std_logic_vector(9-1 DOWNTO 0)
    );
    END COMPONENT;
        SIGNAL clk_tb : std_logic := '0';
    SIGNAL rst_tb : std_logic := '0';
    SIGNAL start_tb : std_logic := '0';
    SIGNAL data_out_tb : std_logic_vector(8 DOWNTO 0);
    
    CONSTANT clk_period : time := 10 ns;
    
BEGIN

    uut: TopLevel
    GENERIC MAP(
        N => 18,
        P => 8,
        A => 3,
        D => 9
    )
    PORT MAP(
        clk => clk_tb,
        rst => rst_tb,
        start => start_tb,
        data_out => data_out_tb
    );
    
    clk_process :process
    begin
            clk_tb <= '0';
            wait for clk_period/2;
            clk_tb <= '1';
            wait for clk_period/2;
    end process;
    
    stim_proc: process
    begin	
        rst_tb <= '1';	        
        wait for 20 ns;
        rst_tb <= '0';
        WAIT for 2 ns; 
        wait for 20 ns;
        
        start_tb <= '1';
        wait for clk_period;
        start_tb <= '0';

        wait for clk_period;
        -- r1 = 01111111 + r2 = 00000001 (127+1=128)
        assert to_integer(signed(data_out_tb)) = 128
        report "Mismatch in output! Expected: 128, Got: " & integer'image(to_integer(signed(data_out_tb))) severity error;
        -- r1 = -128 + r2 = -1 (-128-1=-129)
        wait on data_out_tb;
        assert to_integer(signed(data_out_tb)) = -129
        report "Mismatch in output! Expected: -129, Got: " & integer'image(to_integer(signed(data_out_tb))) severity error;

        -- r1= 127 - r2 = -128 (127 - (-128) = 255)
        wait on data_out_tb;
        assert to_integer(signed(data_out_tb)) = 255
        report "Mismatch in output! Expected: 255, Got: " & integer'image(to_integer(signed(data_out_tb))) severity error;

        -- r1= -128 - r2 = 1 (-128 - 1 = -129)
        wait on data_out_tb;
        assert to_integer(signed(data_out_tb)) = -129
        report "Mismatch in output! Expected: -129, Got: " & integer'image(to_integer(signed(data_out_tb))) severity error;
        
        -- r1 = 01000000 << 1 = 0 1000 0000
        wait on data_out_tb;
        assert to_integer(unsigned(data_out_tb)) = 128
        report "Mismatch in output! Expected: 128, Got: " & integer'image(to_integer(unsigned(data_out_tb))) severity error;


        -- r1 = 00000010 << 7 = 100000000

        wait on data_out_tb;
        assert to_integer(signed(data_out_tb)) = -256
        report "Mismatch in output! Expected: -256, Got: " & integer'image(to_integer(signed(data_out_tb))) severity error;

        -- r1 = 10000000  >> 3 = 111110000
        wait on data_out_tb;
        assert to_integer(signed(data_out_tb)) = -16
        report "Mismatch in output! Expected: -16, Got: " & integer'image(to_integer(signed(data_out_tb))) severity error;

        -- r1 = 01111111  >> 8 = 000000000
        wait on data_out_tb;
        assert to_integer(signed(data_out_tb)) = 0
        report "Mismatch in output! Expected: 0, Got: " & integer'image(to_integer(signed(data_out_tb))) severity error;

        wait;
    end process;

END behavior;
