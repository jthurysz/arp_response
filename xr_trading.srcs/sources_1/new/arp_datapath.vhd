----------------------------------------------
-- Create Date : 10/17/2019 12:36:12 PM
-- Design Name : arp_datapath.vhd
-- Engineer    : Joe Hurysz
--
-- Description : TO-DO
--
----------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ARP_DATAPATH is
    Port (ARESET : in std_logic;

          -- Static Signals
          MY_MAC        : in  std_logic_vector(47 downto 0);
          MY_IPV4       : in  std_logic_vector(31 downto 0);
        
          CLK_RX : in std_logic;
          DATA_RX: in std_logic_vector(7 downto 0);

          CLK_TX       : in std_logic;
          RX_CNT_EQ_41 : out std_logic;
          TX_CNT_EQ_41 : out std_logic;
          RX_EN_CNT    : in std_logic;
          TX_EN_CNT    : in std_logic;
          
          PARSE_DONE: in std_logic;
          SEND_MAC  : out std_logic);
end ARP_DATAPATH;

architecture BEHAVIORAL of ARP_DATAPATH is

    -- Constants
    constant C_CNTR_MAX : positive := 41;

    -- Signal Declarations
    signal rx_cntr_val      : unsigned(5 downto 0);
    signal tx_cntr_val      : unsigned(5 downto 0);

    signal cnt_lt_6      : std_logic;
    signal cnt_btw_5_12  : std_logic;
    signal cnt_eq_12_13  : std_logic;
    signal cnt_eq_14_15  : std_logic;
    signal cnt_eq_16_17  : std_logic;
    signal cnt_eq_18     : std_logic;
    signal cnt_eq_19     : std_logic;
    signal cnt_eq_20_21  : std_logic;
    signal cnt_btw_28_31 : std_logic;
    signal cnt_btw_38_41 : std_logic;

    signal broadcast     : std_logic_vector(47 downto 0);
    signal src_mac       : std_logic_vector(47 downto 0);
    signal frame_type    : std_logic_vector(15 downto 0);
    signal hw_type       : std_logic_vector(15 downto 0);
    signal proto_type    : std_logic_vector(15 downto 0);
    signal hw_len        : std_logic_vector(7  downto 0);
    signal proto_len     : std_logic_vector(7  downto 0);
    signal arp_type      : std_logic_vector(15 downto 0);
    signal src_ipv4      : std_logic_vector(31 downto 0);
    signal match_ipv4    : std_logic_vector(31 downto 0);

    signal broadcast_ltc     : std_logic_vector(47 downto 0);
    signal src_mac_ltc       : std_logic_vector(47 downto 0);
    signal frame_type_ltc    : std_logic_vector(15 downto 0);
    signal hw_type_ltc       : std_logic_vector(15 downto 0);
    signal proto_type_ltc    : std_logic_vector(15 downto 0);
    signal hw_len_ltc        : std_logic_vector(7  downto 0);
    signal proto_len_ltc     : std_logic_vector(7  downto 0);
    signal arp_type_ltc      : std_logic_vector(15 downto 0);
    signal src_ipv4_ltc      : std_logic_vector(31 downto 0);
    signal match_ipv4_ltc    : std_logic_vector(31 downto 0);

    signal send_mac_int  : std_logic;

