----------------------------------------------
-- Create Date : 10/17/2019 12:36:12 PM
-- Design Name : arp_response.vhd
-- Engineer    : Joe Hurysz
--
-- Description : TO-DO
--
----------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

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
        port (ARESET        : in std_logic;
              
              CLK_RX        : in std_logic;
              DATA_VALID_RX : in std_logic;
              
              CNT_EQ_41     : in std_logic;
              EN_CNT        : out std_logic);
    end component ARP_CONTROLLER;

    component ARP_DATAPATH
        port (ARESET        : in std_logic;
                
              CLK_RX        : in std_logic;
              DATA_RX       : in std_logic_vector(7 downto 0);
              
              CNT_EQ_41     : out std_logic;
              EN_CNT        : in std_logic);
    end component ARP_DATAPATH;

    -- Constants

    -- Controller/Datapath Interconnections
    signal en_cnt    : std_logic;
    signal CNT_EQ_41 : std_logic;

begin

    Controller : ARP_CONTROLLER
    port map (ARESET => ARESET,
              CLK_RX => CLK_RX,
              DATA_VALID_RX => DATA_VALID_RX,
              CNT_EQ_41     => CNT_EQ_41,
              EN_CNT        => en_cnt);

    Datapath : ARP_DATAPATH
    port map (ARESET => ARESET,
              CLK_RX => CLK_RX,
              DATA_RX => DATA_RX,
              CNT_EQ_41     => CNT_EQ_41,
              EN_CNT        => en_cnt);

end BEHAVIORAL;
