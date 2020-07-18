library ieee;
use ieee.std_logic_1164.all;

entity root is
    port (
        CLK_100MHz      : in        std_logic;
        HSync           : out       std_logic := '1';
        VSync           : out       std_logic := '0';
        Red             : out       std_logic_vector (2 downto 0) := "000";
        Green           : out       std_logic_vector (2 downto 0) := "000";
        Blue            : out       std_logic_vector (1 downto 0) := "00";
        SevenSegmentEnable: out     std_logic_vector(2 downto 0) := "000"
    );
end root;

architecture behavior of root is
    component clk_wiz_v3_6
        port (
            CLK_100MHz  : in        std_logic;
            CLK_OUT1    : out       std_logic;
            RESET       : in        std_logic;
            LOCKED      : out       std_logic
         );
    end component;
    component VGAController
        port (
            PixelClk    : in        std_logic;
            Color       : in        std_logic_vector (7 downto 0);
            Disable     : in        std_logic;
            HSync       : out       std_logic;
            VSync       : out       std_logic;
            Red         : out       std_logic_vector (2 downto 0);
            Green       : out       std_logic_vector (2 downto 0);
            Blue        : out       std_logic_vector (1 downto 0);
            PixelX      : out       integer;
            PixelY      : out       integer;
            DispEnabled : out       std_logic
        );
    end component;
    component VGATestImageGenerator
        port (
            pixelX      : in        integer;
            pixelY      : in        integer;
            pixelClk    : in        std_logic;
            pixelEna    : in        std_logic;
            color       : out       std_logic_vector(7 downto 0)
        );
    end component;
    
    signal PixelClk: std_logic;
    signal PixelX: integer;
    signal PixelY: integer;
    signal PixelColor: std_logic_vector(7 downto 0);
    signal DisplayEnabled: std_logic;
    signal DisableModule: std_logic := '1';
    signal PLLCoreFreqLocked: std_logic;
begin
    clk_ip_core : clk_wiz_v3_6 port map(
        CLK_100MHz => CLK_100MHz,
        CLK_OUT1 => PixelClk,
        RESET  => '0',
        LOCKED => PLLCoreFreqLocked
    );
    
    controller : VGAController port map(
        PixelClk => PixelClk,
        Color => PixelColor,
        HSync => HSync,
        VSync => VSync,
        Red => Red,
        Green => Green,
        Blue => Blue,
        PixelX => PixelX,
        PixelY => PixelY,
        DispEnabled => DisplayEnabled,
        Disable => DisableModule
    );
    
    imageGenerator : VGATestImageGenerator port map(
        pixelX => PixelX,
        pixelY => PixelY,
        pixelClk => PixelClk,
        pixelEna => DisplayEnabled,
        color => PixelColor
    );
	 
	 SevenSegmentEnable <= "111";
    
    process(PixelClk)
    begin
        if(rising_edge(PixelClk)) then
            if (PLLCoreFreqLocked = '0') then
                DisableModule <= '1';
            elsif(PLLCoreFreqLocked = '1') then
                DisableModule <= '0';
            end if;
        end if;
    end process;
end behavior;