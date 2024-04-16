----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2024 05:12:53 PM
-- Design Name: 
-- Module Name: my_alu - Behavioral
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
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity my_alu is
    Port ( A, B : in std_logic_vector(15 downto 0);
         OPCODE : in std_logic_vector(3 downto 0);
         RES : out std_logic_vector(15 downto 0);
         clk: std_logic);
end my_alu;

architecture Behavioral of my_alu is
    signal shift_right_arithmetic_A :std_logic_vector(15 downto 0);
    signal signed_AgrB,signed_BgrA,unsigned_AeqB, unsigned_AgrB, unsigned_BgrA : STD_LOGIC;
begin
    signed_AgrB <= '1' when (signed(A) < signed(B)) else '0';
    signed_BgrA <= '1' when (signed(A) > signed(B)) else '0';
    unsigned_AeqB <= '1' when (unsigned(A) = unsigned(B)) else '0';
    unsigned_AgrB <= '1' when (unsigned(A) > unsigned(B)) else '0';
    unsigned_BgrA <= '1' when (unsigned(A) < unsigned(B)) else '0';
    
    shift_right_arithmetic_A <=std_logic_vector(shift_right(unsigned(A),1));
    process(clk)   
    begin
        if rising_edge(clk) then 
            case OPCODE is
                when "0000" => RES <= A + B; --x"0"
                when "0001" => RES <= A-B; -- x"1"
                when "0010" => RES <= A+1; --x"2"
                when "0011" => RES <= A-1; --x"3"
                when "0100" => RES <= 0-A;--x"4"
                when "0101" => RES <= A(14 downto 0) & '0'; --x"5"
                when "0110" => RES <= '0' & A(15 downto 1); --x"6"
                when "0111" => RES <= A(3) & shift_right_arithmetic_A(14 downto 0); --x"7"
                when "1000" => RES <= A and B; --x"8"
                when "1001" => RES <= A or B; --x"9"
                when "1010" => RES <= A xor B; --x"A" 
                when "1011" => RES <= "000000000000000" & signed_AgrB; --x"B"
                when "1100" => RES <= "000000000000000" & signed_BgrA; --x"C"
                when "1101" => RES <= "000000000000000" & unsigned_AeqB; --x"D"
                when "1110" => RES <= "000000000000000" & unsigned_BgrA; --x"E"
                when "1111" => RES <= "000000000000000" & unsigned_AgrB; --x"F"
                when others => RES <= (others=>'0');
            end case;
        end if;
    end process;
end Behavioral;