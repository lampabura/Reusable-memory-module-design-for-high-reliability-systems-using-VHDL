----------------------------------------------------------------------------------------------------
-- Engineer: T�th �d�m Raymond
-- Advisor: Dr. Horv�th P�ter

-- University: Budapesti M�szaki �s Gazdas�gtudom�nyi Egyetem
-- Faculty: Villamosm�rn�ki �s Informatikai Kar
-- Department: Elektronikus Eszk�z�k Tansz�k

-- Semester: 2019/20/2

-- Design Name: �jrafelhaszn�lhat� mem�riamodul nagymegb�zhat�s�g� rendszerekhez
-- Module Name:

-- Description: 

----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.header_secded.all;


entity edac is
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
        err_2 : out STD_LOGIC
    );
end entity edac;

architecture rtl of edac is
begin
    L_ENCODER: entity work.encoder(rtl)
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
    
    L_DECODER: entity work.decoder(rtl)
    generic map(
        registered_input => registered_input,
        registered_output => registered_output
    )
    port map(
        clk => clk,
        rst_n => rst_n,
        code_2_edac => code_2_edac,
        raw_data_out => raw_data_out,
        err_1 => err_1,
        err_2 => err_2
    );

end rtl;
