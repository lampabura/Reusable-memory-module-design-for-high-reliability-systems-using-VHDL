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


entity top is
    port(
        clk : in STD_LOGIC;
        rst_n : in STD_LOGIC;
        
        r_code_ready: in std_logic;
        re_ack: out std_logic;
        we: in std_logic;
        w_code_ready: out std_logic;
        
        raw_data_in : in STD_LOGIC_VECTOR ((data_width-1) downto 0);
        code_2_mem : out STD_LOGIC_VECTOR ((code_width-1) downto 0);
        
        code_2_edac : in STD_LOGIC_VECTOR ((code_width-1) downto 0);
        raw_data_out : out STD_LOGIC_VECTOR ((data_width-1) downto 0);
        error: out std_logic_vector(1 downto 0);
        
        force : in STD_LOGIC;
        error_reset: in std_logic;
        busy : out STD_LOGIC;
        
        re: out std_logic;
        address: out std_logic_vector((address_width-1) downto 0)
    );
end top;

architecture rtl of top is

    signal delay: integer := get_delay(registered_input,registered_output);
    signal read_delay: integer := delay;
    signal read_done: std_logic := '0';
    signal write_delay: integer := delay;
    signal write_done: std_logic := '0';
    signal scrub: std_logic;
    
    signal trigger_write: std_logic;

begin
    L_EDAC: entity work.edac(rtl)
        port map(
            clk => clk,
            rst_n => rst_n,
            raw_data_in => raw_data_in,
            code_2_mem => code_2_mem,
            code_2_edac => code_2_edac,
            raw_data_out => raw_data_out,
            error => error
        );


    L_SCRUBBER: entity work.scrubber(rtl)
        port map(
            clk => clk,
            rst_n => rst_n,
            force => force,
            err_rst => error_reset,
            busy => scrub,
            address => address,
            trigger_read => re,
            trigger_write => trigger_write
        );
    busy <= scrub;
               
    L_WRITE_ACKNOWLEDGE: process(clk, rst_n)
    begin
        if(rst_n = '0') then
            write_delay <= delay;
            write_done <= '0';
        elsif(rising_edge(clk)) then
            if(we = '1' and write_done = '0') then
                write_delay <= write_delay - 1;
            elsif(write_done = '1') then
                write_delay <= delay;
            end if;
        end if;
    end process;
    write_done <= '1' when (write_delay = 0) else '0';
    
    w_code_ready <= trigger_write when scrub = '1' else write_done;
    

    L_READ_ACKNOWLEDGE: process(clk, rst_n)
    begin
        if(rst_n = '0') then
            read_delay <= delay;
            read_done <= '0';
        elsif(rising_edge(clk)) then
            if(r_code_ready = '1' and read_done = '0') then
                read_delay <= read_delay - 1;
            elsif(read_done = '1') then
                read_delay <= delay;
            end if;
        end if; 
    end process;
    read_done <= '1' when (read_delay = 0) else '0';
    
    re_ack <= read_done;

end rtl;
