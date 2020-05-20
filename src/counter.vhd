----------------------------------------------------------------------------------------------------
-- Engineer: Tóth Ádám Raymond
-- Advisor: Dr. Horváth Péter

-- University: Budapesti Mûszaki és Gazdaságtudományi Egyetem
-- Faculty: Villamosmérnöki és Informatikai Kar
-- Department: Elektronikus Eszközök Tanszék

-- Semester: 2019/20/2

-- Design Name: Újrafelhasználható memóriamodul nagymegbízhatóságú rendszerekhez
-- Module Name:

-- Description: 

----------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity counter is
    generic(
        -- clock: 100 MHz
        
        -- prescaler counts to seconds (depends on the clock)
        -- prescaler: 2**size
        prescaler_size: integer;
        
        -- timer counts to hours (depends on the user)
        --timer: 2**size
        timer_size: integer
    );
    port(
        clk: in std_logic;
        rst_n: in std_logic;
        input_idle: in std_logic;
        force_count: in std_logic;
        wakeup: out std_logic
    );
end counter;

architecture rtl of counter is

    signal prescaler: std_logic_vector((prescaler_size-1) downto 0);
    signal timer: std_logic_vector((timer_size-1) downto 0);
    signal rforce: std_logic;

begin

    L_TIMER: process(clk,rst_n)
    begin
        if(rst_n = '0') then
            prescaler <= (others => '1');
            timer <= (others => '1');
            rforce <= '0';
        elsif(rising_edge(clk)) then
            rforce <= force_count;
            if(rforce = '1') then
                prescaler <= (others => '1');
                timer <= (others => '1');
            elsif(input_idle = '1') then
                prescaler <= std_logic_vector(unsigned(prescaler) - 1);
                if(unsigned(prescaler) = 0) then
                    timer <= std_logic_vector(unsigned(timer) - 1);
                end if;
            end if;
        end if;
        
    end process;
    wakeup <= '1' when ((unsigned(prescaler) = 0) and (unsigned(timer) = 0)) or (rforce = '1') else '0';

end rtl;
