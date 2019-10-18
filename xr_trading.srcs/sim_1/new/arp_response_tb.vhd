----------------------------------------------
-- Create Date : 10/17/2019 12:36:12 PM
-- Design Name : arp_response_tb.vhd
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

entity ARP_RESPONSE_TB is
end ARP_RESPONSE_TB;

architecture TESTBENCH of ARP_RESPONSE_TB is

    component ARP_RESPONSE
        port (ARESET        : in  std_logic;
     
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
    end component ARP_RESPONSE;

    -- Constants
    constant C_CLK_PERIOD    : time := 8 ns; -- 125 MHz Frequency

    constant C_MY_IPV4         : std_logic_vector(31 downto 0) := x"C0A80102";
    constant C_NOT_MY_IPV4     : std_logic_vector(31 downto 0) := x"C0A80108";
    constant C_MY_MAC          : std_logic_vector(47 downto 0) := x"000223010203";
    constant C_ARP_BROADCAST   : std_logic_vector(47 downto 0) := x"FFFFFFFFFFFF";
    constant C_ETH_SRC_MAC     : std_logic_vector(47 downto 0) := x"000142005F68";
    constant C_ETH_SRC_IPV4    : std_logic_vector(31 downto 0) := x"C0A80101";
    constant C_FRAME_TYPE      : std_logic_vector(15 downto 0) := x"0806";
    constant C_HARDWARE_TYPE   : std_logic_vector(15 downto 0) := x"0001";
    constant C_PROTOCOL_TYPE   : std_logic_vector(15 downto 0) := x"0800";
    constant C_HARDWARE_LEN    : std_logic_vector(7  downto 0) := x"06";
    constant C_PROTOCOL_LEN    : std_logic_vector(7  downto 0) := x"04";
    constant C_ARP_REQUEST     : std_logic_vector(15 downto 0) := x"0001";
    constant C_ARP_REPLY       : std_logic_vector(15 downto 0) := x"0002";

    constant C_ARP_REQ_SUCCESS : std_logic_vector(335 downto 0) := C_ARP_BROADCAST & C_ETH_SRC_MAC   & C_FRAME_TYPE
                                                                &  C_HARDWARE_TYPE & C_PROTOCOL_TYPE & C_HARDWARE_LEN
                                                                &  C_PROTOCOL_LEN  & C_ARP_REQUEST   & C_ETH_SRC_MAC
                                                                &  C_ETH_SRC_IPV4  & x"000000000000" & C_MY_IPV4;
    
    constant C_ARP_REQ_FAIL : std_logic_vector(335 downto 0) := C_ARP_BROADCAST & C_ETH_SRC_MAC   & C_FRAME_TYPE
                                                                &  C_HARDWARE_TYPE & C_PROTOCOL_TYPE & C_HARDWARE_LEN
                                                                &  C_PROTOCOL_LEN  & C_ARP_REQUEST   & C_ETH_SRC_MAC
                                                                &  C_ETH_SRC_IPV4  & x"000000000000" & C_NOT_MY_IPV4;

    -- Testbench Signals
    signal ARESET        : std_logic := '0';
    signal MY_MAC        : std_logic_vector(47 downto 0);
    signal MY_IPV4       : std_logic_vector(31 downto 0);
    signal CLK_RX        : std_logic := '0';
    signal DATA_VALID_RX : std_logic := '0';
    signal DATA_RX       : std_logic_vector(7 downto 0);
    signal CLK_TX        : std_logic := '0';
    signal DATA_VALID_TX : std_logic := '0';
    signal DATA_TX       : std_logic_vector(7 downto 0);
    signal DATA_ACK_TX   : std_logic := '0';


begin

    -- Instantiate Unit Under Test
    UUT : ARP_RESPONSE
    port map (ARESET        => ARESET,
              MY_MAC        => MY_MAC,
              MY_IPV4       => MY_IPV4,
              CLK_RX        => CLK_RX,
              DATA_VALID_RX => DATA_VALID_RX,
              DATA_RX       => DATA_RX,
              CLK_TX        => CLK_TX,
              DATA_VALID_TX => DATA_VALID_TX,
              DATA_TX       => DATA_TX,
              DATA_ACK_TX   => DATA_ACK_TX);

    -- Set-up Clock(s)
    CLK_RX  <= not CLK_RX after C_CLK_PERIOD/2;
    CLK_TX  <= not CLK_TX after C_CLK_PERIOD/2;

    -- Static MAC/IP Initialization
    MY_IPV4 <= C_MY_IPV4;
    MY_MAC  <= C_MY_MAC;

    -- Provide UUT stimulus
    ARP_STIMULUS : process
    begin

        -- Reset Module
        ARESET <= '1';
        wait for C_CLK_PERIOD*10;
        ARESET <= '0';
        wait for C_CLK_PERIOD*2;

        -- start failed ARP request
        wait until rising_edge(CLK_RX);
        DATA_VALID_RX <= '1';
        for i in 41 downto 0 loop
            DATA_RX <= C_ARP_REQ_FAIL((((i+1)*8)-1) downto i*8);
            wait until rising_edge(CLK_RX);
        end loop;
        DATA_VALID_RX <= '0';
        DATA_RX       <= (others => 'U');

        -- start succesful request w/ARESET in middle
        wait for C_CLK_PERIOD*5;
        wait until rising_edge(CLK_RX);
        DATA_VALID_RX <= '1';
        for i in 41 downto 20 loop
            DATA_RX <= C_ARP_REQ_SUCCESS((((i+1)*8)-1) downto i*8);
            wait until rising_edge(CLK_RX);
        end loop;
        DATA_VALID_RX <= '0';
        DATA_RX       <= (others => 'U');

        ARESET <= '1';
        wait for C_CLK_PERIOD;
        ARESET <= '0';
        
        -- Start succesful ARP Request
        wait for C_CLK_PERIOD*5;
        wait until rising_edge(CLK_RX);
        DATA_VALID_RX <= '1';
        for i in 41 downto 0 loop
            DATA_RX <= C_ARP_REQ_SUCCESS((((i+1)*8)-1) downto i*8);
            wait until rising_edge(CLK_RX);
        end loop;
        DATA_VALID_RX <= '0';
        DATA_RX       <= (others => 'U');

        -- send DATA_ACK_TX
        wait for C_CLK_PERIOD*10;
        wait until rising_edge(CLK_TX);
        DATA_ACK_TX <= '1';
        wait until rising_edge(CLK_TX);
        DATA_ACK_TX <= '0';
        
        wait for C_CLK_PERIOD*20;

        wait;
    end process;



end TESTBENCH;
