----------------------------------------------
-- Create Date : 10/17/2019 12:36:12 PM
-- Design Name : arp_controller.vhd
-- Engineer    : Joe Hurysz
--
-- Description : TX_RX FSMs for ARP Response
--               Design
--
----------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ARP_CONTROLLER is
    Port (ARESET           : in  std_logic;
          CLK_RX           : in  std_logic;
          DATA_VALID_RX    : in  std_logic;
          CLK_TX           : in  std_logic;
          DATA_ACK_TX      : in  std_logic;
          DATA_VALID_TX    : out std_logic;
          RX_CNT_EQ_41     : in  std_logic;
          TX_CNT_EQ_41     : in  std_logic;
          RX_EN_CNT        : out std_logic;
          TX_EN_CNT        : out std_logic;
          PARSE_DONE       : out std_logic;
          SEND_MAC         : in  std_logic;
          SHOW_FIRST_BYTE  : out std_logic;
          LD_DATA_OUT      : out std_logic);
end ARP_CONTROLLER;

architecture BEHAVIORAL of ARP_CONTROLLER is

    -- RX FSM Declaration
    type T_RX_FSM is (S_IDLE, S_PARSE);
    signal rx_state, rx_next_state : T_RX_FSM := S_IDLE;

    --TX FSM Declaration
    type T_TX_FSM is (S_IDLE, S_SHOW_BYTE_WAIT_ACK_TX, S_CONTINOUS_WRITE);
    signal tx_state, tx_next_state : T_TX_FSM := S_IDLE;

begin

    RX_State_Process : process(ARESET, CLK_RX)
    begin
        if ARESET = '1' then
            rx_state <= S_IDLE;
        elsif rising_edge(CLK_RX) then
            rx_state <= rx_next_state;
        end if;
    end process RX_State_Process;

    RX_State_Transition_Logic : process(rx_state, ARESET, DATA_VALID_RX, RX_CNT_EQ_41)
    begin
        case rx_state is
            when S_IDLE  =>

                PARSE_DONE <= '0';
                RX_EN_CNT <= '0';

                if (ARESET = '1') then
                    rx_next_state <= S_IDLE;
                elsif (DATA_VALID_RX = '1') then
                    RX_EN_CNT <= '1';
                    rx_next_state <= S_PARSE;
                else
                    rx_next_state <= S_IDLE;
                end if;

            when S_PARSE =>

                RX_EN_CNT <= '1';
            
                if (ARESET = '1' or RX_CNT_EQ_41 = '1') then
                    RX_EN_CNT     <= '0';
                    PARSE_DONE <= '1';
                    rx_next_state <= S_IDLE;
                else
                    rx_next_state <= S_PARSE;
                end if;
        end case;
    end process RX_State_Transition_Logic;

    TX_State_Process : process(ARESET, CLK_TX)
    begin
        if ARESET = '1' then
            tx_state <= S_IDLE;
        elsif rising_edge(CLK_TX) then
            tx_state <= tx_next_state;
        end if;
    end process TX_State_Process;

    TX_State_Transition_Logic : process(tx_state, ARESET, SEND_MAC, DATA_ACK_TX, TX_CNT_EQ_41)
    begin
        case tx_state is

            when S_IDLE  =>

                TX_EN_CNT <= '0';
                SHOW_FIRST_BYTE <= '0';
                LD_DATA_OUT     <= '0';
                DATA_VALID_TX   <= '0';

                if (ARESET = '1') then
                    tx_next_state <= S_IDLE;
                elsif (SEND_MAC = '1') then
                    LD_DATA_OUT     <= '1';
                    tx_next_state <= S_SHOW_BYTE_WAIT_ACK_TX;
                else
                    tx_next_state <= S_IDLE;
                end if;

            when S_SHOW_BYTE_WAIT_ACK_TX =>

                TX_EN_CNT <= '0';
                SHOW_FIRST_BYTE <= '1';
                LD_DATA_OUT     <= '1';
                DATA_VALID_TX   <= '1';
                
                if (ARESET = '1') then
                    tx_next_state <= S_IDLE;
                elsif (DATA_ACK_TX = '1') then
                    TX_EN_CNT <= '1';
                    SHOW_FIRST_BYTE <= '0';
                    tx_next_state <= S_CONTINOUS_WRITE;
                else
                    tx_next_state <= S_SHOW_BYTE_WAIT_ACK_TX;
                end if;

            when S_CONTINOUS_WRITE =>
                
                TX_EN_CNT <= '1';
                SHOW_FIRST_BYTE <= '0';
                LD_DATA_OUT     <= '1';

                if (ARESET = '1' or TX_CNT_EQ_41 = '1') then
                    TX_EN_CNT <= '0';
                    LD_DATA_OUT     <= '0';
                    tx_next_state <= S_IDLE;
                else
                    tx_next_state <= S_CONTINOUS_WRITE;
                end if;
        end case;
    end process TX_State_Transition_Logic;
end BEHAVIORAL;
