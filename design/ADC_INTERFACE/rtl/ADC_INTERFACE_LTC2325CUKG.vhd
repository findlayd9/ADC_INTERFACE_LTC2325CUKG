-- ================================================
--
--  MODULE:         ADC_INTERFACE_LTC2325CUKG
--  DESCRIPTION:    The module acts as an interface to the LTC2325CUKG ADC chip
--
--  =======================
--  CHANGES:
--  
--  Author:     Findlay Dougall
--  DATE:       31/10/2024  
--  CHANGE:     Initial version
-- ================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity ADC_INTERFACE_LTC2325CUKG is
    port(
        CLK_IN:     in std_logic;
        N_RST_IN:   in std_logic;

        -- ADC Channels
        SDOA_IN:    in std_logic;
        SDOB_IN:    in std_logic;
        SDOC_IN:    in std_logic;
        SDOD_IN:    in std_logic;

        ADC_CLK_IN: in std_logic;

        -- ADC Control
        SCLK_OUT:   out std_logic;        
        CNV_OUT:    out std_logic;

        -- Sampled channels
        CHA_OUT:    out std_logic_vector(12 downto 0);
        CHB_OUT:    out std_logic_vector(12 downto 0);
        CHC_OUT:    out std_logic_vector(12 downto 0);
        CHD_OUT:    out std_logic_vector(12 downto 0);
        -- New Sample flag
        SAMP_VALID_OUT: out std_logic
    );
end ADC_INTERFACE_LTC2325CUKG;




architecture ADC_INTERFACE_LTC2325CUKG_ARCH of ADC_INTERFACE_LTC2325CUKG is

    -- Definition of states used in ADC
    type STATE_TYPE is (RESET,
        ACQUIRE_1,
        ACQUIRE_2,
        ACQUIRE_3,
        CONV_1,
        CONV_2,
        CONV_3,
        CONV_4,
        CONV_5,
        CONV_6,
        CONV_7,
        CONV_8,
        CONV_9,
        CONV_10,
        CONV_11,
        CONV_12,
        CONV_13,
        CONV_14,
        CONV_15
        );

    -- Signal definitions
    signal STATE:       STATE_TYPE;
    signal NEXT_STATE:  STATE_TYPE;

    -- Channel data signals
    signal CH_A_DATA:       std_logic_vector(12 downto 0);
    signal CH_B_DATA:       std_logic_vector(12 downto 0);
    signal CH_C_DATA:       std_logic_vector(12 downto 0);
    signal CH_D_DATA:       std_logic_vector(12 downto 0);
    signal NEXT_CH_A_DATA:   std_logic_vector(12 downto 0);
    signal NEXT_CH_B_DATA:   std_logic_vector(12 downto 0);
    signal NEXT_CH_C_DATA:   std_logic_vector(12 downto 0);
    signal NEXT_CH_D_DATA:   std_logic_vector(12 downto 0);

    -- Fully converted channel data
    signal CH_A_DATA_VALID:         std_logic_vector(12 downto 0);
    signal CH_B_DATA_VALID:         std_logic_vector(12 downto 0);
    signal CH_C_DATA_VALID:         std_logic_vector(12 downto 0);
    signal CH_D_DATA_VALID:         std_logic_vector(12 downto 0);
    signal NEXT_CH_A_DATA_VALID:    std_logic_vector(12 downto 0);
    signal NEXT_CH_B_DATA_VALID:    std_logic_vector(12 downto 0);
    signal NEXT_CH_C_DATA_VALID:    std_logic_vector(12 downto 0);
    signal NEXT_CH_D_DATA_VALID:    std_logic_vector(12 downto 0);

    signal SAMP_VALID:             std_logic;         
    signal NEXT_SAMP_VALID:        std_logic; 

begin


-- Set outputs
SAMP_VALID_OUT  <= SAMP_VALID;
CHA_OUT         <= CH_A_DATA_VALID;
CHB_OUT         <= CH_B_DATA_VALID;
CHC_OUT         <= CH_C_DATA_VALID;
CHD_OUT         <= CH_D_DATA_VALID;

-- -------------------------------
-- Process to register various signals within module
REG: process(CLK_IN,N_RST_IN)
begin
    -- During reset, set to know state
    if(N_RST_IN = '1') then

        STATE <= RESET;
        CH_A_DATA   <= (others =>'0');
        CH_B_DATA   <= (others =>'0');
        CH_C_DATA   <= (others =>'0');
        CH_D_DATA   <= (others =>'0');

        -- Set to all 1's before first valid sample to make it easier to distinguish
        CH_A_DATA_VALID <= (others =>'1');
        CH_B_DATA_VALID <= (others =>'1');
        CH_C_DATA_VALID <= (others =>'1');
        CH_D_DATA_VALID <= (others =>'1');

        SAMP_VALID  <= '0';

    -- On clock rising edge
    elsif(rising_edge(CLK_IN)) then

        STATE       <= NEXT_STATE;
        CH_A_DATA   <= NEXT_CH_A_DATA;
        CH_B_DATA   <= NEXT_CH_B_DATA;
        CH_C_DATA   <= NEXT_CH_C_DATA;
        CH_D_DATA   <= NEXT_CH_D_DATA;
        SAMP_VALID  <= NEXT_SAMP_VALID;

        CH_A_DATA_VALID <= NEXT_CH_A_DATA_VALID;
        CH_B_DATA_VALID <= NEXT_CH_B_DATA_VALID;
        CH_C_DATA_VALID <= NEXT_CH_C_DATA_VALID;
        CH_D_DATA_VALID <= NEXT_CH_D_DATA_VALID;

    end if;
