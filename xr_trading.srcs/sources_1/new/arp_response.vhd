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

begin


end BEHAVIORAL;
