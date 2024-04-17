----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2024 12:32:35 PM
-- Design Name: 
-- Module Name: uart_tx - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_tx is
    Port (
        clk, en, send, rst : in std_logic;
        char : in std_logic_vector(7 downto 0);
        ready, tx : out std_logic );
end uart_tx;

architecture Behavioral of uart_tx is
    --Define FSM states
    type state is (idle,start,data);


    signal curr: state:=idle;


    signal char_register : std_logic_vector(7 downto 0):=(others=>'0');
    signal count : integer range 0 to 7 := 0;
begin


    process(clk)
    begin
        if (rising_edge(clk)) then

            if(rst='1') then
                --When rst is asserted, all internal registers are cleared and it goes into an idle state
                char_register <= (others=>'0');
                curr <= idle;
                count <= 0;
                tx<='1';
                ready<= '1';
            elsif (en = '1') then
                case curr is
                    when idle =>
                        if(send = '1') then
                            curr <= start;
                            char_register <= char;
                            
                        else
                            tx<='1';
                            ready<= '1';
                        end if;
                    when start =>
                        tx<='0';
                        ready<='0';
                        curr <= data;
                    when data =>
                        if(count < 7) then
                            tx <= char_register(count);
                            count <= count + 1;
                        elsif(count = 7) then
                            curr <= idle;
                            count <=0;
                            ready <= '1';
                            tx <= char_register(count);
                        end if;
                    when others =>
                        curr <= idle;
                end case;

            end if;

        end if;


    end process;


end Behavioral;