end process REG; 

-- -------------------------------
-- Process to control state machine
STATE_PROC: process(CLK_IN,STATE)
begin
    NEXT_STATE <= STATE;
    if(N_RST_IN = '0') then
        case STATE is
            when RESET => 
                NEXT_STATE <= ACQUIRE_1;
            -- SIGNAL ACQUISITION
            when ACQUIRE_1 =>
                NEXT_STATE <= ACQUIRE_2;
            when ACQUIRE_2 =>
                NEXT_STATE <= ACQUIRE_3;
            when ACQUIRE_3 =>
                NEXT_STATE <= CONV_1;
            -- CONVERSION STATES
            when CONV_1 => 
                NEXT_STATE <= CONV_2;
            when CONV_2 =>
                NEXT_STATE <= CONV_3;
            when CONV_3 =>
                NEXT_STATE <= CONV_4;
            when CONV_4 =>
                NEXT_STATE <= CONV_5;  
            when CONV_5 => 
                NEXT_STATE <= CONV_6;
            when CONV_6 =>
                NEXT_STATE <= CONV_7;
            when CONV_7 =>
                NEXT_STATE <= CONV_8;
            when CONV_8 =>
                NEXT_STATE <= CONV_9;
            when CONV_9 => 
                NEXT_STATE <= CONV_10;
            when CONV_10 =>
                NEXT_STATE <= CONV_11;
            when CONV_11 =>
                NEXT_STATE <= CONV_12;
            when CONV_12 =>
                NEXT_STATE <= CONV_13;
            -- NULL CONVERSION STATES
            when CONV_13 => 
                NEXT_STATE <= CONV_14;
            when CONV_14 =>
                NEXT_STATE <= CONV_15;
            when CONV_15 =>
                NEXT_STATE <= ACQUIRE_1;
        end case;   
    end if;

end process STATE_PROC;     
   
-- -------------------------------
-- Process to control the ADC 
ADC_CONTROL: process(STATE, CLK_IN)
begin
    -- Default values for outputs
    SCLK_OUT    <= '0';  
    CNV_OUT     <= '0';   
    
    case STATE is
        when RESET => 

            SCLK_OUT    <= '0';
            CNV_OUT     <= '0';

        when ACQUIRE_1 | ACQUIRE_2 | ACQUIRE_3 =>

            SCLK_OUT    <= '0';
            CNV_OUT     <= '1';

        when CONV_1 | CONV_2 | CONV_3 | CONV_4 | CONV_5 | CONV_6 | CONV_7 | CONV_8 |
            CONV_9 | CONV_10 | CONV_11 | CONV_12 | CONV_13 | CONV_14 | CONV_15 =>

            CNV_OUT     <= '0';
            SCLK_OUT    <= CLK_IN; -- tie to module clock for conversion and readout
    end case;  

end process ADC_CONTROL;  

-- -------------------------------
-- Process to read the data from the ADC once sampled 
READ_CHANNEL: process(CLK_IN, N_RST_IN)
begin

    NEXT_CH_A_DATA <= CH_A_DATA;
    NEXT_CH_B_DATA <= CH_B_DATA;
    NEXT_CH_C_DATA <= CH_C_DATA;
    NEXT_CH_D_DATA <= CH_D_DATA;

    case STATE is

        when CONV_1 | CONV_2 | CONV_3 | CONV_4 | CONV_5 | CONV_6 | CONV_7 | CONV_8 |
            CONV_9 | CONV_10 | CONV_11 | CONV_12  =>

            NEXT_CH_A_DATA <= CH_A_DATA(11 downto 0) & SDOA_IN;
            NEXT_CH_B_DATA <= CH_B_DATA(11 downto 0) & SDOB_IN;
            NEXT_CH_C_DATA <= CH_C_DATA(11 downto 0) & SDOC_IN;
            NEXT_CH_D_DATA <= CH_D_DATA(11 downto 0) & SDOD_IN;

        when CONV_15 => 
            -- Wait till full Readout finishes before stating sample as valid
            NEXT_SAMP_VALID <= '1';

        when others =>
            NEXT_SAMP_VALID <= '0';

    end case;  

end process READ_CHANNEL;  

-- -------------------------------
-- Process to capture data fully read from ADC
CHAN_REG_PROC: process(SAMP_VALID ) 
begin
    NEXT_CH_A_DATA_VALID <= CH_A_DATA_VALID;
    NEXT_CH_B_DATA_VALID <= CH_B_DATA_VALID;
    NEXT_CH_C_DATA_VALID <= CH_C_DATA_VALID;
    NEXT_CH_D_DATA_VALID <= CH_D_DATA_VALID;

    -- If data fully sampled, set channel data signal
    if(SAMP_VALID = '1') then
        NEXT_CH_A_DATA_VALID <= CH_A_DATA;
        NEXT_CH_B_DATA_VALID <= CH_B_DATA;
        NEXT_CH_C_DATA_VALID <= CH_C_DATA;
        NEXT_CH_D_DATA_VALID <= CH_D_DATA;
    end if;

end process CHAN_REG_PROC;



end ADC_INTERFACE_LTC2325CUKG_ARCH;