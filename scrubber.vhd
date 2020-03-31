----------------------------------------------------------------------------------------------------
-- Engineer: T�th �d�m Raymond
-- Advisor: Dr. Horv�th P�ter

-- University: Budapesti M�szaki �s Gazdas�gtudom�nyi Egyetem
-- Faculty: Villamosm�rn�ki �s Informatikai Kar
-- Department: Elektronikus Eszk�z�k Tansz�k

-- Semester: 2019/20/2

-- Design Name: �jrafelhaszn�lhat� mem�riamodul nagymegb�zhat�s�g� rendszerekhez
-- Module Name:

-- Description: 

----------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.header_scrubber.all;


entity scrubber is
    generic(
        dummy : boolean := true;
        prescaler_size: integer := 17;
        timer_size: integer := 9
    );
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        force : in std_logic;
        busy : out std_logic;
        address : out STD_LOGIC_VECTOR (0 downto 0)
    );
end scrubber;

architecture rtl of scrubber is

    signal pointer: std_logic_vector(0 downto 0);

    signal input_idle: std_logic;
    signal wakeup: std_logic;

begin

L_SCRUBBER: if dummy = false generate

    L_SCRUBBER_COUNTER: entity work.counter(rtl)
        generic map(
            prescaler_size => prescaler_size,
            timer_size => timer_size
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            input_idle => input_idle,
            force => force,
            wakeup => wakeup
        );



end generate L_SCRUBBER;

L_DUMMY: if dummy = true generate
    
    busy <= '0';
    address <= (others => '0');

end generate L_DUMMY;

end rtl;
