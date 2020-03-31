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


package header_secded is

    constant data_width: integer := 4;
    function get_parity_size(constant k: integer) return integer;
    constant parity_width: integer := get_parity_size(data_width);
    function get_code_size(constant k: integer; constant m: integer) return integer;
    constant code_width: integer := get_code_size(data_width, parity_width);
    constant code_width_log2: integer := positive((ceil(log2(real(code_width)))));
    
    function get_delay(constant registered_input: boolean; constant registered_output: boolean) return integer;
    
    -- ENCODE:
    function data_to_code(constant data: std_logic_vector((data_width-1) downto 0)) return std_logic_vector;
    function parity_to_code(constant data_code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector;
    
    -- DECODE:
    function get_syndrome(constant code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector;
    function correct_code(constant code: std_logic_vector((code_width-1) downto 0); constant syndrome: std_logic_vector((parity_width-1) downto 0)) return std_logic_vector;
    function get_data(constant code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector;

end package;

package body header_secded is

    -- parity bits: m
    -- data bits: k = 2^m - m - 1
    function get_parity_size(constant k: integer) return integer is
        variable m: integer := 1;
    begin
        -- calculate hamming parity bits
        while(2**m < k+m+1) loop
            m := m + 1;
        end loop;
        -- +1 for sec-ded     
        return m + 1;
    end function;
    
    
    -- code bits: n = k + m
    function get_code_size(constant k: integer; constant m: integer) return integer is
    begin
        return k + m;
    end function;
    
    
    function get_delay(constant registered_input: boolean; constant registered_output: boolean) return integer is
		variable delay: integer := 1;
	begin
		if(registered_input) then
			delay := delay + 1;
		end if;
		if(registered_output) then
			delay := delay + 1;
		end if;
		return delay;
	end function;

----------------------------------------------------------------------------------------------------

    function data_to_code(constant data: std_logic_vector((data_width-1) downto 0)) return std_logic_vector is
        -- data bit position
        variable j: integer := 0;
        variable code: std_logic_vector((code_width-1) downto 0) := (others => '0');
    begin
        for i in 1 to code_width loop
            if(2**positive((ceil(log2(real(i))))) /= i) then
                code(i-1) := data(j);
                j := j + 1;
            end if;
        end loop;
        return code;
    end function;
    
    
    function parity_to_code(constant data_code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector is
        variable code: std_logic_vector((code_width-1) downto 0) := data_code;
        variable zero: std_logic_vector(code_width_log2 downto 0) := (others => '0');
    begin
        for i in 1 to code_width-1 loop
            if(2**positive((ceil(log2(real(i))))) = i) then
                for j in i to code_width-1 loop
                    if((std_logic_vector(to_unsigned(i, code_width_log2+1)) and std_logic_vector(to_unsigned(j, code_width_log2+1)) ) /= zero) then
                        code(i-1) := code(i-1) xor code(j-1);
                    end if;
                end loop;
            end if;
            code(code_width-1) := code(code_width-1) xor code(i-1);
        end loop;
        return code;
    end function;

----------------------------------------------------------------------------------------------------

    function get_syndrome(constant code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector is
        variable syndrome: std_logic_vector((parity_width-1) downto 0) := (others => '0');
        variable zero: std_logic_vector(code_width_log2 downto 0) := (others => '0');
    begin
        for i in 1 to parity_width loop
            for j in 1 to code_width loop
                if((std_logic_vector(to_unsigned(i, code_width_log2+1)) & std_logic_vector(to_unsigned(j, code_width_log2+1)) ) /= zero) then
                    syndrome(i) := syndrome(i) xor code(j);
                end if;
            end loop;
        end loop;
        return syndrome;
    end function;


    function correct_code(constant code: std_logic_vector((code_width-1) downto 0); constant syndrome: std_logic_vector((parity_width-1) downto 0)) return std_logic_vector is
        variable corr_code: std_logic_vector((code_width-1) downto 0) := code;
    begin
        corr_code(to_integer(unsigned(syndrome))) := not corr_code(to_integer(unsigned(syndrome)));
        return corr_code;
    end function;
    
    
    function get_data(constant code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector is
        variable data: std_logic_vector((data_width-1) downto 0) := (others => '0');
        variable j: integer := 0;
    begin
        for i in 1 to code_width loop
            if(2**positive((ceil(log2(real(i))))) /= i) then
                data(j) := code(i);
                j := j + 1;
            end if;
        end loop;
        return data;
    end function;


    
        
end package body header_secded;