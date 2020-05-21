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

library xil_defaultlib;
use xil_defaultlib.header_testbench.all;



entity tb_timer is
end tb_timer;

architecture behavior of tb_timer is

    -- clk: 100MHz
    constant clk_period: time := 10 ns;

    constant wait_t: time := clk_period * get_delay(registered_input,registered_output);
    
    signal clk: std_logic := '0';
    signal rst_n: std_logic := '1';


    signal idle: std_logic := '1';
    signal force: std_logic := '0';
    signal wakeup: std_logic;
    
    signal presc: std_logic_vector(0 downto 0);
    signal timer: std_logic_vector(1 downto 0);
    
begin

    L_DUT: entity xil_defaultlib.counter
        generic map(
            prescaler_size => 1,
            timer_size => 2
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            input_idle => idle,
            force_count => force,
            wakeup => wakeup
            --prescaler_state => presc,
            --timer_state => timer
        );


        
    L_CLK: process
    begin
        wait for clk_period / 2;
        clk <= not clk;
    end process;



    L_INIT: process
    begin
        wait for 50ns;     
        --init
        
        --reset
        rst_n <= '0';
        wait for 50ns;
        rst_n <= '1';
        
        wait;
    end process;
    
    
end behavior;