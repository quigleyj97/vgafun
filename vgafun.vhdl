library ieee;
use ieee.std_logic_1164.all;

-- 640x480@60hz by these params

entity VGAController is
    generic (
        horiz_fp    :   integer     := 16;
        horiz_pulse :   integer     := 96;
        horiz_bp    :   integer     := 48;
        horiz_width :   integer     := 640;
        horiz_pol   :   std_logic   := '0'; -- sync polarity- 0=sync low
        vert_fp     :   integer     := 11;
        vert_pulse  :   integer     := 2;
        vert_bp     :   integer     := 31;
        vert_height :   integer     := 480;
        vert_pol    :   std_logic   := '1' -- sync polarity- 1=sync high
    );
    port (
        PixelClk    : in        std_logic;
        Color       : in        std_logic_vector (7 downto 0);
        Disable     : in        std_logic;
        HSync       : out       std_logic;
        VSync       : out       std_logic;
        Red         : out       std_logic_vector (2 downto 0);
        Green       : out       std_logic_vector (2 downto 0);
        Blue        : out       std_logic_vector (1 downto 0);
        PixelX      : out       integer range 0 to horiz_width;
        PixelY      : out       integer range 0 to vert_height;
        DispEnabled : out       std_logic
    );
end VGAController;

architecture behavior of VGAController is
    constant horiz_period: integer := horiz_width + horiz_fp + horiz_pulse + horiz_bp;
    constant  vert_period: integer := vert_height + vert_fp + vert_pulse + vert_bp;
    
    signal horiz_index: integer range 0 to horiz_period - 1 := 0;
    signal vert_index: integer range 0 to vert_period - 1  := 0;
begin
    process(PixelClk, Disable)
    begin
        PixelX <= 0;
        PixelY <= 0;
        if (rising_edge(PixelClk)) then
            if(Disable = '1') then
                DispEnabled <= '0';
            elsif(Disable = '0') then
                if(horiz_index < horiz_period - 1) then
                    horiz_index <= horiz_index + 1;
                else
                    horiz_index <= 0;
                    if(vert_index < vert_period - 1) then
                        vert_index <= vert_index + 1;
                    else
                        vert_index <= 0;
                    end if;
                end if;
                
                if(horiz_index < horiz_width + horiz_fp or 
                   horiz_index > horiz_width + horiz_fp + horiz_pulse) then
                    HSync <= not horiz_pol;
                else
                    HSync <= horiz_pol;
                end if;
                
                if(vert_index < vert_height + vert_fp or 
                   vert_index < vert_height + vert_fp + vert_pulse) then
                    VSync <= not vert_pol;
                else
                    VSync <= vert_pol;
                end if;
                
                if(horiz_index < horiz_width and vert_index < vert_height) then
                    DispEnabled <= '1';
                    PixelX <= horiz_index;
                    PixelY <= vert_index;
                    Red <= Color(7 downto 5);
                    Green <= Color(4 downto 2);
                    Blue <= Color(1 downto 0);
                else
                    DispEnabled <= '0';
                         PixelX <= 0;
                         PixelY <= 0;
                    Red <= "000";
                    Green <= "000";
                    Blue <= "00";
                end if;
            end if;
        end if;
    end process;
    
end behavior;
