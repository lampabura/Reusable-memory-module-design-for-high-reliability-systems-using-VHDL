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



package header_testbench is

    constant data_width: integer := 4;
    constant parity_width: integer := 4;
    constant code_width: integer := 8;
    constant address_width: integer := 8;
    
    constant registered_input: boolean := true;
    constant registered_output: boolean := true;

    function rotparityr(constant parity: std_logic_vector((parity_width-1) downto 0)) return std_logic_vector;
    function convert2code(constant data: std_logic_vector((data_width-1) downto 0); constant parity: std_logic_vector((parity_width-1) downto 0)) return std_logic_vector;
    
    function get_delay(constant registered_input: boolean; constant registered_output: boolean) return integer;

end package;

package body header_testbench is

        function rotparityr(constant parity: std_logic_vector((parity_width-1) downto 0)) return std_logic_vector is
            variable newparity: std_logic_vector((parity_width-1) downto 0);
        begin
            newparity(parity_width-1) := parity(0);
            for i in 1 to parity_width-1 loop
                newparity(i-1) := parity(i);
            end loop;
            return newparity;
        end function;

        function convert2code(constant data: std_logic_vector((data_width-1) downto 0); constant parity: std_logic_vector((parity_width-1) downto 0)) return std_logic_vector is
            variable code: std_logic_vector((code_width-1) downto 0);
            variable j: integer := 0;
            variable k: integer :=0;
        begin
            for i in 1 to code_width loop
                if(2**integer((ceil(log2(real(i))))) = i) then
                    code(i-1) := parity(k);
                    k := k + 1;
                else
                    code(i-1) := data(j);
                    j := j + 1;
                end if;
            end loop;
            return code;
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

    
end package body header_testbench;