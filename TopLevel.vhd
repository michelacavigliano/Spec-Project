LIBRARY ieee; 
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY TopLevel IS
    generic(
        N : integer := 18; -- string of 18 bit
        P : integer := 8; -- number of strings
        A : integer := 3;  -- number of bits of the address
        D : integer := 9
    ); 
    PORT(
        clk, rst, start:   IN std_logic;
        data_out:          OUT std_logic_vector(9-1 DOWNTO 0)
    );
END TopLevel;

ARCHITECTURE Struct OF TopLevel IS 
    COMPONENT Unit IS
    generic(
        N : integer := 18; -- string of 18 bit
        P : integer := 8; -- # of strings
        A : integer := 3;  -- address
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
    END COMPONENT;

    COMPONENT RAM IS
    generic(
        RAM_WIDTH : integer := 8;
        RAM_DEPTH : integer := 18;
        RAM_ADD   : integer := 3;
        INIT_FILE : string := "memory.mem"
    );
    port(
        ADDR : in std_logic_vector(RAM_ADD-1 downto 0);                          
        DIN  : in std_logic_vector(RAM_WIDTH-1 downto 0);                                  
        CLK  : in std_logic;                                                                 
        WE   : in std_logic;                                                                
        EN   : in std_logic;                                                                 
        DOUT : out std_logic_vector(RAM_WIDTH-1 downto 0)                                 
    );
    END COMPONENT;

    SIGNAL En_t, We_t: std_logic;
    SIGNAL Add_t: std_logic_vector(A-1 DOWNTO 0);
    SIGNAL Dout_t: std_logic_vector(N-1 DOWNTO 0);
    SIGNAL Din_t: std_logic_vector(N-1 DOWNTO 0);

    BEGIN 
    Unit1: Unit GENERIC MAP(18, 8, 3, 9) PORT MAP(
        clk => clk,
        rst => rst,
        start => start,
        data_out => data_out,
        En_RAM => En_t,
        We_RAM =>  We_t,
        Add_RAM => Add_t,
        D_from_RAM => Dout_t,
        D_to_RAM => Din_t
    );

    RAM1: RAM GENERIC MAP(18, 8, 3, "memory.mem") PORT MAP(
        ADDR => Add_t,
        DIN => Din_t,
        CLK => clk,
        WE => We_t,
        EN => En_t,
        DOUT => Dout_t
    );
END Struct;