library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Unit is
    generic(
        N : integer := 18; -- string of 18 bit
        P : integer := 8; -- # of strings
        A : integer := 3;  --address
        D : integer := 9
    );
    PORT(
        clk, rst, start:    IN std_logic;
        data_out:           OUT std_logic_vector(D-1 DOWNTO 0);
        En_RAM, We_RAM:     OUT std_logic;
        Add_RAM:            OUT std_logic_vector(A-1 DOWNTO 0);
        D_from_RAM:         IN std_logic_vector(N-1 DOWNTO 0);
        D_to_RAM:           OUT std_logic_vector(N-1 DOWNTO 0)
    );
end Unit;

architecture Behavioral of Unit is
    TYPE StateType IS (idle, read,  compute);
    SIGNAL State, NextState : StateType;
    
    SIGNAL inst, instNext : unsigned(1 DOWNTO 0); 
    SIGNAL  cnt, cntNext : unsigned(A DOWNTO 0); 
    SIGNAL  r1, r1Next, r2, r2Next: signed(D-1 DOWNTO 0); 

begin
    CombLogic: PROCESS(State, r1, r2, cnt, inst, start, D_from_RAM) 
    BEGIN
    We_RAM <= '0';
    D_to_RAM <= (OTHERS => '-'); 
        CASE State IS 
            WHEN idle =>
                data_out <= (OTHERS => '0');
                En_RAM <= '0'; 
                r1Next <= (OTHERS => '0');
                r2Next <= (OTHERS => '0');
                cntNext <= (OTHERS => '0');
                instNext <= (OTHERS => '0');
                Add_RAM <= (OTHERS => '0');
                IF(start = '1') THEN 
                    NextState <= read;
                    En_RAM <= '1';
                    Add_RAM <= std_logic_vector(cnt(A-1 downto 0));
                ELSE 
                    NextState <= idle; 
                END IF;
            WHEN read =>
                En_RAM <= '0'; 
                instNext <= unsigned(D_from_RAM(N-1 DOWNTO N-2)); -- da 17 a 16 
                r1Next <= signed(D_from_RAM(N-3) & D_from_RAM(N-3 DOWNTO P ));  -- da 15 a 8 
                r2Next <= signed(D_from_RAM(P-1) & D_from_RAM(P-1  DOWNTO 0));
                NextState <= compute;
                cntNext <= cnt + 1; 
            WHEN compute => 
                En_RAM <= '1'; 
                IF(inst = "00" ) THEN 
                    data_out <= std_logic_vector(r1 + r2);
                ELSIF(inst = "01") THEN
                    data_out <= std_logic_vector(r1 - r2);
                ELSIF(inst = "10") THEN
                    data_out <= std_logic_vector(shift_left(r1, to_integer(abs(r2))));
                ELSIF(inst = "11") THEN -- shift rihgt
                    data_out <= std_logic_vector(shift_right(r1, to_integer(abs(r2))));
                END IF;
                IF(cnt = P) THEN 
                    NextState <= idle; 
                ELSE
                    En_RAM <= '1'; 
                    Add_RAM <= std_logic_vector(cnt(A-1 downto 0));
                    NextState <= read;
                END IF;
            END CASE; 
    END PROCESS;

Regs: PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            State <= idle;
            inst <= (OTHERS => '0');
            cnt <= (OTHERS => '0');
            r1 <= (OTHERS => '0');
            r2 <= (OTHERS => '0');
        ELSIF (rising_edge(clk)) THEN
            State <= NextState;
            inst <= instNext;
            cnt <= cntNext;
            r1 <= r1Next;
            r2 <= r2Next;
        END IF;
    END PROCESS;
end Behavioral;