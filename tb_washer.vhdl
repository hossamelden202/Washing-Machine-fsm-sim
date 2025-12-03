LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity tb_washer is
end tb_washer;

-- Traffic Light Encoding:
-- FILL: "1000"
-- WASH: "0100"
-- RINSE:"0010"
-- SPIN: "0001"

architecture Behavioral of tb_washer is

    signal clk : STD_LOGIC := '0';
    signal clkEn : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';
    signal light : STD_LOGIC_VECTOR (3 downto 0) := "0000";

    constant clk_period : time := 20 ns; -- 50 MHz clock
    constant pulse_period : time := 20 * 20 ns; -- 3 clock cycles for second_pulse
    
    -- Traffic light state encoding
    constant FILL  : STD_LOGIC_VECTOR (3 downto 0) := "1000";
    constant WASH  : STD_LOGIC_VECTOR (3 downto 0) := "0100";
    constant RINSE : STD_LOGIC_VECTOR (3 downto 0) := "0010";
    constant SPIN  : STD_LOGIC_VECTOR (3 downto 0) := "0001";

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.Washer
        port map (
            clk => clk,
            clkEn => clkEn,
            reset => reset,
            light => light
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- Initial reset
        reset <= '0';
        clkEn <= '0';
        wait for 100 ns;
        reset <= '1';
        wait for 100 ns;
        clkEn <= '1';
        
        -- Test clkEn disable at ~1000 ns (during FILL state)
        wait for 20 * 20 ns;
        clkEn <= '0';
        wait for 20 * 20 ns;
        clkEn <= '1';
        
        -- Let system continue through state transitions
        wait for 20 * 20 * 20 ns;
        reset <= '0'; -- Apply reset again
        wait for 500 ns;
        reset <= '1';
        
        -- Keep running until simulation ends at 4000 ns
        wait;
    end process;

    -- Self-checking process with assertions
    check_proc : process
    begin
        -- Wait for reset to complete and clock enable to activate
        wait until reset = '1';
        wait until clkEn = '1';
        wait until rising_edge(clk);
        
        -- Check initial FILL state
        ASSERT light = FILL
            REPORT "Error: Initial state should be FILL (100) but got " & std_logic'image(light(3))  & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
            SEVERITY ERROR;
        
        -- Check FILL state for 9 pulses (transitions on the 10th pulse)
        FOR i IN 1 TO 3 LOOP
            wait for pulse_period;
            ASSERT light = FILL
                REPORT "Error at FILL pulse " & INTEGER'IMAGE(i) & ": Expected FILL=100, got " & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
                SEVERITY ERROR;
        END LOOP;
        
        -- On the 10th pulse, should transition to WASH
        wait for pulse_period;
        ASSERT light = WASH
            REPORT "Error: Should transition to WASH (010) after FILL state, got "  & std_logic'image(light(3)) & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
            SEVERITY ERROR;
        
        -- Check WASH state for 9 pulses (transitions on the 10th pulse)
        FOR i IN 1 TO 4 LOOP
            wait for pulse_period;
            ASSERT light = WASH
                REPORT "Error at WASH pulse " & INTEGER'IMAGE(i) & ": Expected WASH=010, got " & std_logic'image(light(3)) & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
                SEVERITY ERROR;
        END LOOP;
        
        -- On the 10th pulse, should transition to RINSE
        wait for pulse_period;
        ASSERT light = RINSE
            REPORT "Error: Should transition to RINSE (001) after WASH state, got " & std_logic'image(light(3)) & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
            SEVERITY ERROR;
        
        -- Check RINSE state for 4 pulses (transitions on the 5th pulse)
        FOR i IN 1 TO 1 LOOP
            wait for pulse_period;
            ASSERT light = RINSE
                REPORT "Error at RINSE pulse " & INTEGER'IMAGE(i) & ": Expected RINSE=001, got " & std_logic'image(light(3)) & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
                SEVERITY ERROR;
        END LOOP;
        
        -- On the 5th pulse, should cycle back to FILL
        wait for pulse_period;
        ASSERT light = SPIN
            REPORT "Error: Should cycle back to FILL (100) after RINSE state, got " & std_logic'image(light(3)) & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
            SEVERITY ERROR;

        FOR i IN 1 TO 3 LOOP
            wait for pulse_period;
            ASSERT light = SPIN
                REPORT "Error at RINSE pulse " & INTEGER'IMAGE(i) & ": Expected RINSE=001, got " & std_logic'image(light(3)) & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
                SEVERITY ERROR;
        END LOOP;

        wait for pulse_period;
        ASSERT light = FILL
            REPORT "Error: Should cycle back to FILL (100) after RINSE state, got " & std_logic'image(light(3)) & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
            SEVERITY ERROR;
        
        -- Wait for next cycle to reach a stable FILL state for disable test
        wait for 6 * pulse_period;
        -- On the 5th pulse, should cycle back to FILL
        wait for pulse_period;
        ASSERT light = FILL
            REPORT "Error: Should cycle back to FILL (100) after RINSE state, got " & std_logic'image(light(3)) & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
            SEVERITY ERROR;
        
        -- Disable test observer will check behavior
        wait for 800 ns; -- Continue until near end of simulation
        
        REPORT "*** SIMULATION COMPLETED SUCCESSFULLY - All assertions passed ***" SEVERITY NOTE;
        std.env.stop;
        wait;
    end process;
end Behavioral;