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


entity scrubber is
    generic(
        prescaler_size: integer := 17;
        timer_size: integer := 9
    );
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        force : in std_logic;
        err_rst: in std_logic;
        
        trigger_read: out std_logic;
        trigger_write: out std_logic;
        busy : out std_logic;
        address : out STD_LOGIC_VECTOR ((address_width-1) downto 0);
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
    signal state: state_t;
    attribute syn_preserve: boolean;
    attribute syn_preserve of state: signal is true;
    
    
    signal delay: integer := get_delay(registered_input,registered_output);
    signal delay_counter: integer;

    signal pointer: std_logic_vector((address_width-1) downto 0);
    constant address_min: std_logic_vector((address_width-1) downto 0) := (others => '0');
    constant address_max: std_logic_vector((address_width-1) downto 0) := (others => '1');

    signal input_idle: std_logic;
    signal wakeup: std_logic;

begin



L_SCRUBBER: if dummy_scrubber = false generate

    L_SCRUBBER_COUNTER: entity work.counter(rtl)
        generic map(
            prescaler_size => prescaler_size,
            timer_size => timer_size
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            input_idle => input_idle,
            force => force,
            wakeup => wakeup
        );
        
        
    L_SCRUBBER_FSM: process(clk, rst_n)
    begin
        if(rst_n = '0') then
            
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
                                
                when read =>        if(delay = 0) then
                                        trigger_read <= '0';
                                        delay_counter <= delay;
                                        state <= write;
                                    end if;
                                    delay_counter <= delay_counter - 1;
                                
                when write =>       if( delay = 0) then
                                        trigger_write <= '1';
                                        state <= control_2;
                                    end if;
                                    delay_counter <= delay_counter - 1;
                
                when control_2 =>   trigger_write <= '0';
                                    pointer <= std_logic_vector(unsigned(pointer) + 1);
                                    state <= control_1;


                when error =>       pointer <= address_min;
                                    trigger_read <= '0';
                                    trigger_write <= '0';
                                    fsm_error <= '0';
                                    input_idle <= '1';
                                    state <= idle;

                when others =>      fsm_error <= '1';
                                    state <= error;

            end case;              
        end if;
    
    end process;

end generate L_SCRUBBER;



L_DUMMY: if dummy_scrubber = true generate
    
    busy <= '0';
    address <= (others => '0');

end generate L_DUMMY;

end rtl;
