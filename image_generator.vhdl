library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGATestImageGenerator is
    port (
        pixelX: in integer;
        pixelY: in integer;
        pixelClk: in std_logic;
        pixelEna: in std_logic;
        color: out std_logic_vector(7 downto 0)
    );
end VGATestImageGenerator;

architecture behavior of VGATestImageGenerator is
    constant testPatternHeight: integer := 50;
    signal test_signal: integer := 0;
begin
    process(pixelClk, pixelEna)
        variable testColor: std_logic_vector(7 downto 0) := "00000000";
        variable currentHeight: integer;
    begin
        if (pixelEna = '0') then
            color <= (others => '0');
        elsif (rising_edge(pixelClk)) then
            test_signal <= pixelY - 400;
            testColor := std_logic_vector(to_unsigned(pixelX mod 255,8));
                currentHeight := pixelY mod testPatternHeight*2;
            if (currentHeight < testPatternHeight) then
                if (test_signal > 0) then
                    color <= "11100011";
                else
                     color <= testColor;
                end if;
            else
                for i in color'range loop
                    color(i) <= testColor(i);
                end loop;
            end if;
        end if;
    end process;
end behavior;
