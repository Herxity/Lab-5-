----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/03/2024 08:29:34 PM
-- Design Name: 
-- Module Name: vga_ctrl - Behavioral
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

entity vga_ctrl is
    Port ( CLK : in STD_LOGIC;
         EN : in STD_LOGIC;
         HCOUNT : out STD_LOGIC_VECTOR(9 downto 0);
         VCOUNT : out STD_LOGIC_VECTOR(9 downto 0);
         VID : out STD_LOGIC;
         HS : out STD_LOGIC;
         VS : out STD_LOGIC);
end vga_ctrl;

architecture Behavioral of vga_ctrl is

    signal hcounter : STD_LOGIC_VECTOR(9 downto 0):=(others=>'0');
    signal vcounter : STD_LOGIC_VECTOR(9 downto 0):=(others=>'0');
    signal vid_sig : std_logic:='0';
    signal hs_sig : std_logic:='0';
    signal vs_sig : std_logic:='0';

begin
    HCOUNT <= hcounter;
    VCOUNT <= vcounter;
    HS<=hs_sig;
    VS<=vs_sig;
    VID<=vid_sig;

    time_counter:process(CLK)
    begin
        if(rising_edge(CLK) and EN ='1') then
            if(to_integer(unsigned(hcounter)) < 799) then
                hcounter <= std_logic_vector(unsigned(hcounter)+ 1);
            else
                hcounter <= (others=>'0');
                if(to_integer(unsigned(vcounter)) < 524) then
                    vcounter <= std_logic_vector(unsigned(vcounter) + 1);
                else
                    vcounter <= (others=>'0');
                end if;
            end if;
            --This is where we modify the actual resolution of the image. Everything else we can ignore, seemingly.
            if((to_integer(unsigned(hcounter)) <= 63) and (to_integer(unsigned(hcounter)) >= 0) and (to_integer(unsigned(vcounter)) <= 63)and (to_integer(unsigned(vcounter)) >= 0)) then
                vid_sig <= '1';
            else
                vid_sig <= '0';
            end if;
            if((to_integer(unsigned(hcounter)) >= 656) and (to_integer(unsigned(hcounter)) <= 751)) then
                hs_sig <= '0';
            else
                hs_sig <= '1';
            end if;
            if((to_integer(unsigned(vcounter)) >= 490) and (to_integer(unsigned(vcounter)) <= 491)) then
                vs_sig <= '0';
            else
                vs_sig <= '1';
            end if;
        end if;
    end process;

end Behavioral;