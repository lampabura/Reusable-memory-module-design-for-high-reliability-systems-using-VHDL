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



entity tb_scrub is
end tb_scrub;

architecture behavior of tb_scrub is

    -- clk: 100MHz
    constant clk_period: time := 10 ns;

    constant wait_t: time := clk_period * get_delay(registered_input,registered_output);
    
    signal clk: std_logic := '0';
    signal rst_n: std_logic := '1';
    
    signal raw_data_in: std_logic_vector ((data_width-1) downto 0) := (others => '0');
    signal code_out: std_logic_vector ((code_width-1) downto 0);
    
    signal code_in: std_logic_vector ((code_width-1) downto 0) := (others => '0');
    signal raw_data_out: std_logic_vector ((data_width-1) downto 0);
    
    signal error: std_logic_vector(1 downto 0);
    
    signal r_code_ready: std_logic := '0';
    signal re_ack: std_logic;
    signal we: std_logic := '0';
    signal w_code_ready: std_logic;
    signal re: std_logic;

    signal force_top: std_logic := '0';
    signal error_reset: std_logic := '0';
    signal busy: std_logic;
    
    signal address: std_logic_vector((address_width-1) downto 0);
    signal next_address: std_logic_vector((address_width-1) downto 0) := (others => '0');
    
    signal code_test_ok: std_logic;
    signal address_test_ok: std_logic;
    
begin

    L_DUT: entity xil_defaultlib.top
        port map(
            clk => clk,
            rst_n => rst_n,
            r_code_ready => r_code_ready,
            re_ack => re_ack,
            we => we,
            w_code_ready => w_code_ready,
            raw_data_in => raw_data_in,
            code_2_mem => code_out,
            code_2_edac => code_in,
            raw_data_out => raw_data_out,
            error => error,
            error_reset => error_reset,
            forcer => force_top,
            busy => busy,
            re => re,
            address => address
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
        force_top <= '1';
        
        wait;
    end process;


    L_SEQUENCER: process
    begin
        wait on rst_n;
        wait on rst_n;
        
        --stimulus

        wait on re;
        wait on w_code_ready;
        code_in <= (others => '1');
        wait on re;
        wait on w_code_ready;
        code_in <= "10101010";
        raw_data_in <= "1111";
        wait on re;
        wait on w_code_ready;
        code_in <= (others => '0');
        wait on re;
        wait on w_code_ready;
        
        wait;
    end process;
    
        L_CHECKER: process
    begin
    
        wait on rst_n;
        wait on rst_n;
        
        loop wait on re,w_code_ready;
            if(re = '1') then
                if(next_address = address) then
                    address_test_ok <= '1';
                else
                    address_test_ok <= '0';
                    report "TEST FAILED";
                end if;
                next_address <= std_logic_vector(unsigned(next_address) + 1);     
            end if;
            if(w_code_ready = '1') then
                if(code_in = code_out) then
                    code_test_ok <= '1';
                else
                    code_test_ok <= '0';
                    report "TEST FAILED";
                end if;
            end if;
        end loop;
    end process;
    
    
end behavior;