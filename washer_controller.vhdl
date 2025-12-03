library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Washer is
    Port ( clk : in STD_LOGIC;
           clkEn : in STD_LOGIC;
           reset : in STD_LOGIC;
           light : out STD_LOGIC_VECTOR (3 downto 0)
           );
end Washer;

architecture Behavioral of Washer is
    type state_type is (FILL, WASH, RINSE, SPIN);
    signal current_state : state_type;
    signal counter : integer := 0;
    constant freq : integer := 20; -- Clock frequency divider
    signal clkCounter : integer := 0;
    signal second_pulse : STD_LOGIC := '0';

begin
    -- Sequential process: state transitions and counter
    process(second_pulse, reset)
    begin
        if reset = '0' then
            current_state <= FILL;
            counter <= 0;
        elsif rising_edge(second_pulse) then
            if clkEn = '1' then
                case current_state is
                    when FILL =>
                        if counter >= 2 then
                            current_state <= WASH;
                            counter <= 0;
                        else
                            counter <= counter + 1;
                        end if;
                    when WASH =>
                        if counter >= 4 then
                            current_state <= RINSE;
                            counter <= 0;
                        else
                            counter <= counter + 1;
                        end if;
                    when RINSE =>
                        if counter >= 2 then
                            current_state <= SPIN;
                            counter <= 0;
                        else
                            counter <= counter + 1;
                        end if;
                    when SPIN =>
                        if counter >= 2 then
                            current_state <= FILL;
                            counter <= 0;
                        else
                            counter <= counter + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Combinational process: output assignment only
    process(current_state)
    begin
        case current_state is
            when FILL =>
                light <= "1000"; -- FILL light on
            when WASH =>
                light <= "0100"; -- WASH light on
            when RINSE =>
                light <= "0010"; -- RINSE light on
            when SPIN =>
                light <= "0001"; -- SPIN light on
        end case;
    end process;

    process(clk)
    begin
        if (clkEn = '1') then
            if rising_edge(clk) then
                if clkCounter = freq - 1 then
                    clkCounter <= 0;
                    second_pulse <= '1';
                else
                    clkCounter <= clkCounter + 1;
                    second_pulse <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;