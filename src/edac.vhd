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


entity edac is
    port(
        clk : in STD_LOGIC;
        rst_n : in STD_LOGIC;
        
        raw_data_in : in STD_LOGIC_VECTOR ((data_width-1) downto 0);
        code_2_mem : out STD_LOGIC_VECTOR ((code_width-1) downto 0);
        
        code_2_edac : in STD_LOGIC_VECTOR ((code_width-1) downto 0);
        raw_data_out : out STD_LOGIC_VECTOR ((data_width-1) downto 0);
        
        error : out std_logic_vector(1 downto 0)
    );
end entity edac;

architecture rtl of edac is
begin
    L_ENCODER: entity work.encoder(rtl)
    port map(
        clk => clk,
        rst_n => rst_n,
        raw_data_in => raw_data_in,
        code_2_mem => code_2_mem
    );
    
    L_DECODER: entity work.decoder(rtl)
    port map(
        clk => clk,
        rst_n => rst_n,
        code_2_edac => code_2_edac,
        raw_data_out => raw_data_out,
        error => error
    );

end rtl;
