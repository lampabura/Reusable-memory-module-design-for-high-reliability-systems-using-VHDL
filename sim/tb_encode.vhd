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



entity tb_encode is
end tb_encode;

architecture behavior of tb_encode is

    -- clk: 100MHz
    constant clk_period: time := 10 ns;

    constant wait_t: time := clk_period * get_delay(registered_input,registered_output);
    
    signal clk: std_logic := '0';
    signal rst_n: std_logic := '1';
    signal reset: std_logic := '0';
    signal clken: std_logic := '1';
    
    signal raw_data_in: std_logic_vector ((data_width-1) downto 0) := (others => '0');
    signal data_out: std_logic_vector ((data_width-1) downto 0);
    signal chkbits_out: std_logic_vector ((parity_width-1) downto 0);
    signal code_out: std_logic_vector ((code_width-1) downto 0);
    
    signal code_in: std_logic_vector ((code_width-1) downto 0) := (others => '0');
    signal data_in: std_logic_vector ((data_width-1) downto 0) := (others => '0');
    signal chkbits_in: std_logic_vector ((parity_width-1) downto 0) := (others => '0');
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
    
    signal reference_code: std_logic_vector((code_width-1) downto 0);
    signal main_code: std_logic_vector((code_width-1) downto 0);
    signal test_ok: std_logic;
    
begin

    L_DUT: entity xil_defaultlib.wrapper_enc
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
            address => address,


            ecc_clk => clk,
            ecc_reset => reset,
            ecc_clken => clken,
            ecc_data_in => raw_data_in,
            ecc_data_out => data_out,
            ecc_chkbits_out => chkbits_out
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
        reset <= '1';
        wait for 50ns;
        rst_n <= '1';
        reset <= '0';
        
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
    
    L_CHECKER: process
    begin
    
        wait on rst_n;
        wait on rst_n;
        
        loop wait on code_out;
            reference_code <= convert2code(data_out,rotparityr(chkbits_out));
            main_code <= code_out;
            
            if main_code = reference_code then
                test_ok <= '1';
            else
                test_ok <= '0';
                report "TEST FAILED";
            end if;
        end loop;
    end process;
    
    
end behavior;
