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
use work.header_scrubber.all;


entity top is
    generic(
        registered_input: boolean := true;
        registered_output: boolean := true
    );
    port(
        clk : in STD_LOGIC;
        rst_n : in STD_LOGIC;
        
        raw_data_in : in STD_LOGIC_VECTOR ((data_width-1) downto 0);
        code_2_mem : out STD_LOGIC_VECTOR ((code_width-1) downto 0);
        
        code_2_edac : in STD_LOGIC_VECTOR ((code_width-1) downto 0);
        raw_data_out : out STD_LOGIC_VECTOR ((data_width-1) downto 0);
        err_1 : out STD_LOGIC;
        err_2 : out STD_LOGIC;
        
        force : in STD_LOGIC;
        busy : out STD_LOGIC;
        address : out STD_LOGIC_VECTOR (0 downto 0)
    );
end top;

architecture rtl of top is

begin
    L_EDAC: entity work.edac(rtl)
        generic map(
            registered_input => registered_input,
            registered_output => registered_output
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            raw_data_in => raw_data_in,
            code_2_mem => code_2_mem,
            code_2_edac => code_2_edac,
            raw_data_out => raw_data_out,
            err_1 => err_1,
            err_2 => err_2
        );
    L_SCRUBBER: entity work.scrubber(rtl)
        port map(
            clk => clk,
            rst_n => rst_n,
            force => force,
            busy => busy,
            address => address
        );

end rtl;
