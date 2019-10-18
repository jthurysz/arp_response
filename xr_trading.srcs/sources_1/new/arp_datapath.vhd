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
        
          CLK_RX : in std_logic;
          DATA_RX: in std_logic_vector(7 downto 0);

          CNT_EQ_41 : out std_logic;
          EN_CNT : in std_logic);
end ARP_DATAPATH;

architecture BEHAVIORAL of ARP_DATAPATH is

    -- Constants
    constant C_CNTR_MAX : positive := 41;

    -- Signal Declarations
    signal cntr_val      : unsigned(5 downto 0);

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

begin

    Counter_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            CNT_EQ_41 <= '0';
            cntr_val  <= to_unsigned(0, cntr_val'length);
        elsif rising_edge(CLK_RX) then
            if (EN_CNT = '1') then
                if (to_integer(cntr_val) = C_CNTR_MAX) then
                    CNT_EQ_41 <= '1';
                    cntr_val  <= to_unsigned(0, cntr_val'length);
                else
                    CNT_EQ_41 <= '0';
                    cntr_val  <= cntr_val + 1;
                end if;
            end if;
        end if;
    end process Counter_Process;

    -- Comparators
    cnt_lt_6      <= '1' when (cntr_val < 6) else '0';
    cnt_btw_5_12  <= '1' when (cntr_val > 5 and cntr_val < 12) else '0';
    cnt_eq_12_13  <= '1' when (cntr_val = 12 or cntr_val = 13) else '0';
    cnt_eq_14_15  <= '1' when (cntr_val = 14 or cntr_val = 15) else '0';
    cnt_eq_16_17  <= '1' when (cntr_val = 16 or cntr_val = 17) else '0';
    cnt_eq_18     <= '1' when (cntr_val = 18) else '0';
    cnt_eq_19     <= '1' when (cntr_val = 19) else '0';
    cnt_eq_20_21  <= '1' when (cntr_val = 20 or cntr_val = 21) else '0';
    cnt_btw_28_31 <= '1' when (cntr_val > 27 and cntr_val < 32) else '0';
    cnt_btw_38_41 <= '1' when (cntr_val > 37 and cntr_val < 42) else '0';

    Broadcast_Process : process(ARESET, CLK_RX)
    begin
        if (ARESET = '1') then
            broadcast <= (others => '0');
        elsif rising_edge(CLK_RX) then
            if (cnt_lt_6 = '1' and EN_CNT = '1') then
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

end BEHAVIORAL;
