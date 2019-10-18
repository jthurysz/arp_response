----------------------------------------------
-- Create Date : 10/17/2019 12:36:12 PM
-- Design Name : arp_controller.vhd
-- Engineer    : Joe Hurysz
--
-- Description : TO-DO
--
----------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity ARP_CONTROLLER is
    Port (ARESET        : in  std_logic;
          
          CLK_RX        : in  std_logic;
          DATA_VALID_RX : in  std_logic;

          CNT_EQ_41     : in  std_logic;
          EN_CNT        : out std_logic;
          PARSE_DONE    : out std_logic);
end ARP_CONTROLLER;

architecture BEHAVIORAL of ARP_CONTROLLER is

    -- RX FSM Declaration
    type T_RX_FSM is (S_IDLE, S_PARSE);
    signal state, next_state : T_RX_FSM := S_IDLE;

begin

    RX_State_Process : process(ARESET, CLK_RX)
    begin
        if ARESET = '1' then
            state <= S_IDLE;
        elsif rising_edge(CLK_RX) then
            state <= next_state;
        end if;
    end process RX_State_Process;

    RX_State_Transition_Logic : process(state, ARESET, DATA_VALID_RX, CNT_EQ_41)
    begin
        case state is
            when S_IDLE  =>

                PARSE_DONE <= '0';
                EN_CNT <= '0';

                if (ARESET = '1') then
                    next_state <= S_IDLE;
                elsif (DATA_VALID_RX = '1') then
                    EN_CNT <= '1';
                    next_state <= S_PARSE;
                else
                    next_state <= S_IDLE;
                end if;

            when S_PARSE =>

                EN_CNT <= '1';
            
                if (ARESET = '1' or CNT_EQ_41 = '1') then
                    EN_CNT     <= '0';
                    PARSE_DONE <= '1';
                    next_state <= S_IDLE;
                else
                    next_state <= S_PARSE;
                end if;

        end case;
    end process RX_State_Transition_Logic;


end BEHAVIORAL;