begin

    ------ Recieve Logic ---------

    Rx_Counter_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            RX_CNT_EQ_41 <= '0';
            rx_cntr_val  <= to_unsigned(0, rx_cntr_val'length);
        elsif rising_edge(CLK_RX) then
            if (RX_EN_CNT = '1') then
                if (to_integer(rx_cntr_val) = C_CNTR_MAX) then
                    RX_CNT_EQ_41 <= '1';
                    rx_cntr_val  <= to_unsigned(0, rx_cntr_val'length);
                else
                    RX_CNT_EQ_41 <= '0';
                    rx_cntr_val  <= rx_cntr_val + 1;
                end if;
            end if;
        end if;
    end process Rx_Counter_Process;

    -- Outputs
    SEND_MAC <= send_mac_int;

    -- Comparators
    cnt_lt_6      <= '1' when (rx_cntr_val < 6) else '0';
    cnt_btw_5_12  <= '1' when (rx_cntr_val > 5 and rx_cntr_val < 12) else '0';
    cnt_eq_12_13  <= '1' when (rx_cntr_val = 12 or rx_cntr_val = 13) else '0';
    cnt_eq_14_15  <= '1' when (rx_cntr_val = 14 or rx_cntr_val = 15) else '0';
    cnt_eq_16_17  <= '1' when (rx_cntr_val = 16 or rx_cntr_val = 17) else '0';
    cnt_eq_18     <= '1' when (rx_cntr_val = 18) else '0';
    cnt_eq_19     <= '1' when (rx_cntr_val = 19) else '0';
    cnt_eq_20_21  <= '1' when (rx_cntr_val = 20 or rx_cntr_val = 21) else '0';
    cnt_btw_28_31 <= '1' when (rx_cntr_val > 27 and rx_cntr_val < 32) else '0';
    cnt_btw_38_41 <= '1' when (rx_cntr_val > 37 and rx_cntr_val < 42) else '0';

    Broadcast_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            broadcast <= (others => '0');
        elsif rising_edge(CLK_RX) then
            if (cnt_lt_6 = '1' and RX_EN_CNT = '1') then
                broadcast <= broadcast(39 downto 0) & DATA_RX(7 downto 0);
            end if;
        end if;
    end process Broadcast_Process;

    Src_Mac_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            src_mac <= (others => '0');
        elsif rising_edge(CLK_RX) then
            if (cnt_btw_5_12 = '1') then
                src_mac <= src_mac(39 downto 0) & DATA_RX(7 downto 0);
            end if;
        end if;
    end process Src_Mac_Process;

    Frame_Type_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            frame_type <= (others => '0');
        elsif rising_edge(CLK_RX) then
            if (cnt_eq_12_13 = '1') then
                frame_type <= frame_type(7 downto 0) & DATA_RX(7 downto 0);
            end if;
        end if;
    end process Frame_Type_Process;

    HW_Type_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            hw_type <= (others => '0');
        elsif rising_edge(CLK_RX) then
            if (cnt_eq_14_15 = '1') then
                hw_type <= hw_type(7 downto 0) & DATA_RX(7 downto 0);
            end if;
        end if;
    end process HW_Type_Process;

    Proto_Type_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            proto_type <= (others => '0');
        elsif rising_edge(CLK_RX) then
            if (cnt_eq_16_17 = '1') then
                proto_type <= proto_type(7 downto 0) & DATA_RX(7 downto 0);
            end if;
        end if;
    end process Proto_Type_Process;

    HW_Len_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            hw_len <= (others => '0');
        elsif rising_edge(CLK_RX) then
            if (cnt_eq_18 = '1') then
                hw_len <= DATA_RX(7 downto 0);
            end if;
        end if;
    end process HW_Len_Process;

    Proto_Len_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            proto_len <= (others => '0');
        elsif rising_edge(CLK_RX) then
            if (cnt_eq_19 = '1') then
                proto_len <= DATA_RX(7 downto 0);
            end if;
        end if;
    end process Proto_Len_Process;

    Arp_Type_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            arp_type <= (others => '0');
        elsif rising_edge(CLK_RX) then
            if (cnt_eq_20_21 = '1') then
                arp_type <= arp_type(7 downto 0) & DATA_RX(7 downto 0);
            end if;
        end if;
    end process Arp_Type_Process;

    Src_Ipv4_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            src_ipv4 <= (others => '0');
        elsif rising_edge(CLK_RX) then
            if (cnt_btw_28_31 = '1') then
                src_ipv4 <= src_ipv4(23 downto 0) & DATA_RX(7 downto 0);
            end if;
        end if;
    end process Src_Ipv4_Process;

    Match_Ipv4_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            match_ipv4 <= (others => '0');
        elsif rising_edge(CLK_RX) then
            if (cnt_btw_38_41 = '1') then
                match_ipv4 <= match_ipv4(23 downto 0) & DATA_RX(7 downto 0);
            end if;
        end if;
    end process Match_Ipv4_Process;

    Response_Arbiter_Process : process(ARESET, CLK_RX) 
    begin
        if (ARESET = '1') then
            send_mac_int <= '0';
        elsif rising_edge(CLK_RX) then
            if (PARSE_DONE = '1') then
                if (broadcast = x"FFFFFFFFFFFF") then
                    if (frame_type = x"0806") then
                        if (hw_type = x"0001" and proto_type = x"0800") then
                            if (hw_len = x"06" and proto_len = x"04") then
                                if (arp_type = x"0001") then
                                    if (match_ipv4 = MY_IPV4) then
                                        send_mac_int <= '1';
                                    end if;
                                end if;
                           end if;
                        end if;
                    end if;    
                end if;
            else
                send_mac_int <= '0';
            end if;
        end if;
    end process Response_Arbiter_Process;

    Latch_Registers_For_Tx_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            broadcast_ltc     <= (others => '0');
            src_mac_ltc       <= (others => '0');
            frame_type_ltc    <= (others => '0');
            hw_type_ltc       <= (others => '0');
            proto_type_ltc    <= (others => '0');
            hw_len_ltc        <= (others => '0');
            proto_len_ltc     <= (others => '0');
            arp_type_ltc      <= (others => '0');
            src_ipv4_ltc      <= (others => '0');
            match_ipv4_ltc    <= (others => '0');
        elsif rising_edge(CLK_RX) then
            if (send_mac_int = '1') then
                broadcast_ltc     <= broadcast;
                src_mac_ltc       <= src_mac;
                frame_type_ltc    <= frame_type;
                hw_type_ltc       <= hw_type;
                proto_type_ltc    <= proto_type;
                hw_len_ltc        <= hw_len;
                proto_len_ltc     <= proto_len;
                arp_type_ltc      <= arp_type;
                src_ipv4_ltc      <= src_ipv4;
                match_ipv4_ltc    <= match_ipv4;
            end if;
        end if;
    end process Latch_Registers_For_Tx_Process;

    ------ Transmit Logic ---------

    Tx_Counter_Process : process(ARESET, CLK_TX)
    begin
        if (ARESET = '1') then
            TX_CNT_EQ_41 <= '0';
            tx_cntr_val  <= to_unsigned(1, tx_cntr_val'length);
        elsif rising_edge(CLK_TX) then
            if (TX_EN_CNT = '1') then
                if (to_integer(tx_cntr_val) = C_CNTR_MAX) then
                    TX_CNT_EQ_41 <= '1';
                    tx_cntr_val  <= to_unsigned(1, tx_cntr_val'length);
                else
                    TX_CNT_EQ_41 <= '0';
                    tx_cntr_val  <= tx_cntr_val + 1;
                end if;
            end if;
        end if;
    end process Tx_Counter_Process;

end BEHAVIORAL;
