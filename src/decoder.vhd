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
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        code_2_edac : in std_logic_vector ((code_width-1) downto 0);
        raw_data_out : out std_logic_vector ((data_width-1) downto 0);
        error : out std_logic_vector(1 downto 0)
     );
end decoder;

architecture rtl of decoder is

    signal input_reg: std_logic_vector ((code_width-1) downto 0);
    signal input: std_logic_vector ((code_width-1) downto 0);
    
    signal err: std_logic_vector (1 downto 0);
    signal data: std_logic_vector ((data_width-1) downto 0);
    
    signal check_code: std_logic_vector((code_width-1) downto 0);
    signal bits: std_logic_vector(2 downto 0);
    
    signal output_reg_data: std_logic_vector ((data_width-1) downto 0);
    signal output_reg_error: std_logic_vector (1 downto 0);

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

    check_code <= parity_to_code(data_to_code(get_data(input)));
    bits <= check(input, check_code);
    
    
    data <= get_data(parity_get_code(code_get_parity(input))) when bits = "011" else get_data(input);
    err <= "00" when bits = "000" else
           "01" when bits = "001" else
           "01" when bits = "011" else
           "10" when bits = "010" else
           "11";
    
    
    

    L_OUTPUT: process(clk, rst_n)
    begin
        if(rst_n = '0') then
            output_reg_data <= (others => '0');
            output_reg_error <= (others => '0');
        elsif(rising_edge(clk)) then
            output_reg_data <= data;
            output_reg_error <= err;
        end if;
    end process;
    raw_data_out <= output_reg_data when registered_output = true else data;
    error <= output_reg_error when registered_output = true else err;

end rtl;
