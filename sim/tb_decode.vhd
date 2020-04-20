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
use work.header_secded.all;


entity tb_decode is
end tb_decode;

architecture behavior of tb_decode is

    -- clk: 100MHz
    constant clk_period: time := 10 ns;
    
    constant registered_input: boolean := true;
    constant registered_output: boolean := true;
    
    constant wait_t: time := clk_period * get_delay(registered_input,registered_output);
    
    signal clk: std_logic := '0';
    signal rst_n: std_logic := '1';
    signal code_2_edac: std_logic_vector ((code_width-1) downto 0);
    signal raw_data_out: std_logic_vector ((data_width-1) downto 0);
    signal error: std_logic_vector(1 downto 0);
    
begin

    L_CLK: process
    begin
        wait for clk_period / 2;
        clk <= not clk;
    end process;


    L_DUT: entity work.decoder(rtl)
        generic map(
            registered_input => true,
            registered_output => true
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            code_2_edac => code_2_edac,
            raw_data_out => raw_data_out,
            error => error
        );


   L_INIT: process
    begin
        --init
        wait for 100ns;
        
        --reset
        rst_n <= '0';
        wait for 100ns;
        rst_n <= '1';
        
        wait;
    end process;


    L_SEQUENCER: process
    begin
        wait on rst_n;
        wait on rst_n;
        
        --stimulus
        for i in 0 to ((2**code_width)-1) loop
            code_2_edac <= std_logic_vector(to_unsigned(i,code_width));
            wait for wait_t;
        end loop;
        
        code_2_edac <= (others => '0');
        wait for wait_t;
        
        --VHDL-2008
        --finish;
        wait;
        
    end process;
    
end behavior;
