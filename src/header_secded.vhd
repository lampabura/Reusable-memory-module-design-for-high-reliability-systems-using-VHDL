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


package header_secded is

    constant address_width: integer := 8;
    constant data_width: integer := 4;
    constant registered_input: boolean := true;
    constant registered_output: boolean := true;
    constant dummy_scrubber: boolean := false;
    
    constant data_width_log2: integer;
    
    function get_parity_size(constant k: integer) return integer;
    constant parity_width: integer;
    constant parity_width_log2: integer;
    
    function get_code_size(constant k: integer; constant m: integer) return integer;
    constant code_width: integer;
    constant code_width_log2: integer;
    
    function get_delay(constant registered_input: boolean; constant registered_output: boolean) return integer;
    
    -- ENCODE:
    function data_to_code(constant data: std_logic_vector((data_width-1) downto 0)) return std_logic_vector;
    function parity_to_code(constant data_code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector;
    
    -- DECODE:
    function get_data(constant code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector;
    function check(constant raw_code: std_logic_vector((code_width-1) downto 0); constant check_code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector;
    function code_get_parity(constant code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector;
    function parity_get_code(constant parity: std_logic_vector((parity_width-1) downto 0)) return std_logic_vector;
    

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
            if(2**integer((ceil(log2(real(i))))) /= i) then
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
            if(2**integer((ceil(log2(real(i))))) = i) then
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

    function get_data(constant code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector is
        variable data: std_logic_vector((data_width-1) downto 0) := (others => '0');
        variable j: integer := 0;
    begin
        for i in 1 to code_width loop
            if(2**integer((ceil(log2(real(i))))) /= i) then
                data(j) := code(i-1);
                j := j + 1;
            end if;
        end loop;
        return data;
    end function;


    function check(constant raw_code: std_logic_vector((code_width-1) downto 0); constant check_code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector is
        variable bit_counter: std_logic_vector(2 downto 0) := (others => '0');
        variable xcode: std_logic_vector((code_width-1) downto 0);
    begin
        xcode := raw_code xor check_code;
        for i in 0 to code_width-1 loop
            if(xcode(i) = '1') then
                bit_counter := std_logic_vector(unsigned(bit_counter) + 1);
            end if;
        end loop;
        return bit_counter;
    end function;
 
        
    function code_get_parity(constant code: std_logic_vector((code_width-1) downto 0)) return std_logic_vector is
        variable parity: std_logic_vector((parity_width-1) downto 0) := (others => '0');
        variable j: integer := 0;
    begin
        for i in 1 to code_width loop
             if(2**integer((ceil(log2(real(i))))) = i) then
                parity(j) := code(i-1);
                j := j + 1;
             end if;
        end loop;
        return parity;
    end function;
    
    
    function parity_get_code(constant parity: std_logic_vector((parity_width-1) downto 0)) return std_logic_vector is
        variable code: std_logic_vector((code_width-1) downto 0) := (others => '0');
        variable count: integer := 0;
        variable j: integer := 0;
        variable zero: std_logic_vector(code_width_log2 downto 0) := (others => '0');
    begin
    
        for i in 0 to parity_width-1 loop
            if(parity(i) = '1') then
                count := count + 1;
            end if;
        end loop;
        if((count mod 2) = 1) then
            code := (others => '1');
        end if;
        
        for i in 1 to code_width loop
            if(2**integer((ceil(log2(real(i))))) = i) then
                count := 0;
                code(i-1) := parity(j);
                j := j + 1;
                for j in i to code_width-1 loop
                    if((std_logic_vector(to_unsigned(i, code_width_log2+1)) and std_logic_vector(to_unsigned(j, code_width_log2+1)) ) /= zero) then
                        if(code(j-1) = '1') then
                            count := count + 1;
                        end if;
                    end if;
                end loop;
                if((count mod 2) = 1) then
                    for j in i+1 to code_width-1 loop
                        if((std_logic_vector(to_unsigned(i, code_width_log2+1)) and std_logic_vector(to_unsigned(j, code_width_log2+1)) ) /= zero) then
                            code(j-1) := code(j-1) xor '1';
                        end if;
                    end loop;
                end if;
            end if;
        end loop;
        return code;
    end function;
    
    
    
    constant data_width_log2: integer := integer((ceil(log2(real(data_width)))));
    
    constant parity_width: integer := get_parity_size(data_width);
    constant parity_width_log2: integer := integer((ceil(log2(real(parity_width)))));
    
    constant code_width: integer := get_code_size(data_width, parity_width);
    constant code_width_log2: integer := integer((ceil(log2(real(code_width)))));
      
end package body header_secded;