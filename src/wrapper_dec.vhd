library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library xil_defaultlib;
use xil_defaultlib.header_secded.all;


entity wrapper_dec is
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
        address: out std_logic_vector ((address_width-1) downto 0);


        ecc_clk : IN STD_LOGIC;
        ecc_reset : IN STD_LOGIC;
        ecc_correct_n : IN STD_LOGIC;
        ecc_clken : IN STD_LOGIC;
        ecc_data_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        ecc_data_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        ecc_chkbits_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        ecc_sbit_err : OUT STD_LOGIC;
        ecc_dbit_err : OUT STD_LOGIC
    );
end wrapper_dec;

architecture Behavioral of wrapper_dec is

    -- COMP_TAG
COMPONENT ecc_dec
  PORT (
    ecc_clk : IN STD_LOGIC;
    ecc_reset : IN STD_LOGIC;
    ecc_correct_n : IN STD_LOGIC;
    ecc_clken : IN STD_LOGIC;
    ecc_data_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    ecc_data_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    ecc_chkbits_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    ecc_sbit_err : OUT STD_LOGIC;
    ecc_dbit_err : OUT STD_LOGIC
  );
END COMPONENT;
    -- COMP_TAG_END

begin
    
    L_TOP: entity xil_defaultlib.top
        port map(
            clk => clk,
            rst_n => rst_n,
            r_code_ready => r_code_ready,
            re_ack => re_ack,
            we => we,
            w_code_ready => w_code_ready,
            raw_data_in => raw_data_in,
            code_2_mem => code_2_mem,
            code_2_edac => code_2_edac,
            raw_data_out => raw_data_out,
            error => error,
            error_reset => error_reset,
            forcer => forcer,
            busy => busy,
            re => re,
            address => address
    );
    
    -- INST_TAG
    L_REFERENCE : ecc_dec
      PORT MAP (
        ecc_clk => ecc_clk,
        ecc_reset => ecc_reset,
        ecc_correct_n => ecc_correct_n,
        ecc_clken => ecc_clken,
        ecc_data_in => ecc_data_in,
        ecc_data_out => ecc_data_out,
        ecc_chkbits_in => ecc_chkbits_in,
        ecc_sbit_err => ecc_sbit_err,
        ecc_dbit_err => ecc_dbit_err
      );
    -- INST_TAG_END 

end Behavioral;