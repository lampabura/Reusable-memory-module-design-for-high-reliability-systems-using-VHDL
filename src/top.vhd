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
use xil_defaultlib.header_secded.all;


entity top is
    port(
        clk: in std_logic;
        rst_n: in std_logic;
        
        r_code_ready: in std_logic;
        re_ack: out std_logic;
        we: in std_logic;
        w_code_ready: out std_logic;
        
        raw_data_in: in std_logic_vector ((data_width-1) downto 0);
        code_2_mem: out std_logic_vector ((code_width-1) downto 0);
        
        error_reset: in std_logic;
        busy: out std_logic;
        forcer: in std_logic;
        
        error: out std_logic_vector (1 downto 0);
        code_2_edac: in std_logic_vector ((code_width-1) downto 0);
        raw_data_out: out std_logic_vector ((data_width-1) downto 0);
        
        re: out std_logic;
        address: out std_logic_vector ((address_width-1) downto 0)
    );
end top;

architecture rtl of top is

    constant delay: integer := get_delay(registered_input,registered_output);
    signal read_delay: std_logic_vector(3 downto 0);
    signal read_done: std_logic;
    signal write_delay: std_logic_vector(3 downto 0);
    signal write_done: std_logic;
    signal scrub: std_logic;
    
    signal trigger_write: std_logic;
    
    signal input_data: std_logic_vector((data_width-1) downto 0);
    signal output_data: std_logic_vector((data_width-1) downto 0);
    

begin
    L_EDAC: entity xil_defaultlib.edac(rtl)
        port map(
            clk => clk,
            rst_n => rst_n,
            raw_data_in => input_data,
            code_2_mem => code_2_mem,
            code_2_edac => code_2_edac,
            raw_data_out => output_data,
            error => error
        );


    L_SCRUBBER: entity xil_defaultlib.scrubber(rtl)
        port map(
            clk => clk,
            rst_n => rst_n,
            error_rst => error_reset,
            force_scrub => forcer,
            busy => scrub,
            address => address,
            trigger_read => re,
            trigger_write => trigger_write
        );

               
    L_WRITE_ACKNOWLEDGE: process(clk, rst_n)
    begin
        if(rst_n = '0') then
            write_delay <= std_logic_vector(to_unsigned(delay, 4));
        elsif(rising_edge(clk)) then
            if(we = '1' and write_done = '0') then
                write_delay <= std_logic_vector(unsigned(write_delay) - 1);
            elsif(write_done = '1') then
                write_delay <= std_logic_vector(to_unsigned(delay, 4));
            end if;
        end if;
    end process; 
    write_done <= '1' when (write_delay = "0000") else '0';
    
    w_code_ready <= trigger_write when scrub = '1' else write_done;
    
    
    busy <= scrub;
    input_data <= output_data when scrub = '1' else raw_data_in;
    raw_data_out <= output_data;
    

    L_READ_ACKNOWLEDGE: process(clk, rst_n)
    begin
        if(rst_n = '0') then
            read_delay <= std_logic_vector(to_unsigned(delay,4));
        elsif(rising_edge(clk)) then
            if(r_code_ready = '1' and read_done = '0') then
                read_delay <= std_logic_vector(unsigned(read_delay) - 1);
            elsif(read_done = '1') then
                read_delay <= std_logic_vector(to_unsigned(delay,4));
            end if;
        end if; 
    end process;
    read_done <= '1' when (read_delay = "0000") else '0';
    
    re_ack <= read_done;

end rtl;
