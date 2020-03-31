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


entity tb_decode is
end tb_decode;

architecture behavior of tb_decode is

    -- clk: 100MHz
    constant clk_period: time := 10 ns;
    
    signal clk: std_logic := '0';
    signal rst_n: std_logic := '1';
    signal code_2_edac: std_logic_vector ((code_width-1) downto 0);
    signal raw_data_out: std_logic_vector ((data_width-1) downto 0);
    signal err_1: std_logic;
    signal err_2: std_logic;
    
begin

    L_CLK: process
    begin
        wait for clk_period / 2;
        clk <= not clk;
    end process;


    L_DUT: entity work.decoder(rtl)
        generic map(
            registered_input => true,
            registered_output => true
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            code_2_edac => code_2_edac,
            raw_data_out => raw_data_out,
            err_1 => err_1,
            err_2 => err_2
        );


    L_TEST: process
    begin
        
        --init
        wait for 100ns;
        
        --reset
        rst_n <= '0';
        wait for 100ns;
        rst_n <= '1';
        
        wait for 100ns;
        
        --stimulus

        
        
    end process;
    
end behavior;