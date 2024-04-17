----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/08/2024 07:34:38 PM
-- Design Name: 
-- Module Name: clock_div - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_div_uart is
  Port ( clk : in std_logic;
         div : out std_logic);
end clock_div_uart;

architecture Behavioral of clock_div_uart is
    signal counter : std_logic_vector(26 downto 0) := (others => '0');
begin

    process(clk)
    begin
    
        if rising_edge(clk) then
            --50Mhz/115200Hz = 1085 => sub 1 => 1084
            if (unsigned(counter) < 1084) then
                counter <= std_logic_vector(unsigned(counter) + 1);
                div <='0'; --Happens at first countup after we set counter = 0
            else
                counter <= (others => '0');
                div <= '1'; --Happens @ Reset
            end if;
        end if;
    
    end process;
end Behavioral;