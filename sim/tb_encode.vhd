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


entity tb_encode is
end tb_encode;

architecture behavior of tb_encode is

    -- clk: 100MHz
    constant clk_period: time := 10 ns;
    
    constant registered_input: boolean := true;
    constant registered_output: boolean := true;
    
    constant wait_t: time := clk_period * get_delay(registered_input,registered_output);
    
    signal clk: std_logic := '0';
    signal rst_n: std_logic := '1';
    signal raw_data_in: std_logic_vector ((data_width-1) downto 0);
    signal code_2_mem: std_logic_vector ((code_width-1) downto 0);
    
begin

    L_CLK: process
    begin
        wait for clk_period / 2;
        clk <= not clk;
    end process;


    L_DUT: entity work.encoder(rtl)
        generic map(
            registered_input => registered_input,
            registered_output => registered_output
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            raw_data_in => raw_data_in,
            code_2_mem => code_2_mem
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
        for i in 0 to ((2**data_width)-1) loop
            raw_data_in <= std_logic_vector(to_unsigned(i,data_width));
            wait for wait_t;
        end loop;
        
        raw_data_in <= (others => '0');
        wait for wait_t;
        
        --VHDL-2008
        --finish;
        wait;
        
    end process;
    
    
--    L_CHECKER: process
--        variable previous: std_logic_vector((code_width-1) downto 0);
--        variable current: std_logic_vector((code_width-1) downto 0);
--        variable changed: integer;
--    begin
--        wait on raw_data_in;
--        
--        --check
--        previous := code_2_mem;
--        wait for 1ns;
--
--    end process;
    
end behavior;
