----------------------------------------------
-- Create Date : 10/17/2019 12:36:12 PM
-- Design Name : arp_response.vhd
-- Engineer    : Joe Hurysz
--
-- Description : Toplevel ARP Response Design
--               Connects down to separate
--               controller and datapath modules
--
--
--
--   ** Written in VHDL **
--   ** Experience with Verilog though as well **
--
----------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;

entity ARP_RESPONSE is
    Port ( ARESET        : in  std_logic;
     
           -- Static Signals
           MY_MAC        : in  std_logic_vector(47 downto 0);
           MY_IPV4       : in  std_logic_vector(31 downto 0);
           
           -- Recieve Signals
           CLK_RX        : in  std_logic;
           DATA_VALID_RX : in  std_logic;
           DATA_RX       : in  std_logic_vector(7 downto 0);
           
           -- Transmit Signals
           CLK_TX        : in  std_logic;
           DATA_VALID_TX : out std_logic;
           DATA_TX       : out std_logic_vector(7 downto 0);
           DATA_ACK_TX   : in  std_logic);
end ARP_RESPONSE;

architecture BEHAVIORAL of ARP_RESPONSE is

    -- Component Instantions
    component ARP_CONTROLLER
        port (ARESET          : in  std_logic;
              CLK_RX          : in  std_logic;
              DATA_VALID_RX   : in  std_logic;
              DATA_ACK_TX     : in  std_logic;
              DATA_VALID_TX   : out std_logic;
              CLK_TX          : in  std_logic;
              RX_CNT_EQ_41    : in  std_logic;
              TX_CNT_EQ_41    : in  std_logic;
              RX_EN_CNT       : out std_logic;
              TX_EN_CNT       : out std_logic;
              PARSE_DONE      : out std_logic;
              SEND_MAC        : in  std_logic;
              SHOW_FIRST_BYTE : out std_logic;
              LD_DATA_OUT     : out std_logic);
    end component ARP_CONTROLLER;

    component ARP_DATAPATH
        port (ARESET          : in  std_logic;
              MY_MAC          : in  std_logic_vector(47 downto 0);
              MY_IPV4         : in  std_logic_vector(31 downto 0);
              CLK_RX          : in  std_logic;
              DATA_RX         : in  std_logic_vector(7 downto 0);
              DATA_TX         : out std_logic_vector(7 downto 0);
              CLK_TX          : in  std_logic;
              RX_CNT_EQ_41    : out std_logic;
              TX_CNT_EQ_41    : out std_logic;
              RX_EN_CNT       : in  std_logic;
              TX_EN_CNT       : in  std_logic;
              PARSE_DONE      : in  std_logic;
              SEND_MAC        : out std_logic;
              SHOW_FIRST_BYTE : in  std_logic;
              LD_DATA_OUT     : in  std_logic);
    end component ARP_DATAPATH;

    -- Controller/Datapath Interconnections
    signal rx_en_cnt       : std_logic;
    signal tx_en_cnt       : std_logic;
    signal rx_cnt_eq_41    : std_logic;
    signal tx_cnt_eq_41    : std_logic;
    signal parse_done      : std_logic;
    signal send_mac        : std_logic;
    signal show_first_byte : std_logic;
    signal ld_data_out     : std_logic;

begin

    Controller : ARP_CONTROLLER
    port map (ARESET          => ARESET,
              CLK_RX          => CLK_RX,
              DATA_VALID_RX   => DATA_VALID_RX,
              CLK_TX          => CLK_TX,
              DATA_ACK_TX     => DATA_ACK_TX,
              DATA_VALID_TX   => DATA_VALID_TX,
              RX_CNT_EQ_41    => rx_cnt_eq_41,
              TX_CNT_EQ_41    => tx_cnt_eq_41,
              RX_EN_CNT       => rx_en_cnt,
              TX_EN_CNT       => tx_en_cnt,
              PARSE_DONE      => parse_done,
              SEND_MAC        => send_mac,
              SHOW_FIRST_BYTE => show_first_byte,
              LD_DATA_OUT     => ld_data_out);

    Datapath : ARP_DATAPATH
    port map (ARESET          => ARESET,
              MY_MAC          => MY_MAC,
              MY_IPV4         => MY_IPV4,
              CLK_RX          => CLK_RX,
              DATA_RX         => DATA_RX,
              DATA_TX         => DATA_TX,
              CLK_TX          => CLK_TX,
              RX_CNT_EQ_41    => rx_cnt_eq_41,
              TX_CNT_EQ_41    => tx_cnt_eq_41,
              RX_EN_CNT       => rx_en_cnt,
              TX_EN_CNT       => tx_en_cnt,
              PARSE_DONE      => parse_done,
              SEND_MAC        => send_mac,
              SHOW_FIRST_BYTE => show_first_byte,
              LD_DATA_OUT     => ld_data_out);

end BEHAVIORAL;