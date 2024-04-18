----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2024 06:31:23 PM
-- Design Name: 
-- Module Name: framebuffer - Behavioral
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

entity framebuffer is
    generic(
        DATA : integer := 16;
        ADDR : integer := 12
    );
    Port (
        clk1, en1, en2, ld : in std_logic;
        addr1, addr2 : in std_logic_vector(ADDR-1 downto 0);
        wr_en1 : in std_logic;
        din1: in std_logic_vector(15 downto 0);
        dout1, dout2 : out std_logic_vector(15 downto 0));
end framebuffer;

architecture Behavioral of framebuffer is

    -- memory 
    type mem_type is array (0 to (2**ADDR)-1) of std_logic_vector(DATA-1 downto 0);
    signal mem: mem_type := (others=>(others=>'0'));
    signal count: integer;
begin

    --Port A 
    process(clk1)
    begin
        if rising_edge(clk1) then
            if ld ='1' then --synchronous reset, line needs to be held high for 4096 cycles for complete reset.
                if(count <= 4095) then 
                    count <= count + 1;
                    mem(count) <= b"0000000000000000";
                else
                    count <= 0;
                end if;
            elsif en1 = '1' then
                if(wr_en1 = '1') then
                    mem(to_integer(unsigned(addr1))) <= din1;
                end if;
                dout1 <= mem(to_integer(unsigned(addr1)));
            end if;
        end if;

    end process;

    --Port B 
    process(clk1)
    begin
        if rising_edge(clk1) and en2 = '1' then
            dout2 <= mem(to_integer(unsigned(addr2)));
        end if;
    end process;

end Behavioral;
