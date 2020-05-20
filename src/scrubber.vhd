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
library xil_defaultlib;
use xil_defaultlib.header_secded.all;


entity scrubber is
    generic(
        prescaler_size: integer := 17;
        timer_size: integer := 9
    );
    port(
        clk: in std_logic;
        rst_n: in std_logic;
        force_scrub: in std_logic;
        error_rst: in std_logic;
        
        trigger_read: out std_logic;
        trigger_write: out std_logic;
        busy: out std_logic;
        address: out STD_LOGIC_VECTOR ((address_width-1) downto 0);
        fsm_error: out std_logic
    );
end scrubber;

architecture rtl of scrubber is

    type state_t is(
        idle,
        control_1,
        read,
        write,
        control_2,
        error
    );
    attribute syn_enum_encoding: string;
	attribute syn_enum_encoding of state_t : type is "onehot";
	
	signal state: state_t;
	attribute syn_preserve: boolean;
    attribute syn_preserve of state:signal is true;
    
    
    constant delay: integer := get_delay(registered_input,registered_output);
    signal delay_counter: integer;

    signal pointer: std_logic_vector((address_width-1) downto 0);
    constant address_min: std_logic_vector((address_width-1) downto 0) := (others => '0');
    constant address_max: std_logic_vector((address_width-1) downto 0) := (others => '1');

    signal input_idle: std_logic;
    signal wakeup: std_logic;
    
    signal error_reset_reg: std_logic;

begin



L_SCRUBBER: if dummy_scrubber = false generate

    L_SCRUBBER_COUNTER: entity xil_defaultlib.counter(rtl)
        generic map(
            prescaler_size => prescaler_size,
            timer_size => timer_size
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            input_idle => input_idle,
            force_count => force_scrub,
            wakeup => wakeup
        );
        
        
    L_SCRUBBER_FSM: process(clk, rst_n)
    begin
        if(rst_n = '0') then
            state <= idle;
            busy <= '0';
            pointer <= address_min;
            input_idle <= '1';
            fsm_error <= '0';
            trigger_read <= '0';
            trigger_write <= '0';
        elsif(rising_edge(clk)) then
            case state is
                when idle =>        if(wakeup = '1') then 
                                        state <= control_1;
                                        busy <= '1';
                                        input_idle <= '0';
                                    end if;
             
                when control_1 =>   if(pointer < address_max) then
                                        delay_counter <= delay;
                                        state <= read;
                                        trigger_read <= '1';
                                    else
                                        pointer <= address_min;
                                        state <= idle;
                                        input_idle <= '1';
                                        busy <= '0';
                                    end if;               
                                
                when read =>        if(delay_counter = 0) then
                                        trigger_read <= '0';
                                        delay_counter <= delay;
                                        state <= write;
                                        trigger_write <= '0';
                                    else
                                        delay_counter <= delay_counter - 1;
                                    end if;
                                
                when write =>       if( delay_counter = 0) then
                                        trigger_write <= '1';
                                        state <= control_2;
                                    else
                                        delay_counter <= delay_counter - 1;
                                    end if;
                
                when control_2 =>   trigger_write <= '0';
                                    pointer <= std_logic_vector(unsigned(pointer) + 1);
                                    state <= control_1;


                when error =>       if(error_reset_reg = '1') then
                                        pointer <= address_min;
                                        trigger_read <= '0';
                                        trigger_write <= '0';
                                        fsm_error <= '0';
                                        input_idle <= '1';
                                        state <= idle;
                                        busy <= '0';
                                    end if;
                                    

                when others =>      fsm_error <= '1';
                                    state <= error;

            end case;              
        end if;
        
    end process;
    address <= pointer;
    error_reset_reg <= error_rst;
    
end generate L_SCRUBBER;



L_DUMMY: if dummy_scrubber = true generate
    
    busy <= '0';
    address <= address_min;
    fsm_error <= '0';
    trigger_read <= '0';
    trigger_write <= '0';

end generate L_DUMMY;

end rtl;
