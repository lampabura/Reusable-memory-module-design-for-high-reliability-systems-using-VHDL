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


entity decoder is
    generic(
        registered_input: boolean := true;
        registered_output: boolean := true
    );
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        code_2_edac : in std_logic_vector ((code_width-1) downto 0);
        raw_data_out : out std_logic_vector ((data_width-1) downto 0);
        err_1 : out std_logic;
        err_2 : out std_logic
     );
end decoder;

architecture rtl of decoder is

    signal input_reg: std_logic_vector ((code_width-1) downto 0);
    signal input: std_logic_vector ((code_width-1) downto 0);
    
    signal data: std_logic_vector ((data_width-1) downto 0);
    
    signal output_reg: std_logic_vector ((data_width-1) downto 0);

begin
    L_INPUT: process(clk, rst_n)
    begin
        if(rst_n = '0') then
            input_reg <= (others => '0');
        elsif(rising_edge(clk)) then
            input_reg <= code_2_edac;
        end if;
    end process;
    input <= input_reg when registered_input = true else code_2_edac;
    
    data <= get_data(correct_code(input,get_syndrome(input)));

    L_OUTPUT: process(clk, rst_n)
    begin
        if(rst_n = '0') then
            output_reg <= (others => '0');
        elsif(rising_edge(clk)) then
            output_reg <= data;
        end if;
    end process;
    raw_data_out <= output_reg when registered_output = true else data;


end rtl;
