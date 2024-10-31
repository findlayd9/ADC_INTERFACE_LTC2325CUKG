-- ================================================
--
--  FILE:           TB_ADC_INTERFACE_LTC2325CUKG
--  DESCRIPTION:    Testbench for the TB_ADC_INTERFACE_LTC2325CUKG module
--
--  =======================
--  CHANGES:
--  
--  Author:     ChatGPT
--  DATE:       31/10/2024  
--  CHANGE:     Initial version
-- ================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_ADC_INTERFACE_LTC2325CUKG is
end tb_ADC_INTERFACE_LTC2325CUKG;

architecture TB_ARCH of tb_ADC_INTERFACE_LTC2325CUKG is
    -- Component declaration for the unit under test
    component ADC_INTERFACE_LTC2325CUKG
        port(
            CLK_IN:     in std_logic;
            N_RST_IN:   in std_logic;

            SDOA_IN:    in std_logic;
            SDOB_IN:    in std_logic;
            SDOC_IN:    in std_logic;
            SDOD_IN:    in std_logic;

            ADC_CLK_IN: in std_logic;

            SCLK_OUT:   out std_logic;
            CNV_OUT:    out std_logic;

            CHA_OUT:    out std_logic_vector(12 downto 0);
            CHB_OUT:    out std_logic_vector(12 downto 0);
            CHC_OUT:    out std_logic_vector(12 downto 0);
            CHD_OUT:    out std_logic_vector(12 downto 0);

            SAMP_VALID_OUT: out std_logic
        );
    end component;

    -- Testbench signals
    signal CLK_IN_tb: std_logic := '0';
    signal N_RST_IN_tb: std_logic := '1';
    signal SDOA_IN_tb: std_logic := '0';
    signal SDOB_IN_tb: std_logic := '0';
    signal SDOC_IN_tb: std_logic := '0';
    signal SDOD_IN_tb: std_logic := '0';
    signal ADC_CLK_IN_tb: std_logic := '0';
    
    signal SCLK_OUT_tb: std_logic;
    signal CNV_OUT_tb: std_logic;
    signal CHA_OUT_tb: std_logic_vector(12 downto 0);
    signal CHB_OUT_tb: std_logic_vector(12 downto 0);
    signal CHC_OUT_tb: std_logic_vector(12 downto 0);
    signal CHD_OUT_tb: std_logic_vector(12 downto 0);

    signal SAMP_VALID_OUT_tb:   std_logic;
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: ADC_INTERFACE_LTC2325CUKG
        port map (
            CLK_IN     => CLK_IN_tb,
            N_RST_IN   => N_RST_IN_tb,
            SDOA_IN    => SDOA_IN_tb,
            SDOB_IN    => SDOB_IN_tb,
            SDOC_IN    => SDOC_IN_tb,
            SDOD_IN    => SDOD_IN_tb,
            ADC_CLK_IN => ADC_CLK_IN_tb,
            SCLK_OUT   => SCLK_OUT_tb,
            CNV_OUT    => CNV_OUT_tb,
            CHA_OUT    => CHA_OUT_tb,
            CHB_OUT    => CHB_OUT_tb,
            CHC_OUT    => CHC_OUT_tb,
            CHD_OUT    => CHD_OUT_tb,
            SAMP_VALID_OUT   => SAMP_VALID_OUT_tb
        );

    -- Clock generation process
    CLK_GEN: process
    begin
        CLK_IN_tb <= '0';
        wait for CLK_PERIOD/2;
        CLK_IN_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Test sequence process
    STIMULUS: process
    begin
        -- Initial reset
        N_RST_IN_tb <= '1';
        wait for 20 ns;
        
        -- Deassert reset
        N_RST_IN_tb <= '0';
        wait for 20 ns;

        -- Observe behavior for a few clock cycles
        wait for 200 ns;
        
        -- Fiddle the serial inputs to spoof ADC change 
        SDOA_IN_tb <= '1';
        SDOB_IN_tb <= '0';
        SDOC_IN_tb <= '1';
        SDOD_IN_tb <= '0';

        -- Observe behavior for a few more clock cycles
        wait for 200 ns;

        -- Stop simulation
        wait;
    end process STIMULUS;

end TB_ARCH;
